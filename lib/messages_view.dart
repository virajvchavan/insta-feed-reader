import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'browser.dart';

const _messagesScript = """
(function() {
  function checkUrl() {
    var p = location.pathname;
    if (p === '/' || p === '' || p.indexOf('/explore') === 0 || p.indexOf('/reels') === 0) {
      location.replace('https://www.instagram.com/direct/inbox/');
    }
  }
  checkUrl();
  window.addEventListener('popstate', checkUrl);
  setInterval(checkUrl, 400);

  document.addEventListener('click', function(e) {
    var p = location.pathname;
    if (p.indexOf('/direct') === -1) {
      var backBtn = e.target.closest('[aria-label*="Back" i], [aria-label*="back" i], [aria-label*="Go back" i], header a, div[role="banner"] a');
      if (backBtn) {
        e.preventDefault();
        e.stopPropagation();
        history.back();
      }
    }
  }, true);

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
    var path = location.pathname;
    var isReelPage = path.indexOf('/reel') !== -1;
    var isPostPage = path.indexOf('/p/') !== -1;

    if (!isReelPage && !isPostPage) return;

    var target = e.target;
    var inComments = target && target.closest('div[role="dialog"], textarea, input, form, [aria-label*="comment" i]');
    if (inComments) return;

    if (e.touches && e.touches.length === 1) {
      var dy = Math.abs(e.touches[0].clientY - startY);
      var dx = Math.abs(e.touches[0].clientX - startX);

      if (dy > 4 && dy > dx) {
        if (isReelPage) {
          isSwiping = true;
          e.preventDefault();
          e.stopPropagation();
          return;
        }
        var onVideo = !!(target && (target.tagName === 'VIDEO' || target.closest('video') || target.closest('div:has(> video)')));
        if (onVideo) {
          isSwiping = true;
          e.preventDefault();
          e.stopPropagation();
        }
      }
    }
  }, { passive: false, capture: true });

  window.addEventListener('touchend', function(e) {
    if (isSwiping) {
      isSwiping = false;
      var path = location.pathname;
      if (path.indexOf('/reel') !== -1) {
        e.preventDefault();
        e.stopPropagation();
      }
    }
  }, { passive: false, capture: true });

  window.addEventListener('wheel', function(e) {
    if (location.pathname.indexOf('/reel') !== -1) {
      var inComments = e.target && e.target.closest('div[role="dialog"], textarea, input, form');
      if (!inComments) {
        e.preventDefault();
        e.stopPropagation();
      }
    }
  }, { passive: false, capture: true });

  var css = `
    a[href="/"],
    a[href="https://www.instagram.com/"],
    a[href="https://www.instagram.com"],
    header a[href="/"],
    div[role="banner"] a[href="/"],
    nav:has(a[href*="/reels/"]),
    div[role="navigation"]:has(a[href*="/reels/"]),
    div[style*="bottom: 0"]:has(a[href*="/reels/"]),
    div[style*="bottom:0"]:has(a[href*="/reels/"]),
    div[style*="scroll-snap-type"] {
      scroll-snap-type: none !important;
      overflow-y: hidden !important;
    }
  `;

  function apply() {
    var style = document.getElementById('__messages_view_css');
    if (!style && (document.head || document.documentElement)) {
      style = document.createElement('style');
      style.id = '__messages_view_css';
      style.textContent = css;
      (document.head || document.documentElement).appendChild(style);
    }

    var p = location.pathname;
    var isThread = p.indexOf('/direct/t/') !== -1;
    var isPostOrReel = p.indexOf('/p/') !== -1 || p.indexOf('/reel') !== -1;
    var isAllMessages = !isThread && !isPostOrReel;

    var homeLinks = document.querySelectorAll('a[href="/"], a[href="https://www.instagram.com/"], a[href="https://www.instagram.com"], header a[href="/"], div[role="banner"] a[href="/"]');
    for (var i = 0; i < homeLinks.length; i++) {
      homeLinks[i].style.setProperty('display', 'none', 'important');
    }

    if (isAllMessages) {
      // 1. Hide by aria-label
      var ariaEls = document.querySelectorAll('[aria-label*="Back" i], [aria-label*="back" i], [aria-label*="Go back" i], [aria-label*="Instagram" i]');
      for (var a = 0; a < ariaEls.length; a++) {
        var aTarget = ariaEls[a].closest('button, a, div[role="button"]') || ariaEls[a];
        aTarget.style.setProperty('display', 'none', 'important');
        aTarget.style.setProperty('visibility', 'hidden', 'important');
        aTarget.style.setProperty('opacity', '0', 'important');
        aTarget.style.setProperty('pointer-events', 'none', 'important');
      }

      // 2. Hide any SVG in the top-left corner (the back icon)
      var svgs = document.querySelectorAll('svg');
      for (var s = 0; s < svgs.length; s++) {
        var svg = svgs[s];
        var sr = svg.getBoundingClientRect();
        if (sr.top >= 0 && sr.top < 65 && sr.left >= 0 && sr.left < 85 && sr.width > 0) {
          var clickable = svg.closest('button, a, div[role="button"]') || svg.parentElement || svg;
          clickable.style.setProperty('display', 'none', 'important');
          clickable.style.setProperty('visibility', 'hidden', 'important');
          clickable.style.setProperty('opacity', '0', 'important');
          clickable.style.setProperty('pointer-events', 'none', 'important');
        }
      }

      // 3. Hide any clickable element in top-left corner that isn't the username title
      var clickables = document.querySelectorAll('button, a, div[role="button"]');
      for (var c = 0; c < clickables.length; c++) {
        var el = clickables[c];
        var cr = el.getBoundingClientRect();
        if (cr.top >= 0 && cr.top < 65 && cr.left >= 0 && cr.left < 85 && cr.width > 0 && cr.width < 120) {
          if (el.innerText.trim() === '' || (el.getAttribute('aria-label') || '').toLowerCase().indexOf('back') !== -1) {
            el.style.setProperty('display', 'none', 'important');
            el.style.setProperty('visibility', 'hidden', 'important');
            el.style.setProperty('opacity', '0', 'important');
            el.style.setProperty('pointer-events', 'none', 'important');
          }
        }
      }
    }

    var links = document.querySelectorAll('a[href*="/reels/"], a[href*="/explore/"]');
    for (var j = 0; j < links.length; j++) {
      var parent = links[j].closest('nav') || links[j].closest('div[role="navigation"]') || links[j].parentElement;
      while (parent && parent !== document.body) {
        var ps = window.getComputedStyle(parent);
        if (ps.position === 'fixed') {
          var bRect = parent.getBoundingClientRect();
          if (bRect.bottom >= window.innerHeight - 20 && bRect.top > window.innerHeight / 2) {
            parent.style.setProperty('display', 'none', 'important');
            break;
          }
        }
        parent = parent.parentElement;
      }
    }

    if (location.pathname.indexOf('/reel') !== -1) {
      var containers = document.querySelectorAll('div, main, section');
      for (var cIdx = 0; cIdx < containers.length; cIdx++) {
        var container = containers[cIdx];
        if (container.closest('div[role="dialog"]')) continue;
        var cs = window.getComputedStyle(container);
        if (cs.scrollSnapType && cs.scrollSnapType !== 'none') {
          container.style.setProperty('scroll-snap-type', 'none', 'important');
          container.style.setProperty('overflow-y', 'hidden', 'important');
        }
      }
    }
  }

  apply();
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', apply);
  }
  var observer = new MutationObserver(apply);
  observer.observe(document.documentElement, { childList: true, subtree: true });
  setInterval(apply, 200);
})();
""";

