import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

import 'browser.dart';
import 'database.dart';
import 'feed_kind.dart';
import 'feed_parser.dart';
import 'inbox_parser.dart';
import 'media_downloader.dart';
import 'stories_parser.dart';

final _blockedPath = RegExp(r'^/(accounts/login|challenge|checkpoint)');

class FetchReport {
  String? userAgent;
  final androidFeatures = <String, bool>{};
  Map<String, dynamic>? hookInstalled;
  String? visibilityWhileScrolling;
  bool? mediaExcludedFromBackup;
  int inlinePages = 0;
  int hookedPages = 0;
  int graphqlStarted = 0;
  int graphqlResponses = 0;
  int scrolls = 0;
  bool? hasNextPage;
  final posts = <String, Post>{};
  int newPosts = 0;
  int duplicatePosts = 0;
  bool reachedStoredPost = false;
  int repeatPagesInARow = 0;
  final skippedNodeTypes = <String, int>{};
  final mediaNodesWithExtras = <String, int>{};
  int filesDownloaded = 0;
  int bytesDownloaded = 0;
  int downloadsFailed = 0;
  final errors = <String>[];
  bool inboxBadgeSeen = false;
  int? unreadConversations;
  String? stopReason;
  String? stallDiagnostics;
  String? blockedReason;
  HeadlessInAppWebView? blockedWebView;
  Duration? duration;

  int get pages => inlinePages + hookedPages;
}

class FeedFetcher {
  FeedFetcher({required this.feed, required this.db, required this.log, this.maxPosts = 50});

  final FeedKind feed;
  final AppDatabase db;
  final void Function(String line) log;
  final int maxPosts;
  final report = FetchReport();
  final _random = Random();
  final _started = DateTime.now();
  late final MediaDownloader _downloader;
  Future<void> _pageQueue = Future.value();
  final _newVideoPostIds = <String>{};

  static const _maxIdleScrolls = 8;
  static const _maxRepeatPages = 2;
  static const _maxScrolls = 80;

  Future<FetchReport> run() async {
    final settings = await browserSettings();
    report.userAgent = settings.userAgent;
    if (Platform.isAndroid) {
      for (final feature in [
        WebViewFeature.DOCUMENT_START_SCRIPT,
        WebViewFeature.REQUESTED_WITH_HEADER_ALLOW_LIST,
      ]) {
        report.androidFeatures[feature.toNativeValue()] = await WebViewFeature.isFeatureSupported(feature);
      }
    }

    if (!await hasInstagramSession()) {
      report.blockedReason = 'no Instagram session cookie, log in first';
      return report;
    }

    _downloader = await MediaDownloader.open(userAgent: settings.userAgent!);
    report.mediaExcludedFromBackup = _downloader.excludedFromBackup;

    final hookSource = await rootBundle.loadString('assets/feed_hook.js');
    final feedUrl = feed.url;
    InAppWebViewController? controller;

    final webView = HeadlessInAppWebView(
      initialSize: const Size(390, 844),
      initialSettings: settings,
      initialUrlRequest: URLRequest(url: WebUri(feedUrl)),
      initialUserScripts: UnmodifiableListView([
        UserScript(
          source: hookSource,
          injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          forMainFrameOnly: true,
        ),
      ]),
      onWebViewCreated: (created) {
        controller = created;
        created.addJavaScriptHandler(handlerName: 'feedHook', callback: (args) => _onHookMessage(args.first));
      },
      onLoadStop: (loaded, uri) async {
        _checkBlockedUrl(uri);
        final hasPasswordField =
            await loaded.evaluateJavascript(source: "!!document.querySelector('input[type=\"password\"]')");
        if (hasPasswordField == true) report.blockedReason ??= 'login form shown at $uri';
      },
      onUpdateVisitedHistory: (_, uri, _) => _checkBlockedUrl(uri),
      onReceivedError: (_, request, error) {
        if (request.isForMainFrame ?? false) report.errors.add('load error: ${error.type} ${error.description}');
      },
    );

    _log('loading $feedUrl');
    await webView.run();

    final gotFirstPage = await _waitUntil(
      () => report.blockedReason != null || report.pages > 0,
      const Duration(seconds: 25),
    );
    if (!gotFirstPage) report.errors.add('no feed data within 25s of loading');

    var idleScrolls = 0;
    var pagesSeen = report.pages;
    while ((report.stopReason = _stopReason()) == null) {
      idleScrolls = report.pages == pagesSeen ? idleScrolls + 1 : 0;
      pagesSeen = report.pages;
      if (idleScrolls > _maxIdleScrolls) {
        report.stopReason = 'no new page after $_maxIdleScrolls scrolls';
        if (controller != null) report.stallDiagnostics = await _stallDiagnostics(controller!);
        break;
      }
      await Future.delayed(_humanPause());
      report.visibilityWhileScrolling ??= await controller?.evaluateJavascript(source: 'document.visibilityState');
      final screens = 0.8 + _random.nextDouble();
      await controller?.evaluateJavascript(source: 'window.scrollBy(0, Math.round(innerHeight * $screens))');
      report.scrolls++;
    }

    await _pageQueue;
    if (report.blockedReason == null && !report.inboxBadgeSeen) {
      await _waitUntil(() => report.inboxBadgeSeen, const Duration(seconds: 5));
    }
    if (report.blockedReason == null && controller != null) {
      await _extractStoriesFromDom(controller!);
    }
    if (report.blockedReason != null) {
      report.blockedWebView = webView;
    } else {
      await webView.dispose();
    }

    await _downloadMissingMedia();
    report.filesDownloaded = _downloader.filesDownloaded;
    report.bytesDownloaded = _downloader.bytesDownloaded;
    _downloader.close();
    report.duration = DateTime.now().difference(_started);
    return report;
  }

