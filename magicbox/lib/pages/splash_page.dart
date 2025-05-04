// lib/pages/splash_page.dart
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('魔盒App加载中...', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
