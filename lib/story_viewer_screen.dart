import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'browser.dart';
import 'database.dart';

const _storyViewerScript = """
(function() {
  // Swipe detection for switching between stories
  var startX = 0;
  var startY = 0;
  var startTime = 0;

  window.addEventListener('touchstart', function(e) {
    if (e.touches && e.touches.length === 1) {
      startX = e.touches[0].clientX;
      startY = e.touches[0].clientY;
      startTime = Date.now();
    }
  }, { passive: true, capture: true });

  window.addEventListener('touchend', function(e) {
    if (e.changedTouches && e.changedTouches.length === 1) {
      var dx = e.changedTouches[0].clientX - startX;
      var dy = e.changedTouches[0].clientY - startY;
      var dt = Date.now() - startTime;
      if (Math.abs(dx) > 45 && Math.abs(dx) > Math.abs(dy) * 1.3 && dt < 600) {
        if (dx < 0) {
          window.flutter_inappwebview.callHandler('onSwipeNext');
        } else {
          window.flutter_inappwebview.callHandler('onSwipePrev');
        }
      }
    }
  }, { passive: true, capture: true });

  // Hide bottom nav and back buttons
  var css = `
    div[style*="bottom: 0"]:has(a[href*="/reels/"]),
    div[style*="bottom:0"]:has(a[href*="/reels/"]),
    [aria-label*="Back" i],
    [aria-label*="back" i],
    [aria-label*="Go back" i],
    button:has([aria-label*="Back" i]),
    a:has([aria-label*="Back" i]),
    header a[href="/"],
    div[role="banner"] a[href="/"] {
      display: none !important;
    }
  `;
  function apply() {
    var style = document.getElementById('__hide_story_nav');
    if (!style && (document.head || document.documentElement)) {
      style = document.createElement('style');
      style.id = '__hide_story_nav';
      style.textContent = css;
      (document.head || document.documentElement).appendChild(style);
    }
  }
  apply();
  document.addEventListener('DOMContentLoaded', apply);
  window.addEventListener('load', apply);
})();
""";

Future<void> openStoriesViewer(
  BuildContext context, {
  required List<StoredStory> stories,
  required int initialIndex,
  required AppDatabase db,
  required Directory mediaDirectory,
}) async {
  if (stories.isEmpty || !context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    backgroundColor: Colors.black,
    builder: (_) => StoryViewerScreen(
      stories: stories,
      initialIndex: initialIndex,
      db: db,
      mediaDirectory: mediaDirectory,
    ),
  );
}

class StoryViewerScreen extends StatefulWidget {
  const StoryViewerScreen({
    super.key,
    required this.stories,
    required this.initialIndex,
    required this.db,
    required this.mediaDirectory,
  });

  final List<StoredStory> stories;
  final int initialIndex;
  final AppDatabase db;
  final Directory mediaDirectory;

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late int _currentIndex;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.stories.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
    widget.db.markStorySeen(widget.stories[_currentIndex].username);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int targetIndex) {
    if (targetIndex >= 0 && targetIndex < widget.stories.length) {
      _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else if (targetIndex >= widget.stories.length) {
      Navigator.of(context).pop();
    }
  }

  File? _file(String? name) => name == null ? null : File('${widget.mediaDirectory.path}/$name');

  @override
  Widget build(BuildContext context) {
    final currentStory = widget.stories[_currentIndex];
    final avatar = _file(currentStory.avatarFile);
    final avatarExists = avatar != null && avatar.existsSync();
    final hasNetworkAvatar = currentStory.avatarUrl != null && currentStory.avatarUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundImage: avatarExists
                  ? FileImage(avatar)
                  : (hasNetworkAvatar ? NetworkImage(currentStory.avatarUrl!) as ImageProvider : null),
              child: !avatarExists && !hasNetworkAvatar
                  ? Text(
                      currentStory.username.characters.first.toUpperCase(),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '@${currentStory.username}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          if (_currentIndex > 0)
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.white70),
              tooltip: 'Previous story',
              onPressed: () => _goTo(_currentIndex - 1),
            ),
          Center(
            child: Text(
              '${_currentIndex + 1}/${widget.stories.length}',
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          if (_currentIndex < widget.stories.length - 1)
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Colors.white70),
              tooltip: 'Next story',
              onPressed: () => _goTo(_currentIndex + 1),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.stories.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          widget.db.markStorySeen(widget.stories[index].username);
        },
        itemBuilder: (context, index) {
          final story = widget.stories[index];
          return _StoryPage(
            key: ValueKey(story.username),
            username: story.username,
            onNextUser: () => _goTo(_currentIndex + 1),
            onPrevUser: () => _goTo(_currentIndex - 1),
            onStoryFinished: () => _goTo(_currentIndex + 1),
          );
        },
      ),
    );
  }
}

class _StoryPage extends StatefulWidget {
  const _StoryPage({
    super.key,
    required this.username,
    required this.onNextUser,
    required this.onPrevUser,
    required this.onStoryFinished,
  });

  final String username;
  final VoidCallback onNextUser;
  final VoidCallback onPrevUser;
  final VoidCallback onStoryFinished;

  @override
  State<_StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<_StoryPage> {
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    final url = 'https://www.instagram.com/stories/${widget.username}/';

    return Stack(
      children: [
        FutureBuilder<InAppWebViewSettings>(
          future: browserSettings(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator(color: Colors.white54));
            }
            return InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(url)),
              initialSettings: snapshot.data,
              initialUserScripts: UnmodifiableListView([
                UserScript(
                  source: _storyViewerScript,
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                  forMainFrameOnly: true,
                ),
              ]),
              onWebViewCreated: (controller) {
                controller.addJavaScriptHandler(
                  handlerName: 'onSwipeNext',
                  callback: (_) => widget.onNextUser(),
                );
                controller.addJavaScriptHandler(
                  handlerName: 'onSwipePrev',
                  callback: (_) => widget.onPrevUser(),
                );
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url;
                if (uri != null && uri.host.contains('instagram.com')) {
                  final path = uri.path;
                  // When a user's story reaches the end, Instagram Web navigates away to '/'
                  if (path == '/' || path.isEmpty || path.startsWith('/explore') || path.startsWith('/reels')) {
                    widget.onStoryFinished();
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
              onProgressChanged: (_, progress) {
                if (mounted) setState(() => _progress = progress / 100);
              },
            );
          },
        ),
        if (_progress > 0 && _progress < 1)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 2,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
            ),
          ),
      ],
    );
  }
}