  void _log(String line) {
    final seconds = DateTime.now().difference(_started).inMilliseconds / 1000;
    log('+${seconds.toStringAsFixed(1)}s $line');
  }

  String? _stopReason() {
    if (report.blockedReason != null) return 'blocked: ${report.blockedReason}';
    if (report.reachedStoredPost) return 'reached a post already in ${feed.label}';
    if (report.repeatPagesInARow >= _maxRepeatPages) {
      return '$_maxRepeatPages pages in a row repeated posts already seen in this refresh';
    }
    if (report.scrolls >= _maxScrolls) return 'reached $_maxScrolls scrolls';
    if (report.posts.length >= maxPosts) return 'reached cap of $maxPosts posts';
    if (report.hasNextPage == false) return 'end of feed';
    return null;
  }

  /// Mostly short gaps between flicks, with an occasional longer pause as if
  /// reading a post.
  Duration _humanPause() {
    final reading = _random.nextDouble() < 0.12 ? 2500 + _random.nextInt(3500) : 0;
    return Duration(milliseconds: 900 + _random.nextInt(1800) + reading);
  }

  void _checkBlockedUrl(WebUri? uri) {
    if (uri != null && _blockedPath.hasMatch(uri.path)) report.blockedReason ??= 'redirected to $uri';
  }

  void _onHookMessage(dynamic message) {
    if (message is! Map) return;
    switch (message['type']) {
      case 'hookInstalled':
        report.hookInstalled = message.cast<String, dynamic>();
        _log('hook installed: readyState=${message['readyState']} '
            'visibility=${message['visibilityState']} '
            'scriptsInDom=${message['scriptsInDom']} '
            'fetchWasNative=${message['fetchWasNative']} '
            'xhrOpenWasNative=${message['xhrOpenWasNative']}');
      case 'inline':
        final bodies = (message['bodies'] as List? ?? []).whereType<String>().toList();
        _log('inline scan at ${message['phase']}: ${message['scriptCount']} JSON scripts, '
            '${bodies.length} with feed data');
        for (final body in bodies) {
          _enqueuePages(body, source: 'inline');
        }
      case 'inboxBadge':
        report.inboxBadgeSeen = true;
        final body = message['body'];
        report.unreadConversations = body is String ? unreadConversationCount(body) : null;
        _log('inbox badge: ${report.unreadConversations} unread conversations');
      case 'storiesTray':
        final body = message['body'];
        if (body is String) {
          final parsed = parseStories(body);
          if (parsed.isNotEmpty) {
            _log('stories tray: received ${parsed.length} stories from hook');
            db.saveStories(parsed);
          }
        }
      case 'graphqlStart':
        report.graphqlStarted++;
      case 'graphql':
        report.graphqlResponses++;
        final body = message['body'];
        if (body is String) _enqueuePages(body, source: 'hook/${message['via']}');
    }
  }

  /// Pages are stored one after another so that the stop check sees the
  /// already-stored post as soon as its page has been processed.
  void _enqueuePages(String body, {required String source}) {
    _pageQueue = _pageQueue.then((_) => _storePages(body, source: source));
  }

