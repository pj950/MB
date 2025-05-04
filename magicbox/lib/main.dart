// lib/main.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pages/db_test_page.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/create_box_page.dart';
import 'pages/box_detail_page.dart';
import 'controllers/auth_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MagicBoxApp());
}

// 主应用入口
class MagicBoxApp extends StatelessWidget {
  const MagicBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 初始化AuthController，确保登录状态
    Get.put(AuthController());

    return GetMaterialApp(
      title: '魔盒',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      initialRoute: '/home',
      getPages: [
        GetPage(name: '/db_test', page: () => const DBTestPage()),
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/create_box', page: () => const CreateBoxPage()),
        GetPage(
            name: '/box_detail', page: () => BoxDetailPage(box: Get.arguments)),
      ],
    );
  }
}
