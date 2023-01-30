import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyDashboard extends StatefulWidget {
  const MyDashboard({super.key});
  @override
  State<StatefulWidget> createState() => _MyDashboardState();
}
class _MyDashboardState extends State<MyDashboard> {
  var loadingPercentage = 0;
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('http://127.0.0.1:9090/ui'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DASHBOARD')),
      body: WebViewWidget(controller: controller),
    );
  }
}
