import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'browser.dart';

Future<void> openLogin(BuildContext context, [HeadlessInAppWebView? blockedWebView]) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => LoginScreen(blockedWebView: blockedWebView)),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.blockedWebView});

  final HeadlessInAppWebView? blockedWebView;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final Future<InAppWebViewSettings> _settings = browserSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.blockedWebView == null ? 'Log in to Instagram' : 'Instagram needs you'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
        ],
      ),
      body: FutureBuilder(
        future: _settings,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          return InAppWebView(
            headlessWebView: widget.blockedWebView,
            initialSettings: snapshot.data,
            initialUrlRequest: URLRequest(url: WebUri('https://www.instagram.com/accounts/login/')),
          );
        },
      ),
    );
  }
}
