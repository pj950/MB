import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ThreeBoxWebViewPage extends StatefulWidget {
  const ThreeBoxWebViewPage({super.key});

  @override
  State<ThreeBoxWebViewPage> createState() => _ThreeBoxWebViewPageState();
}

class _ThreeBoxWebViewPageState extends State<ThreeBoxWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/html/three_box.html');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('3D 盒子视图')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
