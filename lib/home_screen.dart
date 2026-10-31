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
      bottomNavigationBar: _InstagramBottomBar(
        selectedIndex: _tab,
        onTap: _selectTab,
        unreadConversations: _unreadConversations,
      ),
    );
  }
}

class _InstagramBottomBar extends StatelessWidget {
  const _InstagramBottomBar({
    required this.selectedIndex,
    required this.onTap,
    required this.unreadConversations,
  });

  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int unreadConversations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark ? Colors.white60 : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              Expanded(
                child: _NavBarButton(
                  icon: selectedIndex == 0 ? Icons.home : Icons.home_outlined,
                  isSelected: selectedIndex == 0,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  onTap: () => onTap(0),
                ),
              ),
              Expanded(
                child: _NavBarButton(
                  icon: Icons.search,
                  isSelected: selectedIndex == 1,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  onTap: () => onTap(1),
                ),
              ),
              Expanded(
                child: _NavBarButton(
                  icon: selectedIndex == 2 ? Icons.chat_bubble : Icons.chat_bubble_outline,
                  isSelected: selectedIndex == 2,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                  badgeCount: unreadConversations,
                  onTap: () => onTap(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarButton extends StatelessWidget {
  const _NavBarButton({
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      size: 26,
      color: isSelected ? activeColor : inactiveColor,
    );

    if (badgeCount > 0) {
      iconWidget = Badge(
        label: Text(
          '$badgeCount',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFFF3040),
        child: iconWidget,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(child: iconWidget),
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
