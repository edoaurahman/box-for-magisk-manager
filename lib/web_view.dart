import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyDashboard extends StatefulWidget {
  final String url,pageName;
  const MyDashboard(this.url,this.pageName, {super.key});
  @override
  State<StatefulWidget> createState() => _MyDashboardState(url,pageName);
}
class _MyDashboardState extends State<MyDashboard> {
  late final WebViewController controller;
  final String url,pageName;
  _MyDashboardState(this.url,this.pageName);
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pageName)),
      body: WebViewWidget(controller: controller),
    );
  }
}
