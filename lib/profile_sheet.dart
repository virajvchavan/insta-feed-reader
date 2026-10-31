import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'browser.dart';
import 'database.dart';

const _hideNavScript = """
(function() {
  var startY = 0;
  var startX = 0;
  var isSwiping = false;

  window.addEventListener('touchstart', function(e) {
    if (e.touches && e.touches.length === 1) {
      startY = e.touches[0].clientY;
      startX = e.touches[0].clientX;
      isSwiping = false;
    }
  }, { passive: true, capture: true });

  window.addEventListener('touchmove', function(e) {
    var isReelPage = location.pathname.indexOf('/reel') !== -1;
    var target = e.target;
    var onVideo = !!(target && (target.tagName === 'VIDEO' || target.closest('video') || target.closest('div:has(> video)')));

    if (!isReelPage && !onVideo) return;

    var inComments = target && target.closest('div[role="dialog"], textarea, input, form, [aria-label*="comment" i]');
    if (inComments) return;

    if (e.touches && e.touches.length === 1) {
      var dy = Math.abs(e.touches[0].clientY - startY);
      var dx = Math.abs(e.touches[0].clientX - startX);
      if (dy > 4 && dy > dx) {
        isSwiping = true;
        e.preventDefault();
        e.stopPropagation();
      }
    }
  }, { passive: false, capture: true });

  window.addEventListener('touchend', function(e) {
    if (isSwiping) {
      isSwiping = false;
      if (location.pathname.indexOf('/reel') !== -1) {
        e.preventDefault();
        e.stopPropagation();
      }
    }
  }, { passive: false, capture: true });

  var css = `
    div[style*="bottom: 0"]:has(a[href*="/reels/"]),
    div[style*="bottom:0"]:has(a[href*="/reels/"]),
    div[style*="scroll-snap-type"] {
      scroll-snap-type: none !important;
      overflow-y: hidden !important;
    }
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
    var style = document.getElementById('__hide_bottom_nav');
    if (!style && (document.head || document.documentElement)) {
      style = document.createElement('style');
      style.id = '__hide_bottom_nav';
      style.textContent = css;
      (document.head || document.documentElement).appendChild(style);
    }
    var all = document.querySelectorAll('div, nav, footer');
    for (var i = 0; i < all.length; i++) {
      var el = all[i];
      var s = window.getComputedStyle(el);
      if (s.position === 'fixed') {
        var rect = el.getBoundingClientRect();
        if (rect.bottom >= window.innerHeight - 20 && rect.top > window.innerHeight / 2) {
          el.style.setProperty('display', 'none', 'important');
        }
      }
    }
    var backButtons = document.querySelectorAll('[aria-label*="Back" i], [aria-label*="Go back" i], header a[href="/"]');
    for (var b = 0; b < backButtons.length; b++) {
      var btn = backButtons[b];
      var target = btn.closest('button, a, div[role="button"]') || btn;
      target.style.setProperty('display', 'none', 'important');
    }
  }

  function findUsernameOnPage() {
    var input = document.querySelector('input[name="username"], input[id*="username" i], input[aria-label*="username" i]');
    if (input && input.value && input.value.trim().length > 0) {
      return input.value.trim();
    }

    var links = document.querySelectorAll('a[href^="/"]');
    var reserved = ['accounts', 'explore', 'direct', 'stories', 'reels', 'legal', 'about', 'p', 'reel'];
    for (var i = 0; i < links.length; i++) {
      var h = links[i].getAttribute('href') || '';
      var m = h.match(/^\\/([a-zA-Z0-9._]{1,30})\\/?/);
      if (m && !reserved.includes(m[1].toLowerCase())) {
        if (links[i].querySelector('img') || links[i].innerText.toLowerCase().indexOf('profile') !== -1 || links[i].closest('header, form')) {
          return m[1];
        }
      }
    }

    var scripts = document.querySelectorAll('script');
    for (var s = 0; s < scripts.length; s++) {
      var txt = scripts[s].textContent;
      if (txt && txt.indexOf('"username"') !== -1) {
        var mViewer = txt.match(/"viewer":\\s*\\{[^}]*"username":\\s*"([^"]+)"/);
        if (mViewer && mViewer[1]) return mViewer[1];
        var mUname = txt.match(/"username":\\s*"([a-zA-Z0-9._]{1,30})"/);
        if (mUname && mUname[1] && mUname[1] !== 'true' && mUname[1] !== 'false') {
          return mUname[1];
        }
      }
    }

    var imgs = document.querySelectorAll('img[alt*="profile" i]');
    for (var j = 0; j < imgs.length; j++) {
      var parent = imgs[j].closest('div, section, form');
      if (parent) {
        var spans = parent.querySelectorAll('span, h1, h2, div');
        for (var k = 0; k < spans.length; k++) {
          var t = spans[k].innerText.trim();
          if (t.length >= 2 && t.length <= 30 && !['change', 'photo', 'profile', 'accounts', 'instagram'].includes(t.toLowerCase())) {
            return t;
          }
        }
      }
    }

    return null;
  }

  var editCheckTimer = null;
  function detectOwnUsernameFromEdit() {
    if (location.pathname.indexOf('/accounts/edit') === -1) {
      if (editCheckTimer) clearInterval(editCheckTimer);
      return;
    }
    var realName = findUsernameOnPage();
    if (realName) {
      console.log('[profile-detect] Found real username: ' + realName);
      if (editCheckTimer) clearInterval(editCheckTimer);
      if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('onDetectedOwnUsername', realName);
      }
      location.replace('https://www.instagram.com/' + realName + '/');
    }
  }
  detectOwnUsernameFromEdit();
  editCheckTimer = setInterval(detectOwnUsernameFromEdit, 250);

  apply();
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', apply);
  }
  var observer = new MutationObserver(apply);
  observer.observe(document.documentElement, { childList: true, subtree: true });
})();
""";

