import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import 'browser.dart';

const _notificationsScript = """
(function() {
  function ensureNotificationsOpen() {
    var heart = document.querySelector('[aria-label*="Activity" i], [aria-label*="Notification" i], a[href*="/activity"]');
    if (heart) {
      var isPanelOpen = document.querySelector('div[role="dialog"], [aria-label*="Notification" i]:not(a):not(button)');
      if (!isPanelOpen) {
        heart.click();
      }
    }
  }

  var css = `
    div[style*="bottom: 0"]:has(a[href*="/reels/"]),
    div[style*="bottom:0"]:has(a[href*="/reels/"]),
    header a[href="/"],
    div[role="banner"] a[href="/"] {
      display: none !important;
    }
  `;

  function apply() {
    var style = document.getElementById('__notifications_clean_css');
    if (!style && (document.head || document.documentElement)) {
      style = document.createElement('style');
      style.id = '__notifications_clean_css';
      style.textContent = css;
      (document.head || document.documentElement).appendChild(style);
    }
    ensureNotificationsOpen();
  }

  apply();
  document.addEventListener('DOMContentLoaded', apply);
  window.addEventListener('load', apply);

  var observer = new MutationObserver(apply);
  if (document.documentElement) {
    observer.observe(document.documentElement, { childList: true, subtree: true });
  }
})();
""";

Future<void> openNotifications(BuildContext context) async {
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    builder: (_) => const NotificationsSheet(),
  );
}

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  static const _initialUrl = 'https://www.instagram.com/accounts/activity/';
  String _currentUrl = _initialUrl;
  double _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
            initialUrlRequest: URLRequest(
              url: WebUri(_initialUrl),
              headers: {
                'Referer': 'https://www.instagram.com/',
              },
            ),
            initialSettings: snapshot.data,
            initialUserScripts: UnmodifiableListView([
              UserScript(
                source: _notificationsScript,
                injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                forMainFrameOnly: true,
              ),
            ]),
            onProgressChanged: (_, progress) {
              if (mounted) setState(() => _progress = progress / 100);
            },
            onUpdateVisitedHistory: (_, uri, _) {
              if (uri != null) _currentUrl = uri.toString();
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url;
              if (uri != null && uri.host.contains('instagram.com')) {
                final path = uri.path;
                if (path == '/' || path.isEmpty) {
                  Navigator.of(context).pop();
                  return NavigationActionPolicy.CANCEL;
                }
              }
              return NavigationActionPolicy.ALLOW;
            },
          );
        },
      ),
    );
  }
}
