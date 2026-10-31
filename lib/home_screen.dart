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
  static const _titles = ['Updates', 'Messages', 'Search'];
  static const _messagesTab = 1;

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
      extendBody: true,
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
          _messagesOpened ? const MessagesView() : const SizedBox.shrink(),
          SearchView(isActive: _tab == 2),
        ],
      ),
      bottomNavigationBar: _FloatingInstagramBar(
        selectedIndex: _tab,
        onTap: (index) {
          if (index == 3) {
            openProfile(context, db: widget.db);
            return;
          }
          _selectTab(index);
        },
        unreadConversations: _unreadConversations,
      ),
    );
  }
}

class _FloatingInstagramBar extends StatelessWidget {
  const _FloatingInstagramBar({
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
    final iconColor = isDark ? Colors.white : Colors.black;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                blurRadius: 18,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _FloatingNavItem(
                  isSelected: selectedIndex == 0,
                  onTap: () => onTap(0),
                  child: CustomPaint(
                    size: const Size(24, 24),
                    painter: _HomePainter(
                      color: iconColor,
                      filled: selectedIndex == 0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _FloatingNavItem(
                  isSelected: selectedIndex == 1,
                  onTap: () => onTap(1),
                  child: CustomPaint(
                    size: const Size(24, 24),
                    painter: _PaperPlanePainter(
                      color: iconColor,
                      hasUnread: unreadConversations > 0,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _FloatingNavItem(
                  isSelected: selectedIndex == 2,
                  onTap: () => onTap(2),
                  child: CustomPaint(
                    size: const Size(24, 24),
                    painter: _SearchPainter(
                      color: iconColor,
                      bold: selectedIndex == 2,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _FloatingNavItem(
                  isSelected: false,
                  onTap: () => onTap(3),
                  child: CustomPaint(
                    size: const Size(24, 24),
                    painter: _ProfilePainter(
                      color: iconColor,
                      bold: false,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FloatingNavItem extends StatelessWidget {
  const _FloatingNavItem({
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  final Widget child;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Container(
          width: 64,
          height: 44,
          decoration: isSelected
              ? BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(22),
                )
              : null,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

class _HomePainter extends CustomPainter {
  const _HomePainter({required this.color, required this.filled});
  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final path = Path();
    path.moveTo(12.0, 2.5);
    path.lineTo(2.5, 10.5);
    path.lineTo(2.5, 20.0);
    path.arcToPoint(const Offset(4.5, 22.0), radius: const Radius.circular(2));
    path.lineTo(9.2, 22.0);
    path.lineTo(9.2, 14.8);
    path.arcToPoint(const Offset(14.8, 14.8), radius: const Radius.circular(2.8));
    path.lineTo(14.8, 22.0);
    path.lineTo(19.5, 22.0);
    path.arcToPoint(const Offset(21.5, 20.0), radius: const Radius.circular(2));
    path.lineTo(21.5, 10.5);
    path.close();

    if (filled) {
      canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.fill);
    } else {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HomePainter old) => color != old.color || filled != old.filled;
}

class _PaperPlanePainter extends CustomPainter {
  const _PaperPlanePainter({required this.color, required this.hasUnread});
  final Color color;
  final bool hasUnread;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final outline = Path();
    outline.moveTo(21.8, 2.2);
    outline.lineTo(2.2, 9.8);
    outline.lineTo(9.8, 14.0);
    outline.lineTo(14.0, 21.8);
    outline.close();

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(outline, strokePaint);
    canvas.drawLine(const Offset(9.8, 14.0), const Offset(21.8, 2.2), strokePaint);

    if (hasUnread) {
      final redPaint = Paint()
        ..color = const Color(0xFFE83C4E)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(const Offset(20.5, 20.0), 3.2, redPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PaperPlanePainter old) => color != old.color || hasUnread != old.hasUnread;
}

class _SearchPainter extends CustomPainter {
  const _SearchPainter({required this.color, required this.bold});
  final Color color;
  final bool bold;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = bold ? 2.6 : 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(const Offset(10.2, 10.2), 6.8, strokePaint);
    canvas.drawLine(const Offset(15.2, 15.2), const Offset(21.2, 21.2), strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SearchPainter old) => color != old.color || bold != old.bold;
}

class _ProfilePainter extends CustomPainter {
  const _ProfilePainter({required this.color, required this.bold});
  final Color color;
  final bool bold;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.scale(scale, scale);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = bold ? 2.4 : 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(const Offset(12.0, 12.0), 9.6, strokePaint);

    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(const Offset(12.0, 9.0), 3.2, headPaint);

    canvas.save();
    final clipPath = Path()..addOval(Rect.fromCircle(center: const Offset(12.0, 12.0), radius: 8.8));
    canvas.clipPath(clipPath);

    final shoulderPath = Path();
    shoulderPath.moveTo(5.0, 20.0);
    shoulderPath.quadraticBezierTo(12.0, 14.0, 19.0, 20.0);
    canvas.drawPath(shoulderPath, strokePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ProfilePainter old) => color != old.color || bold != old.bold;
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
