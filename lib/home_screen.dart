import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'browser.dart';
import 'database.dart';
import 'feed_fetcher.dart';
import 'feed_kind.dart';
import 'login_screen.dart';
import 'media_downloader.dart';
import 'messages_view.dart';
import 'profile_sheet.dart';
import 'search_view.dart';
import 'spike_screen.dart';
import 'updates_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.db, required this.initialFeed});

  final AppDatabase db;
  final FeedKind initialFeed;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _titles = ['Updates', 'Search', 'Messages'];
  static const _messagesTab = 2;

  static const _feed = FeedKind.following;
  bool _unreadOnly = true;
  late Stream<List<FeedEntry>> _entries = widget.db.watchFeed(_feed, unreadOnly: _unreadOnly);
  late final Future<Directory> _mediaDirectory = mediaDirectory();
  int _tab = 0;
  bool _messagesOpened = false;
  bool _updating = false;
  int _unreadConversations = 0;

  @override
  void initState() {
    super.initState();
    widget.db.unreadConversations().then((count) {
      if (mounted) setState(() => _unreadConversations = count);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _loginIfNeeded());
  }

  void _setUnreadConversations(int count) {
    setState(() => _unreadConversations = count);
    widget.db.saveUnreadConversations(count);
  }

  Future<void> _loginIfNeeded() async {
    if (!await hasInstagramSession() && mounted) await openLogin(context);
  }

  Future<void> _refresh() async {
    if (_updating) return;
    setState(() => _updating = true);
    final report = await FeedFetcher(feed: _feed, db: widget.db, log: (line) => debugPrint('[refresh] $line')).run();
    debugPrint('[refresh] done: ${report.stopReason}; ${report.newPosts} new, ${report.duplicatePosts} duplicate; '
        'skipped ${report.skippedNodeTypes}; errors ${report.errors}');
    if (!mounted) return;
    setState(() => _updating = false);
    if (report.unreadConversations case final count?) _setUnreadConversations(count);

    if (report.blockedReason != null) {
      await openLogin(context, report.blockedWebView);
      return;
    }
    final summary = report.newPosts == 0 ? 'Up to date' : '${report.newPosts} new posts';
    final errors = report.errors.isEmpty ? '' : ' · ${report.errors.length} errors (see debug)';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$summary$errors')));
  }

  void _selectTab(int tab) {
    setState(() {
      _tab = tab;
      if (tab == _messagesTab) _messagesOpened = true;
    });
  }

  void _setUnreadOnly(bool unreadOnly) {
    if (_unreadOnly == unreadOnly) return;
    setState(() {
      _unreadOnly = unreadOnly;
      _entries = widget.db.watchFeed(_feed, unreadOnly: _unreadOnly);
    });
  }

  void _onPostDismissed(FeedEntry entry) {
    widget.db.markPostAsRead(entry.post.id, isRead: true);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1800),
        behavior: SnackBarBehavior.floating,
        persist: false,
        content: Text('Marked as read: @${entry.post.username ?? "post"}'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            widget.db.markPostAsRead(entry.post.id, isRead: false);
          },
        ),
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark all as read?'),
        content: const Text('This will clear all unread posts from your feed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Mark as Read'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final clearedIds = await widget.db.markAllPostsAsRead(_feed);
    if (!mounted) return;
    if (clearedIds.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No unread posts')),
      );
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        persist: false,
        content: Text('${clearedIds.length} posts marked as read'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            widget.db.markPostsAsUnread(clearedIds);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _tab == _messagesTab
          ? null
          : AppBar(
              title: _tab == 0
                  ? SegmentedButton<bool>(
                      showSelectedIcon: false,
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text('Unread', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text('All', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ],
                      selected: {_unreadOnly},
                      onSelectionChanged: (set) => _setUnreadOnly(set.first),
                    )
                  : Text(_titles[_tab]),
              actions: [
                if (_tab == 0) ...[
                  IconButton(
                    tooltip: 'Mark all as read',
                    icon: const Icon(Icons.done_all),
                    onPressed: _markAllAsRead,
                  ),
                  IconButton(
                    tooltip: 'My Profile',
                    icon: const Icon(Icons.person_outline),
                    onPressed: () => openProfile(context, db: widget.db),
                  ),
                  IconButton(
                    tooltip: 'Debug',
                    icon: const Icon(Icons.bug_report_outlined),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SpikeScreen(db: widget.db, feed: _feed)),
                    ),
                  ),
                ],
              ],
              bottom: _tab == 0 && _updating ? const _UpdatingBar() : null,
            ),
      body: IndexedStack(
        index: _tab,
        children: [
          FutureBuilder<Directory>(
            future: _mediaDirectory,
            builder: (context, directory) {
              if (!directory.hasData) return const SizedBox.shrink();
              return StreamBuilder<List<FeedEntry>>(
                stream: _entries,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();
                  return UpdatesView(
                    entries: snapshot.data!,
                    mediaDirectory: directory.data!,
                    onRefresh: () async => unawaited(_refresh()),
                    onUserTap: (username) => openProfile(context, username: username, db: widget.db),
                    onDismiss: _onPostDismissed,
                    unreadOnly: _unreadOnly,
                    onToggleFilter: () => _setUnreadOnly(false),
                  );
                },
              );
            },
          ),
          SearchView(isActive: _tab == 1),
          _messagesOpened ? const MessagesView() : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Updates',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _unreadConversations > 0,
              label: Text('$_unreadConversations'),
              child: const Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: Badge(
              isLabelVisible: _unreadConversations > 0,
              label: Text('$_unreadConversations'),
              child: const Icon(Icons.chat_bubble),
            ),
            label: 'Messages',
          ),
        ],
      ),
    );
  }
}

class _UpdatingBar extends StatelessWidget implements PreferredSizeWidget {
  const _UpdatingBar();

  @override
  Size get preferredSize => const Size.fromHeight(26);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text('Updating…', style: Theme.of(context).textTheme.labelMedium),
        ),
        const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }
}