Future<void> openProfile(BuildContext context, {String? username, AppDatabase? db}) async {
  final isOwnProfile = username == null;
  final ownUsername = isOwnProfile && db != null ? await db.ownUsername() : null;
  final effectiveUsername = username ?? (ownUsername != null && ownUsername.isNotEmpty ? ownUsername : null);
  final initialUrl = effectiveUsername != null
      ? 'https://www.instagram.com/$effectiveUsername/'
      : 'https://www.instagram.com/accounts/edit/';

  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    builder: (_) => ProfileSheet(
      initialUrl: initialUrl,
      title: effectiveUsername != null ? '@$effectiveUsername' : 'My Profile',
      isOwnProfile: isOwnProfile,
      onUsernameDetected: isOwnProfile && db != null ? (name) => db.saveOwnUsername(name) : null,
    ),
  );
}

Future<void> openPostWeb(BuildContext context, String code) async {
  final url = 'https://www.instagram.com/p/$code/';
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    builder: (_) => ProfileSheet(
      initialUrl: url,
      title: 'Post',
    ),
  );
}

class ProfileSheet extends StatefulWidget {
  const ProfileSheet({
    super.key,
    required this.initialUrl,
    required this.title,
    this.isOwnProfile = false,
    this.onUsernameDetected,
  });

  final String initialUrl;
  final String title;
  final bool isOwnProfile;
  final void Function(String username)? onUsernameDetected;

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  late String _currentUrl = widget.initialUrl;
  late String _title = widget.title;
  double _progress = 0;

  static final _ignoredPaths = RegExp(r'^/(accounts|explore|direct|stories|reels)/?');

  void _inspectUrl(WebUri? uri) {
    if (uri == null) return;
    _currentUrl = uri.toString();
    final path = uri.path;
    final match = RegExp(r'^/([a-zA-Z0-9._]+)/?$').firstMatch(path);
    if (match != null && !_ignoredPaths.hasMatch(path)) {
      if (widget.isOwnProfile) {
        final detected = match.group(1)!;
        widget.onUsernameDetected?.call(detected);
        if (mounted) setState(() => _title = '@$detected');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open in Instagram',
            onPressed: () => launchUrl(Uri.parse(_currentUrl), mode: LaunchMode.externalApplication),
          ),
        ],
        bottom: _progress > 0 && _progress < 1
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _progress),
              )
            : null,
      ),
      body: FutureBuilder<InAppWebViewSettings>(
        future: browserSettings(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
            initialSettings: snapshot.data,
            initialUserScripts: UnmodifiableListView([
              UserScript(
                source: _hideNavScript,
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                forMainFrameOnly: true,
              ),
            ]),
            onConsoleMessage: (controller, consoleMessage) {
              debugPrint('[profile-webview] ${consoleMessage.message}');
            },
            onWebViewCreated: (controller) {
              controller.addJavaScriptHandler(
                handlerName: 'onDetectedOwnUsername',
                callback: (args) {
                  if (args.isNotEmpty && args[0] is String && widget.isOwnProfile) {
                    final detected = args[0] as String;
                    if (detected.isNotEmpty) {
                      widget.onUsernameDetected?.call(detected);
                      if (mounted) setState(() => _title = '@$detected');
                    }
                  }
                },
              );
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url;
              if (uri != null && uri.host.contains('instagram.com')) {
                final path = uri.path;
                if (path == '/' || path.isEmpty || path.startsWith('/explore') || path.startsWith('/reels')) {
                  Navigator.of(context).pop();
                  return NavigationActionPolicy.CANCEL;
                }
              }
              return NavigationActionPolicy.ALLOW;
            },
            onProgressChanged: (_, progress) => setState(() => _progress = progress / 100),
            onUpdateVisitedHistory: (_, uri, _) => _inspectUrl(uri),
            onLoadStop: (_, uri) => _inspectUrl(uri),
          );
        },
      ),
    );
  }
}