class MessagesView extends StatefulWidget {
  const MessagesView({super.key});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> {
  late final Future<InAppWebViewSettings> _settings = browserSettings();

  void _redirectIfLeavingMessages(InAppWebViewController controller, WebUri? uri) {
    if (uri == null) return;
    final path = uri.path;
    if (path == '/' || path.isEmpty || path.startsWith('/explore') || path.startsWith('/reels')) {
      controller.loadUrl(urlRequest: URLRequest(url: WebUri('https://www.instagram.com/direct/inbox/')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: FutureBuilder(
        future: _settings,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return InAppWebView(
            initialSettings: snapshot.data,
            initialUrlRequest: URLRequest(url: WebUri('https://www.instagram.com/direct/inbox/')),
            initialUserScripts: UnmodifiableListView([
              UserScript(
                source: _messagesScript,
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                forMainFrameOnly: true,
              ),
            ]),
            onConsoleMessage: (controller, consoleMessage) {
              debugPrint('[messages-webview] ${consoleMessage.message}');
            },
            onWebViewCreated: (controller) {
              controller.getUrl().then((uri) => _redirectIfLeavingMessages(controller, uri));
            },
            onLoadStop: (controller, uri) async {
              _redirectIfLeavingMessages(controller, uri);
            },
            onUpdateVisitedHistory: (controller, uri, isReload) {
              _redirectIfLeavingMessages(controller, uri);
            },
            shouldOverrideUrlLoading: (controller, action) async {
              final uri = action.request.url;
              if (uri == null) return NavigationActionPolicy.ALLOW;

              final host = uri.host.toLowerCase();
              final isMetaService = host.contains('instagram.com') ||
                  host.contains('facebook.com') ||
                  host.contains('meta.com') ||
                  host.contains('fbcdn.net') ||
                  host.contains('cdninstagram.com');

              if (host.contains('instagram.com')) {
                final path = uri.path;
                if (path == '/' || path.isEmpty || path.startsWith('/explore') || path.startsWith('/reels')) {
                  controller.loadUrl(urlRequest: URLRequest(url: WebUri('https://www.instagram.com/direct/inbox/')));
                  return NavigationActionPolicy.CANCEL;
                }
              }

              if (!isMetaService && (action.hasGesture ?? false)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
          );
        },
      ),
    );
  }
}
