import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'browser.dart';
import 'database.dart';

const _storyViewerScript = r"""
(function() {
  // 1. Spoof referrer so Instagram treats this as an internal navigation
  try {
    Object.defineProperty(document, 'referrer', {
      get: function() { return 'https://www.instagram.com/'; },
      configurable: true
    });
  } catch (e) {}

  // 2. Prevent native iOS full-screen video player hijacking
  if (window.HTMLVideoElement) {
    HTMLVideoElement.prototype.webkitEnterFullscreen = function() {};
    HTMLVideoElement.prototype.webkitRequestFullscreen = function() {};
    if (HTMLVideoElement.prototype.requestFullscreen) {
      HTMLVideoElement.prototype.requestFullscreen = function() { return Promise.resolve(); };
    }
  }

  function ensureInlineVideos() {
    var videos = document.querySelectorAll('video');
    for (var i = 0; i < videos.length; i++) {
      var v = videos[i];
      if (!v.hasAttribute('playsinline')) {
        v.setAttribute('playsinline', 'true');
        v.setAttribute('webkit-playsinline', 'true');
        v.playsInline = true;
      }
    }
  }

  // 3. Detect when this user's story reaches the end
  var storyNavHandled = false;

  function notifyStoryFinished() {
    if (storyNavHandled) return;
    storyNavHandled = true;
    window.flutter_inappwebview.callHandler('onStoryFinished');
  }

  function checkStoryUrl(urlStr) {
    try {
      var currentPath = urlStr ? new URL(urlStr, location.origin).pathname : location.pathname;
      if (currentPath === '/' || currentPath === '' || currentPath.startsWith('/explore') || currentPath.startsWith('/reels')) {
        notifyStoryFinished();
        return;
      }
      var m = currentPath.match(/\/stories\/([^\/]+)/);
      if (m && m[1]) {
        var targetUser = m[1].toLowerCase();
        if (initialUsername && targetUser !== initialUsername) {
          notifyStoryFinished();
          return;
        }
      }
    } catch (e) {}
  }

  var initialMatch = location.pathname.match(/\/stories\/([^\/]+)/);
  var initialUsername = initialMatch ? initialMatch[1].toLowerCase() : "";

  var origPush = history.pushState;
  history.pushState = function(state, title, url) {
    var ret = origPush.apply(this, arguments);
    if (url) checkStoryUrl(url.toString());
    return ret;
  };

  var origReplace = history.replaceState;
  history.replaceState = function(state, title, url) {
    var ret = origReplace.apply(this, arguments);
    if (url) checkStoryUrl(url.toString());
    return ret;
  };

  window.addEventListener('popstate', function() {
    checkStoryUrl(location.pathname);
  });

  // 4. Auto-dismiss "View as <username>?" interstitial prompt
  var viewAsDismissed = false;

  function dismissViewAs() {
    if (viewAsDismissed) return;

    // A. Check clickable buttons/elements matching "View as ..."
    var clickables = document.querySelectorAll('button, div[role="button"], a[role="button"]');
    for (var i = 0; i < clickables.length; i++) {
      var el = clickables[i];
      var text = (el.textContent || '').trim();
      if (/\b(view as|continue as|view story|open as)\b/i.test(text) &&
          !/\b(cancel|not now|switch|close|back)\b/i.test(text)) {
        var parent = el.closest('div[role="dialog"], div[style*="fixed"], div[style*="absolute"], section');
        if (parent) {
          parent.style.opacity = '0';
          parent.style.pointerEvents = 'none';
          parent.style.position = 'fixed';
          parent.style.top = '-9999px';
        }
        el.click();
        viewAsDismissed = true;
        return;
      }
    }

    // B. Check modal dialogs containing "view as" text
    var dialogs = document.querySelectorAll('div[role="dialog"]');
    for (var j = 0; j < dialogs.length; j++) {
      var dlg = dialogs[j];
      var dlgText = (dlg.textContent || '').toLowerCase();
      if (/\b(view as|continue as|view story as|open as)\b/i.test(dlgText)) {
        dlg.style.opacity = '0';
        dlg.style.pointerEvents = 'none';
        dlg.style.position = 'fixed';
        dlg.style.top = '-9999px';

        var dlgBtns = dlg.querySelectorAll('button, div[role="button"], a[role="button"]');
        for (var k = 0; k < dlgBtns.length; k++) {
          var b = dlgBtns[k];
          var bText = (b.textContent || '').trim().toLowerCase();
          if (bText && !/\b(cancel|not now|switch|close|back)\b/i.test(bText)) {
            b.click();
            viewAsDismissed = true;
            return;
          }
        }
        if (dlgBtns.length > 0) {
          dlgBtns[0].click();
          viewAsDismissed = true;
          return;
        }
      }
    }
  }

  function onDomMutated() {
    ensureInlineVideos();
    dismissViewAs();
    if (location.pathname === '/' || (!location.pathname.startsWith('/stories/') && location.pathname !== '')) {
      notifyStoryFinished();
    }
  }

  ensureInlineVideos();
  dismissViewAs();

  var domObserver = new MutationObserver(onDomMutated);
  if (document.documentElement) {
    domObserver.observe(document.documentElement, { childList: true, subtree: true });
  } else {
    document.addEventListener('DOMContentLoaded', function() {
      domObserver.observe(document.documentElement, { childList: true, subtree: true });
    });
  }

  var checkInterval = setInterval(function() {
    onDomMutated();
  }, 80);
  setTimeout(function() { clearInterval(checkInterval); }, 4000);

  // 4. Fallback horizontal swipe detection inside webview
  var startX = 0;
  var startY = 0;
  var startTime = 0;
  var handled = false;

  function onTouchStart(e) {
    if (e.touches && e.touches.length === 1) {
      startX = e.touches[0].clientX;
      startY = e.touches[0].clientY;
      startTime = Date.now();
      handled = false;
    }
  }

  function checkSwipe(currentX, currentY) {
    if (handled) return;
    var dx = currentX - startX;
    var dy = currentY - startY;
    var dt = Date.now() - startTime;
    if (Math.abs(dx) > 40 && Math.abs(dx) > Math.abs(dy) * 1.3 && dt < 800) {
      handled = true;
      if (dx < 0) {
        window.flutter_inappwebview.callHandler('onSwipeNext');
      } else {
        window.flutter_inappwebview.callHandler('onSwipePrev');
      }
    } else if (dy > 70 && Math.abs(dy) > Math.abs(dx) * 1.4 && dt < 800) {
      handled = true;
      window.flutter_inappwebview.callHandler('onSwipeClose');
    }
  }

  function onTouchMove(e) {
    if (e.touches && e.touches.length === 1) {
      checkSwipe(e.touches[0].clientX, e.touches[0].clientY);
    }
  }

  function onTouchEnd(e) {
    if (e.changedTouches && e.changedTouches.length === 1) {
      checkSwipe(e.changedTouches[0].clientX, e.changedTouches[0].clientY);
    }
  }

  window.addEventListener('touchstart', onTouchStart, { passive: true, capture: true });
  window.addEventListener('touchmove', onTouchMove, { passive: true, capture: true });
  window.addEventListener('touchend', onTouchEnd, { passive: true, capture: true });
  window.addEventListener('touchcancel', onTouchEnd, { passive: true, capture: true });

  // 6. Hide bottom nav, back buttons, close buttons, and feed elements
  var css = `
    div[style*="bottom: 0"]:has(a[href*="/reels/"]),
    div[style*="bottom:0"]:has(a[href*="/reels/"]),
    [aria-label*="Back" i],
    [aria-label*="back" i],
    [aria-label*="Go back" i],
    button:has([aria-label*="Back" i]),
    a:has([aria-label*="Back" i]),
    [aria-label*="Close" i],
    [aria-label*="close" i],
    button:has([aria-label*="Close" i]),
    a:has([aria-label*="Close" i]),
    div[role="button"]:has([aria-label*="Close" i]),
    [aria-label*="Exit" i],
    button:has([aria-label*="Exit" i]),
    a:has([aria-label*="Exit" i]),
    header a[href="/"],
    div[role="banner"] a[href="/"],
    a[href="/"],
    a[href="https://www.instagram.com/"],
    a[href="https://www.instagram.com"],
    div[role="feed"],
    article[role="presentation"],
    main:not(:has(video)):not(:has([aria-label*="Story" i])) {
      display: none !important;
    }
  `;

  document.addEventListener('click', function(e) {
    var target = e.target;
    if (!target) return;
    var closeEl = target.closest(
      '[aria-label*="Close" i], [aria-label*="Exit" i], a[href="/"], a[href="https://www.instagram.com/"], a[href="https://www.instagram.com"]'
    );
    if (closeEl) {
      e.preventDefault();
      e.stopPropagation();
      e.stopImmediatePropagation();
      window.flutter_inappwebview.callHandler('onSwipeClose');
    }
  }, true);
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
  await Navigator.of(context).push<void>(
    PageRouteBuilder(
      opaque: true,
      pageBuilder: (context, animation, secondaryAnimation) => StoryViewerScreen(
        stories: stories,
        initialIndex: initialIndex,
        db: db,
        mediaDirectory: mediaDirectory,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
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
  bool _isTransitioning = false;

  double? _dragStartX;
  double? _dragStartY;
  bool _dragHandled = false;

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
    if (_isTransitioning) return;
    if (targetIndex >= 0 && targetIndex < widget.stories.length) {
      widget.db.markStorySeen(widget.stories[targetIndex].username);
      _isTransitioning = true;
      _pageController
          .animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      )
          .whenComplete(() {
        if (mounted) _isTransitioning = false;
      });
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
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (e) {
          _dragStartX = e.position.dx;
          _dragStartY = e.position.dy;
          _dragHandled = false;
        },
        onPointerMove: (e) {
          if (_dragHandled || _dragStartX == null || _dragStartY == null) return;
          final dx = e.position.dx - _dragStartX!;
          final dy = e.position.dy - _dragStartY!;
          if (dx.abs() > 40 && dx.abs() > dy.abs() * 1.3) {
            _dragHandled = true;
            if (dx < 0) {
              _goTo(_currentIndex + 1);
            } else {
              _goTo(_currentIndex - 1);
            }
          } else if (dy > 70 && dy.abs() > dx.abs() * 1.4) {
            _dragHandled = true;
            Navigator.of(context).pop();
          }
        },
        onPointerUp: (e) {
          if (!_dragHandled && _dragStartX != null && _dragStartY != null) {
            final dx = e.position.dx - _dragStartX!;
            final dy = e.position.dy - _dragStartY!;
            if (dx.abs() > 40 && dx.abs() > dy.abs() * 1.3) {
              _dragHandled = true;
              if (dx < 0) {
                _goTo(_currentIndex + 1);
              } else {
                _goTo(_currentIndex - 1);
              }
            } else if (dy > 70 && dy.abs() > dx.abs() * 1.4) {
              _dragHandled = true;
              Navigator.of(context).pop();
            }
          }
          _dragStartX = null;
          _dragStartY = null;
          _dragHandled = false;
        },
        onPointerCancel: (_) {
          _dragStartX = null;
          _dragStartY = null;
          _dragHandled = false;
        },
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.stories.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
            widget.db.markStorySeen(widget.stories[index].username);
          },
          itemBuilder: (context, index) {
            final story = widget.stories[index];
            final shouldLoad = (index - _currentIndex).abs() <= 1;
            if (!shouldLoad) {
              return _StoryPlaceholder(
                username: story.username,
                avatarFile: _file(story.avatarFile),
                avatarUrl: story.avatarUrl,
              );
            }
            return _StoryPage(
              key: ValueKey(story.username),
              username: story.username,
              isActive: index == _currentIndex,
              onNextUser: () => _goTo(index + 1),
              onPrevUser: () => _goTo(index - 1),
              onClose: () => Navigator.of(context).pop(),
              onStoryFinished: () => _goTo(index + 1),
            );
          },
        ),
      ),
    );
  }
}

class _StoryPlaceholder extends StatelessWidget {
  const _StoryPlaceholder({
    required this.username,
    required this.avatarFile,
    required this.avatarUrl,
  });

  final String username;
  final File? avatarFile;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final avatarExists = avatarFile != null && avatarFile!.existsSync();
    final hasNetworkAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: avatarExists
                ? FileImage(avatarFile!)
                : (hasNetworkAvatar ? NetworkImage(avatarUrl!) as ImageProvider : null),
            child: !avatarExists && !hasNetworkAvatar
                ? Text(
                    username.characters.first.toUpperCase(),
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            '@$username',
            style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

class _StoryPage extends StatefulWidget {
  const _StoryPage({
    super.key,
    required this.username,
    required this.isActive,
    required this.onNextUser,
    required this.onPrevUser,
    required this.onClose,
    required this.onStoryFinished,
  });

  final String username;
  final bool isActive;
  final VoidCallback onNextUser;
  final VoidCallback onPrevUser;
  final VoidCallback onClose;
  final VoidCallback onStoryFinished;

  @override
  State<_StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<_StoryPage> {
  double _progress = 0;
  InAppWebViewController? _controller;

  @override
  void didUpdateWidget(covariant _StoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive && _controller != null) {
      if (widget.isActive) {
        _controller?.evaluateJavascript(
          source: "document.querySelectorAll('video').forEach(function(v) { v.play(); });",
        );
      } else {
        _controller?.evaluateJavascript(
          source: "document.querySelectorAll('video, audio').forEach(function(v) { v.pause(); });",
        );
      }
    }
  }

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
            final settings = snapshot.data!;
            settings.allowsInlineMediaPlayback = true;
            settings.mediaPlaybackRequiresUserGesture = false;

            return InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(url),
                headers: {
                  'Referer': 'https://www.instagram.com/',
                },
              ),
              initialSettings: settings,
              initialUserScripts: UnmodifiableListView([
                UserScript(
                  source: _storyViewerScript,
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                  forMainFrameOnly: true,
                ),
              ]),
              onWebViewCreated: (controller) {
                _controller = controller;
                controller.addJavaScriptHandler(
                  handlerName: 'onSwipeNext',
                  callback: (_) => widget.onNextUser(),
                );
                controller.addJavaScriptHandler(
                  handlerName: 'onSwipePrev',
                  callback: (_) => widget.onPrevUser(),
                );
                controller.addJavaScriptHandler(
                  handlerName: 'onSwipeClose',
                  callback: (_) => widget.onClose(),
                );
                controller.addJavaScriptHandler(
                  handlerName: 'onStoryFinished',
                  callback: (_) => widget.onStoryFinished(),
                );
              },
              onUpdateVisitedHistory: (controller, url, isReload) {
                if (url != null && url.host.contains('instagram.com')) {
                  final path = url.path;
                  if (path == '/' || path.isEmpty || path.startsWith('/explore') || path.startsWith('/reels')) {
                    widget.onStoryFinished();
                  } else if (path.startsWith('/stories/')) {
                    final segments = url.pathSegments;
                    if (segments.length >= 2) {
                      final targetUser = segments[1];
                      if (targetUser.isNotEmpty && targetUser.toLowerCase() != widget.username.toLowerCase()) {
                        widget.onStoryFinished();
                      }
                    }
                  }
                }
              },
              onLoadStop: (controller, url) {
                if (!widget.isActive) {
                  controller.evaluateJavascript(
                    source: "document.querySelectorAll('video, audio').forEach(function(v) { v.pause(); });",
                  );
                }
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url;
                if (uri != null && uri.host.contains('instagram.com')) {
                  final path = uri.path;
                  if (path.startsWith('/stories/')) {
                    final segments = uri.pathSegments;
                    if (segments.length >= 2) {
                      final targetUser = segments[1];
                      if (targetUser.isNotEmpty && targetUser.toLowerCase() != widget.username.toLowerCase()) {
                        widget.onNextUser();
                        return NavigationActionPolicy.CANCEL;
                      }
                    }
                  } else if (path == '/' || path.isEmpty || path.startsWith('/explore') || path.startsWith('/reels')) {
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
