import 'dart:io';

import 'package:flutter/material.dart';

import 'database.dart';
import 'post_card.dart';

class UpdatesView extends StatefulWidget {
  const UpdatesView({
    super.key,
    required this.entries,
    required this.mediaDirectory,
    required this.onRefresh,
    this.onUserTap,
    this.onDismiss,
    this.unreadOnly = true,
    this.onToggleFilter,
  });

  final List<FeedEntry> entries;
  final Directory mediaDirectory;
  final Future<void> Function() onRefresh;
  final void Function(String username)? onUserTap;
  final void Function(FeedEntry entry)? onDismiss;
  final bool unreadOnly;
  final VoidCallback? onToggleFilter;

  @override
  State<UpdatesView> createState() => _UpdatesViewState();
}

class _UpdatesViewState extends State<UpdatesView> {
  final Set<String> _dismissedIds = {};

  @override
  void didUpdateWidget(UpdatesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentIds = widget.entries.map((e) => e.post.id).toSet();
    _dismissedIds.retainWhere(currentIds.contains);
  }

  @override
  Widget build(BuildContext context) {
    final visibleEntries = widget.entries.where((e) => !_dismissedIds.contains(e.post.id)).toList();

    if (visibleEntries.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.unreadOnly ? Icons.check_circle_outline : Icons.inbox_outlined,
                    size: 56,
                    color: widget.unreadOnly ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.unreadOnly ? 'All caught up!' : 'No posts yet',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.unreadOnly
                        ? 'You have seen all new posts. Pull down to refresh or browse your history.'
                        : 'Pull down to refresh and fetch updates.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, height: 1.4),
                  ),
                  if (widget.unreadOnly && widget.onToggleFilter != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: widget.onToggleFilter,
                      icon: const Icon(Icons.history, size: 18),
                      label: const Text('View All Posts'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.separated(
        itemCount: visibleEntries.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (_, index) {
          final entry = visibleEntries[index];
          return Dismissible(
            key: ValueKey(entry.post.id),
            direction: DismissDirection.horizontal,
            background: Container(
              color: Colors.green.withValues(alpha: 0.15),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Row(
                children: [
                  Icon(Icons.check, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Mark as read', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            secondaryBackground: Container(
              color: Colors.green.withValues(alpha: 0.15),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Mark as read', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.check, color: Colors.green),
                ],
              ),
            ),
            onDismissed: (_) {
              setState(() => _dismissedIds.add(entry.post.id));
              widget.onDismiss?.call(entry);
            },
            child: CompactPostTile(
              key: ValueKey(entry.post.id),
              entry: entry,
              mediaDirectory: widget.mediaDirectory,
              onUserTap: widget.onUserTap,
            ),
          );
        },
      ),
    );
  }
}
