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
import 'controllers/box_controller.dart';
import 'controllers/item_controller.dart';
import 'controllers/repository_controller.dart';
import 'models/user_model.dart';
import 'services/auth_service.dart';
import 'services/database_service.dart';
import 'pages/community_page.dart';
import 'pages/channel_page.dart';
import 'controllers/community_controller.dart';
import 'controllers/follow_controller.dart';

void main() async {
  try {
    debugPrint('开始初始化应用程序...');
    WidgetsFlutterBinding.ensureInitialized();

    await Future.delayed(const Duration(milliseconds: 500)); // ⬅️ 添加这一行

    // 初始化 sqflite
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        try {
          debugPrint('初始化 sqflite_ffi...');
          sqfliteFfiInit();
          databaseFactory = databaseFactoryFfi;
          debugPrint('sqflite_ffi 初始化完成');
        } catch (e) {
          debugPrint('sqflite_ffi 初始化失败: $e');
          debugPrint('错误堆栈: ${StackTrace.current}');
          rethrow;
        }
      }
    }

    // 初始化数据库服务
    debugPrint('初始化数据库服务...');
    final dbService = DatabaseService();
    await Get.put(dbService, permanent: true);
    debugPrint('数据库服务初始化完成');

    try {
      // 初始化数据库
      debugPrint('初始化数据库...');
      await dbService.reinitializeDatabase();
      debugPrint('数据库初始化完成');
    } catch (e) {
      debugPrint('数据库初始化失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    try {
      debugPrint('初始化控制器...');

      // 首先初始化 AuthController，因为其他控制器可能依赖它
      debugPrint('初始化 AuthController...');
      await Get.put(AuthController(), permanent: true);
      debugPrint('AuthController 初始化完成');

      // 初始化 BoxController，因为 RepositoryController 依赖它
      debugPrint('初始化 BoxController...');
      await Get.put(BoxController(), permanent: true);
      debugPrint('BoxController 初始化完成');

      // 初始化 ItemController，因为 RepositoryController 依赖它
      debugPrint('初始化 ItemController...');
      await Get.put(ItemController(), permanent: true);
      debugPrint('ItemController 初始化完成');

      // 然后初始化其他控制器
      debugPrint('初始化 RepositoryController...');
      await Get.put(RepositoryController(), permanent: true);
      debugPrint('RepositoryController 初始化完成');

      debugPrint('初始化 SubscriptionController...');
      await Get.put(SubscriptionController(), permanent: true);
      debugPrint('SubscriptionController 初始化完成');

      // debugPrint('初始化 FollowController...');
      // await Get.put(FollowController(), permanent: true);
      // debugPrint('FollowController 初始化完成');

      debugPrint('初始化 UserModel...');
      await Get.put(
          UserModel(
            id: '1',
            username: 'test',
            email: 'test@example.com',
            password: dbService.hashPassword('123456'),
            type: UserType.PERSONAL,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
          ),
          permanent: true);
      debugPrint('UserModel 初始化完成');

      debugPrint('初始化 CommunityController...');
      await Get.put(CommunityController(), permanent: true);
      debugPrint('CommunityController 初始化完成');

      debugPrint('所有控制器初始化完成');
    } catch (e) {
      debugPrint('控制器初始化失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    debugPrint('启动应用程序...');
    runApp(const MagicBoxApp());
  } catch (e) {
    debugPrint('应用初始化失败: $e');
    debugPrint('错误堆栈: ${StackTrace.current}');
    rethrow;
  }
}

// 主应用入口
class MagicBoxApp extends StatelessWidget {
  const MagicBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('构建应用程序...');
    return GetMaterialApp(
      title: '魔盒',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/login',
      onInit: () {
        debugPrint('应用程序初始化完成');
      },
      onReady: () {
        debugPrint('应用程序准备就绪');
      },
      onDispose: () {
        debugPrint('应用程序销毁');
      },
      getPages: [
        GetPage(
          name: '/login',
          page: () {
            debugPrint('加载登录页面');
            return LoginPage();
          },
        ),
        GetPage(
          name: '/home',
          page: () {
            debugPrint('加载主页');
            if (!Get.isRegistered<BoxController>()) {
              debugPrint('BoxController 未注册，重新初始化');
              Get.put(BoxController(), permanent: true);
            }
            return HomePage();
          },
        ),
        GetPage(
          name: '/community',
          page: () {
            debugPrint('加载社区页面');
            return CommunityPage();
          },
        ),
        GetPage(
          name: '/channel',
          page: () {
            debugPrint('加载频道页面');
            return ChannelPage(channel: Get.arguments);
          },
        ),
        GetPage(
          name: '/create_box',
          page: () {
            debugPrint('加载创建盒子页面');
            return CreateBoxPage();
          },
        ),
        GetPage(
          name: '/box_detail',
          page: () {
            debugPrint('加载盒子详情页面');
            return BoxDetailPage(box: Get.arguments);
          },
        ),
        GetPage(
          name: '/statistics',
          page: () {
            debugPrint('加载统计页面');
            return StatisticsPage();
          },
        ),
        GetPage(
          name: '/help',
          page: () {
            debugPrint('加载帮助页面');
            return HelpPage();
          },
        ),
        GetPage(
          name: '/settings',
          page: () {
            debugPrint('加载设置页面');
            return SettingsPage();
          },
        ),
        GetPage(
          name: '/subscription',
          page: () {
            debugPrint('加载订阅页面');
            return SubscriptionPage();
          },
        ),
      ],
    );
  }
}
