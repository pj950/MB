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
import 'pages/statistics_page.dart';
import 'pages/help_page.dart';
import 'pages/settings_page.dart';
import 'controllers/auth_controller.dart';
import 'controllers/subscription_controller.dart';
import 'pages/subscription_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Get.put(AuthController());
  Get.put(SubscriptionController());

  runApp(const MagicBoxApp());
}

// 主应用入口
class MagicBoxApp extends StatelessWidget {
  const MagicBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        GetPage(name: '/statistics', page: () => StatisticsPage()),
        GetPage(name: '/help', page: () => HelpPage()),
        GetPage(name: '/settings', page: () => SettingsPage()),
        GetPage(name: '/subscription', page: () => SubscriptionPage()),
      ],
    );
  }
}
