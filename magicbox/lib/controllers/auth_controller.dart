// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import '../models/subscription_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../controllers/subscription_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../controllers/repository_controller.dart';
import '../controllers/box_controller.dart';
import '../controllers/item_controller.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  late final AuthService _authService;
  late final SubscriptionController _subscriptionController;
  final _currentUser = Rxn<UserModel>();
  final _isLoading = false.obs;

  UserModel? get currentUser => _currentUser.value;
  Rx<UserModel?> get currentUserRx => _currentUser;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.put(AuthService());
    _subscriptionController = Get.put(SubscriptionController());
    _loadLoginState(); // 在控制器初始化时加载登录状态
  }

  Future<void> _loadCurrentUser() async {
    try {
      debugPrint('开始加载当前用户信息...');
      final user = await _authService.getCurrentUser();
      debugPrint('获取到用户信息: ${user?.username}');
      _currentUser.value = user;
    } catch (e) {
      debugPrint('加载当前用户失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
    UserType type = UserType.PERSONAL,
  }) async {
    _isLoading.value = true;
    try {
      final user = await _authService.register(
        username: username,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        type: type,
      );
      _currentUser.value = user;
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('注册失败', e.toString());
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> login(String username, String password) async {
    try {
      debugPrint('开始登录流程');
      debugPrint('用户名: $username, 密码: $password');
      _isLoading.value = true;

      // 使用 AuthService 进行登录验证
      final user = await _authService.login(username, password);
      _currentUser.value = user;
      debugPrint('用户登录成功: ${_currentUser.value?.username}');

      // 加载用户订阅信息
      await _subscriptionController.loadSubscription();
      debugPrint('用户订阅信息加载完成');

      // 保存登录状态
      await _saveLoginState();
      debugPrint('登录状态保存完成');

      // 加载用户相关数据
      await _loadUserData();
      debugPrint('用户数据加载完成');

      Get.offAllNamed('/home');
    } catch (e) {
      debugPrint('登录失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
      Get.snackbar(
        '登录失败',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      debugPrint('开始加载用户数据');
      if (_currentUser.value == null) {
        debugPrint('当前用户为空，无法加载数据');
        return;
      }

      // 加载用户仓库
      await Get.find<RepositoryController>().loadRepositories();
      debugPrint('用户仓库加载完成');

      // 加载用户盒子
      await Get.find<BoxController>().loadBoxes();
      debugPrint('用户盒子加载完成');

      // 加载用户项目
      await Get.find<ItemController>().loadItems();
      debugPrint('用户项目加载完成');
    } catch (e) {
      debugPrint('加载用户数据失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
    }
  }

  Future<void> _saveLoginState() async {
    try {
      debugPrint('开始保存登录状态');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _currentUser.value!.id.toString());
      await prefs.setString('username', _currentUser.value!.username);
      debugPrint('登录状态保存成功');
    } catch (e) {
      debugPrint('保存登录状态失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
    }
  }

  Future<void> _loadLoginState() async {
    try {
      debugPrint('开始加载登录状态');
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      final username = prefs.getString('username');

      if (userId != null && username != null) {
        debugPrint('找到保存的登录信息，开始加载用户数据');
        // 从数据库加载用户信息
        final db = await DatabaseService().database;
        final List<Map<String, dynamic>> maps = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [userId],
        );

        if (maps.isNotEmpty) {
          _currentUser.value = UserModel.fromMap(maps.first);
          debugPrint('用户信息加载成功: ${_currentUser.value?.username}');

          // 加载当前用户详细信息
          await _loadCurrentUser();
          debugPrint('当前用户详细信息加载完成');

          // 初始化用户等级
          await _initLevels();
          debugPrint('用户等级初始化完成');

          // 加载用户订阅信息
          await _subscriptionController.loadSubscription();
          debugPrint('用户订阅信息加载完成');

          // 加载用户相关数据
          await _loadUserData();
          debugPrint('用户数据加载完成');
        } else {
          debugPrint('未找到用户信息，清除登录状态');
          await logout();
        }
      } else {
        debugPrint('未找到保存的登录信息');
      }
    } catch (e) {
      debugPrint('加载登录状态失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
      await logout();
    }
  }

  Future<void> logout() async {
    _isLoading.value = true;
    try {
      await _authService.logout();
      _currentUser.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('退出失败', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProfile(UserModel user) async {
    _isLoading.value = true;
    try {
      await _authService.updateProfile(user);
      _currentUser.value = user;
      Get.snackbar('成功', '个人信息已更新');
    } catch (e) {
      Get.snackbar('更新失败', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<UserModel?> getUserByUsername(String username) async {
    try {
      return await _authService.getUserByUsername(username);
    } catch (e) {
      print('获取用户信息失败: $e');
      return null;
    }
  }

  Future<void> _initLevels() async {
    try {
      debugPrint('开始初始化用户等级系统');
      final currentUser = _currentUser.value;
      if (currentUser == null) {
        debugPrint('当前用户为空，无法初始化等级系统');
        return;
      }

      // 初始化用户等级
      if (currentUser.level == 0) {
        debugPrint('用户等级为0，设置为初始等级1');
        currentUser.level = 1;
        currentUser.experience = 0;
        await updateProfile(currentUser);
        debugPrint('用户等级初始化完成');
      }

      // 初始化订阅信息
      debugPrint('开始初始化订阅信息');
      final subscription = _subscriptionController.subscription;
      if (subscription == null) {
        debugPrint('未找到订阅信息，创建默认订阅');
        await _subscriptionController.updateSubscription(
          type: SubscriptionType.FREE,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 30)),
          expiryText: '30天后到期', // 添加到期文本
        );
        debugPrint('默认订阅创建完成');
      }
      debugPrint('订阅信息初始化完成');
    } catch (e) {
      debugPrint('初始化用户等级系统失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
    }
  }
}
