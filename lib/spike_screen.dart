import 'package:flutter/material.dart';

import 'database.dart';
import 'feed_fetcher.dart';
import 'feed_kind.dart';
import 'feed_parser.dart';
import 'login_screen.dart';
import 'media_downloader.dart';

class SpikeScreen extends StatefulWidget {
  const SpikeScreen({super.key, required this.db, required this.feed});

  final AppDatabase db;
  final FeedKind feed;

  @override
  State<SpikeScreen> createState() => _SpikeScreenState();
}

class _SpikeScreenState extends State<SpikeScreen> {
  bool _running = false;
  final _lines = <String>[];

  @override
  void initState() {
    super.initState();
    _logStorage('stored');
  }

  Future<void> _logStorage(String label) async {
    final usage = await mediaFolderUsage();
    _log('$label: ${await widget.db.stats()}; media folder ${usage.files} files, ${_megabytes(usage.bytes)}');
  }

  String _megabytes(int bytes) => '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';

  void _log(String line) {
    debugPrint('[spike] $line');
    if (mounted) setState(() => _lines.add(line));
  }

  Future<void> _fetch() async {
    setState(() {
      _running = true;
      _lines.clear();
    });
    final report = await FeedFetcher(feed: widget.feed, db: widget.db, log: _log).run();
    _logReport(report);
    await _logStorage('stored now');
    setState(() => _running = false);
    if (report.blockedReason != null && mounted) await openLogin(context, report.blockedWebView);
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear stored data?'),
        content: const Text('Deletes every stored post and all downloaded media. Your Instagram login stays.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.db.deleteEverything();
    final deleted = await deleteAllMediaFiles();
    _log('cleared stored data; deleted $deleted media files');
    await _logStorage('stored');
  }

  void _logReport(FetchReport report) {
    _log('--- summary');
    _log('stopped: ${report.stopReason} after ${report.duration?.inSeconds}s');
    _log('user agent: ${report.userAgent}');
    if (report.androidFeatures.isNotEmpty) _log('android webview features: ${report.androidFeatures}');
    _log('page saw: ${report.hookInstalled?['userAgent']} brands=${report.hookInstalled?['uaBrands']}');
    _log('visibility while scrolling: ${report.visibilityWhileScrolling}');
    _log('pages: inline=${report.inlinePages} hooked=${report.hookedPages} '
        '(graphql requests started ${report.graphqlStarted}, finished ${report.graphqlResponses}; '
        'scrolls: ${report.scrolls})');
    if (report.stallDiagnostics != null) _log('stall: ${report.stallDiagnostics}');
    _log('posts: ${report.posts.length} seen, ${report.newPosts} new, ${report.duplicatePosts} duplicate');
    _log('downloads: ${report.filesDownloaded} files, ${_megabytes(report.bytesDownloaded)}, '
        '${report.downloadsFailed} failed; media excluded from iCloud backup: ${report.mediaExcludedFromBackup}');
    _log('skipped node types: ${report.skippedNodeTypes}');
    if (report.mediaNodesWithExtras.isNotEmpty) {
      _log('post nodes that also had: ${report.mediaNodesWithExtras}');
    }
    if (report.blockedReason != null) _log('BLOCKED: ${report.blockedReason}');
    for (final error in report.errors) {
      _log('ERROR: $error');
    }
    _log('--- posts');
    for (final post in report.posts.values) {
      _log(_describe(post));
    }
    final first = report.posts.values.firstOrNull;
    if (first != null) _log('first post raw keys: ${first.raw.keys.toList()}');
  }

  String _describe(Post post) {
    final kind = switch (post.mediaType) {
      1 => 'photo',
      2 => 'video',
      8 => 'carousel(${post.carousel.length})',
      _ => 'type ${post.mediaType}',
    };
    final caption = (post.caption ?? '').replaceAll('\n', ' ');
    final shortCaption = caption.length > 60 ? '${caption.substring(0, 60)}…' : caption;
    return '@${post.username} · ${post.takenAt?.toLocal()} · $kind/${post.productType} · '
        'likes ${post.likeCount} · comments ${post.commentCount} · ${post.permalink}\n'
        '   "$shortCaption"\n'
        '   image=${post.imageUrl != null} video=${post.videoUrl != null} '
        'avatar=${post.profilePicUrl != null} alt=${post.accessibilityCaption != null}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debug · ${widget.feed.label}')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              children: [
                OutlinedButton(onPressed: _running ? null : () => openLogin(context), child: const Text('Log in')),
                FilledButton(onPressed: _running ? null : _fetch, child: const Text('Refresh')),
                TextButton(onPressed: _running ? null : _confirmClear, child: const Text('Clear stored data')),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (_running) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _lines.length,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SelectableText(
                  _lines[index],
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
