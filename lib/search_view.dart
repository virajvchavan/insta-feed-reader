import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'browser.dart';
import 'profile_sheet.dart';

const _cleanSearchScript = """
(function() {
  function apply() {
    if (location.pathname.indexOf('/explore') !== -1) {
      var articles = document.querySelectorAll('article, main div[style*="grid"]');
      for (var a = 0; a < articles.length; a++) {
        articles[a].style.setProperty('display', 'none', 'important');
      }
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

    var input = document.querySelector('input[placeholder*="Search" i], input[type="search"], input[type="text"]');
    if (input && document.activeElement !== input) {
      input.focus();
    }
  }
  apply();
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', apply);
  }
  var observer = new MutationObserver(apply);
  observer.observe(document.documentElement, { childList: true, subtree: true });
})();
""";

class SearchView extends StatefulWidget {
  const SearchView({super.key, this.isActive = false});

  final bool isActive;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  InAppWebViewController? _controller;

  @override
  void didUpdateWidget(covariant SearchView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller?.evaluateJavascript(source: """
        var input = document.querySelector('input[placeholder*="Search" i], input[type="search"], input[type="text"]');
        if (input) input.focus();
      """);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<InAppWebViewSettings>(
      future: browserSettings(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        return InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri('https://www.instagram.com/explore/search/')),
          initialSettings: snapshot.data,
          initialUserScripts: UnmodifiableListView([
            UserScript(
              source: _cleanSearchScript,
              injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
              forMainFrameOnly: true,
            ),
          ]),
          onWebViewCreated: (c) => _controller = c,
          onUpdateVisitedHistory: (controller, uri, _) {
            if (uri != null && uri.host.contains('instagram.com')) {
              final path = uri.path;
              final match = RegExp(r'^/([a-zA-Z0-9._]+)/?$').firstMatch(path);
              if (match != null && !RegExp(r'^(explore|reels|direct|stories|accounts)').hasMatch(match.group(1)!)) {
                openProfile(context, username: match.group(1)!);
                controller.loadUrl(urlRequest: URLRequest(url: WebUri('https://www.instagram.com/explore/search/')));
              }
            }
          },
          shouldOverrideUrlLoading: (controller, action) async {
            final uri = action.request.url;
            if (uri != null && uri.host.contains('instagram.com')) {
              final path = uri.path;
              final match = RegExp(r'^/([a-zA-Z0-9._]+)/?$').firstMatch(path);
              if (match != null && !RegExp(r'^(explore|reels|direct|stories|accounts)').hasMatch(match.group(1)!)) {
                openProfile(context, username: match.group(1)!);
                return NavigationActionPolicy.CANCEL;
              }
              if (path == '/' || path.isEmpty || path.startsWith('/reels')) {
                return NavigationActionPolicy.CANCEL;
              }
            }
            return NavigationActionPolicy.ALLOW;
          },
        );
      },
    );
  }
}
