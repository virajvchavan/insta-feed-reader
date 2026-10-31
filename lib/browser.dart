import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

final instagramHome = WebUri('https://www.instagram.com/');

/// Starts from the WebView's own agent so the OS and engine versions stay true
/// to the device, then removes the parts that mark it as an embedded WebView.
Future<String> browserUserAgent() async {
  final webViewAgent = await InAppWebViewController.getDefaultUserAgent();
  if (Platform.isAndroid) {
    return webViewAgent.replaceAll('; wv', '').replaceAll(RegExp(r'Version/[\d.]+ '), '');
  }
  if (webViewAgent.contains('Safari/')) return webViewAgent;
  final osVersion = RegExp(r'\d+\.\d+(\.\d+)?').firstMatch(Platform.operatingSystemVersion)?.group(0) ??
      RegExp(r'OS (\d+_\d+)').firstMatch(webViewAgent)?.group(1)?.replaceAll('_', '.');
  return '${webViewAgent.replaceFirst('Mobile/', 'Version/$osVersion Mobile/')} Safari/604.1';
}

Future<InAppWebViewSettings> browserSettings() async {
  return InAppWebViewSettings(
    userAgent: await browserUserAgent(),
    requestedWithHeaderOriginAllowList: Platform.isAndroid ? <String>{} : null,
    mediaPlaybackRequiresUserGesture: true,
    isInspectable: kDebugMode,
  );
}

Future<bool> hasInstagramSession() async {
  final cookie = await CookieManager.instance().getCookie(url: instagramHome, name: 'sessionid');
  return cookie != null && '${cookie.value}'.isNotEmpty;
}