  Future<void> _storePages(String body, {required String source}) async {
    try {
      for (final page in parseFeedPages(body)) {
        var newPosts = 0;
        var duplicates = 0;
        for (final media in page.media) {
          final post = Post.fromMedia(media);
          if (post == null) {
            report.errors.add('media node without pk/id ($source)');
            continue;
          }
          if (report.posts.containsKey(post.id)) {
            duplicates++;
            continue;
          }
          report.posts[post.id] = post;
          switch (await db.savePost(post, feed)) {
            case SaveResult.newPost:
              newPosts++;
              _newVideoPostIds.add(post.id);
            case SaveResult.addedToFeed:
              newPosts++;
            case SaveResult.alreadyInFeed:
              duplicates++;
              report.reachedStoredPost = true;
          }
        }
        if (source == 'inline') {
          report.inlinePages++;
        } else {
          report.hookedPages++;
        }
        report.newPosts += newPosts;
        report.duplicatePosts += duplicates;
        final repeated = page.media.isNotEmpty && duplicates == page.media.length && !report.reachedStoredPost;
        report.repeatPagesInARow = repeated ? report.repeatPagesInARow + 1 : 0;
        report.hasNextPage = page.hasNextPage;
        _addCounts(report.skippedNodeTypes, page.skippedNodeTypes);
        _addCounts(report.mediaNodesWithExtras, page.mediaNodesWithExtras);
        _log('page ${report.pages} from $source: ${page.media.length} posts '
            '($newPosts new, $duplicates duplicate), skipped ${page.skippedNodeTypes}, '
            'has_next_page=${page.hasNextPage}');
      }
    } catch (error) {
      report.errors.add('parse/store error ($source): $error');
    }
  }

  Future<void> _downloadMissingMedia() async {
    final avatars = await db.postsMissingAvatar();
    final images = await db.mediaMissingImage(coverOnly: true);
    final storyAvatars = await db.storiesMissingAvatar();
    _log('downloading ${avatars.length} post avatars, ${storyAvatars.length} story avatars, ${images.length} thumbnails');
    await Future.wait([
      for (final post in avatars)
        _downloadFile(post.profilePicUrl!, '${post.id} avatar').then((file) async {
          if (file != null) await db.setAvatarFile(post.id, file);
        }),
      for (final story in storyAvatars)
        _downloadFile(story.avatarUrl!, 'story_${story.id} avatar').then((file) async {
          if (file != null) await db.setStoryAvatarFile(story.id, file);
        }),
      for (final media in images)
        _downloadFile(media.imageUrl!, '${media.postId}#${media.position} thumbnail').then((file) async {
          if (file != null) await db.setMediaFiles(media.postId, media.position, imageFile: file);
        }),
    ]);
  }

  Future<void> _extractStoriesFromDom(InAppWebViewController controller) async {
    try {
      final json = await controller.evaluateJavascript(source: '''
(function() {
  var stories = [];
  var seen = {};
  var links = document.querySelectorAll('a[href*="/stories/"], [role="menuitem"]');
  for (var i = 0; i < links.length; i++) {
    var el = links[i];
    var href = el.getAttribute('href') || (el.querySelector('a') && el.querySelector('a').getAttribute('href')) || '';
    var match = href.match(/\\/stories\\/([^\\/\\?]+)/);
    var img = el.querySelector('img');
    var username = match ? match[1] : null;
    if (!username && img && img.alt) {
      var altMatch = img.alt.match(/(.+?)['’]s profile picture/);
      if (altMatch) username = altMatch[1];
    }
    if (!username || seen[username]) continue;
    seen[username] = true;

    var avatarUrl = img ? img.src : null;
    var canvas = el.querySelector('canvas');
    var hasUnseen = !!canvas || (el.innerHTML.indexOf('gradient') !== -1) || true;
    stories.push({
      id: username,
      username: username,
      avatarUrl: avatarUrl,
      hasUnseen: hasUnseen
    });
  }
  return JSON.stringify(stories);
})()
''');
      if (json is String && json.isNotEmpty && json != '[]') {
        final parsed = parseStories(json);
        if (parsed.isNotEmpty) {
          _log('extracted ${parsed.length} stories from DOM');
          await db.saveStories(parsed);
        }
      }
    } catch (e) {
      _log('failed DOM stories extraction: $e');
    }
  }

  Future<String> _stallDiagnostics(InAppWebViewController controller) async {
    final metrics = await controller.evaluateJavascript(
      source: "[scrollY, innerHeight, document.documentElement.scrollHeight].join('/')",
    );
    final screenshot = await controller.takeScreenshot();
    var saved = 'no screenshot';
    if (screenshot != null) {
      final file = File('${(await getTemporaryDirectory()).path}/stall.png');
      await file.writeAsBytes(screenshot);
      saved = 'screenshot tmp/stall.png';
    }
    return 'scrollY/innerHeight/scrollHeight=$metrics, '
        'requests started=${report.graphqlStarted} finished=${report.graphqlResponses}, $saved';
  }

  Future<String?> _downloadFile(String url, String label) async {
    try {
      return await _downloader.download(url);
    } catch (error) {
      report.downloadsFailed++;
      report.errors.add('download failed for $label: $error');
      return null;
    }
  }
}

void _addCounts(Map<String, int> into, Map<String, int> from) {
  from.forEach((key, count) => into[key] = (into[key] ?? 0) + count);
}

Future<bool> _waitUntil(bool Function() condition, Duration timeout) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) return false;
    await Future.delayed(const Duration(milliseconds: 250));
  }
  return true;
}
