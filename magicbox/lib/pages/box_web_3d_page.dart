import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BoxWeb3DPage extends StatefulWidget {
  const BoxWeb3DPage({super.key});

  @override
  State<BoxWeb3DPage> createState() => _BoxWeb3DPageState();
}

class _BoxWeb3DPageState extends State<BoxWeb3DPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadFlutterAsset('assets/web/three_box.html'); // 放置你的 three.js HTML 文件
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("3D 魔盒体验")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
