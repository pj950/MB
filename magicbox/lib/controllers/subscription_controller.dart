import 'package:get/get.dart';
import '../models/subscription_model.dart';
import '../services/database_service.dart';
import 'auth_controller.dart';
import 'package:flutter/foundation.dart';

class SubscriptionController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  // 可观察的订阅状态
  final Rx<SubscriptionModel?> _subscription = Rx<SubscriptionModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isUpgrading = false.obs;

  // 获取当前订阅
  SubscriptionModel? get subscription => _subscription.value;
  SubscriptionModel? get currentSubscription => _subscription.value;

  @override
  void onInit() async {
    super.onInit();
    try {
      debugPrint('初始化 SubscriptionController...');
      
      // 确保数据库服务已初始化
      if (!Get.isRegistered<DatabaseService>()) {
        debugPrint('注册 DatabaseService...');
        Get.put(DatabaseService());
      }
      
      // 确保订阅表已创建
      debugPrint('创建订阅表...');
      await _databaseService.createSubscriptionTable();
      
      // 加载订阅信息
      debugPrint('加载订阅信息...');
      await loadSubscription();
      
      debugPrint('SubscriptionController 初始化完成');
    } catch (e) {
      debugPrint('SubscriptionController 初始化失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
    }
  }

  // 加载订阅信息
  Future<void> loadSubscription() async {
    try {
      isLoading.value = true;
      final userId = Get.find<AuthController>().currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      // 获取订阅信息
      var subscription = await _databaseService.getSubscription(userId.toString());
      
      // 如果没有订阅信息，创建默认的免费订阅
      if (subscription == null) {
        debugPrint('未找到订阅信息，创建默认免费订阅');
        subscription = SubscriptionModel(
          userId: userId.toString(),
          type: SubscriptionType.FREE,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 36500)), // 100年有效期
          isActive: true,
          maxRepositories: 3,
          maxBoxesPerRepository: 10,
          hasAdvancedProperties: false,
          hasWatermarkProtection: false,
          maxFamilyMembers: 1,
        );
        
        // 保存到数据库
        await _databaseService.createSubscription(subscription);
        debugPrint('默认免费订阅创建成功');
      }
      
      _subscription.value = subscription;
      debugPrint('订阅信息加载完成: ${subscription.type}');
    } catch (e) {
      debugPrint('加载订阅信息失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
      Get.snackbar(
        '错误',
        '加载订阅信息失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 升级订阅
  Future<void> upgradeSubscription(SubscriptionType newType) async {
    try {
      isUpgrading.value = true;
      final userId = Get.find<AuthController>().currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      final currentSubscription = _subscription.value;
      if (currentSubscription == null) {
        throw Exception('未找到当前订阅信息');
      }

      // 创建新订阅
      final newSubscription = SubscriptionModel(
        userId: userId.toString(),
        type: newType,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      // 保存到数据库
      await _databaseService.updateSubscription(newSubscription);
      _subscription.value = newSubscription;

      Get.snackbar(
        '成功',
        '订阅已升级到${getSubscriptionTypeName(newType)}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '升级订阅失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpgrading.value = false;
    }
  }

  // 续订订阅
  Future<void> renewSubscription() async {
    try {
      isUpgrading.value = true;
      final currentSubscription = _subscription.value;
      if (currentSubscription == null) {
        throw Exception('未找到当前订阅信息');
      }

      // 更新结束日期
      final renewedSubscription = currentSubscription.copyWith(
        endDate: DateTime.now().add(const Duration(days: 30)),
      );

      // 保存到数据库
      await _databaseService.updateSubscription(renewedSubscription);
      _subscription.value = renewedSubscription;

      Get.snackbar(
        '成功',
        '订阅已续订，有效期延长30天',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '续订订阅失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpgrading.value = false;
    }
  }

  // 添加家庭成员
  Future<void> addFamilyMember(String memberId) async {
    try {
      final currentSubscription = _subscription.value;
      if (currentSubscription == null) {
        throw Exception('未找到当前订阅信息');
      }

      if (currentSubscription.type != SubscriptionType.FAMILY) {
        throw Exception('只有家庭版订阅才能添加家庭成员');
      }

      if (!currentSubscription.canAddFamilyMember()) {
        throw Exception('已达到最大家庭成员数量限制');
      }

      final memberIds = currentSubscription.familyMemberIds?.split(',') ?? [];
      memberIds.add(memberId);
      final updatedMemberIds = memberIds.join(',');
      
      final updatedSubscription = currentSubscription.copyWith(
        familyMemberIds: updatedMemberIds,
      );

      await _databaseService.updateSubscription(updatedSubscription);
      _subscription.value = updatedSubscription;

      Get.snackbar(
        '成功',
        '已添加家庭成员',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '添加家庭成员失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 移除家庭成员
  Future<void> removeFamilyMember(String memberId) async {
    try {
      final currentSubscription = _subscription.value;
      if (currentSubscription == null) {
        throw Exception('未找到当前订阅信息');
      }

      final memberIds = currentSubscription.familyMemberIds?.split(',') ?? [];
      final updatedMemberIds = memberIds.where((id) => id != memberId).join(',');
      
      final updatedSubscription = currentSubscription.copyWith(
        familyMemberIds: updatedMemberIds,
      );

      await _databaseService.updateSubscription(updatedSubscription);
      _subscription.value = updatedSubscription;

      Get.snackbar(
        '成功',
        '已移除家庭成员',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '移除家庭成员失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 检查订阅是否有效
  bool isSubscriptionValid() {
    final currentSubscription = _subscription.value;
    if (currentSubscription == null) return false;
    return currentSubscription.isActive && !currentSubscription.isExpired();
  }

  // 获取订阅类型名称
  String getSubscriptionTypeName(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.FREE:
        return '免费版';
      case SubscriptionType.PERSONAL:
        return '个人版';
      case SubscriptionType.FAMILY:
        return '家庭版';
    }
  }

  // 获取订阅价格
  double getSubscriptionPrice(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.FREE:
        return 0;
      case SubscriptionType.PERSONAL:
        return 5;
      case SubscriptionType.FAMILY:
        return 15;
    }
  }

  // 获取订阅权益描述
  Map<String, dynamic> getSubscriptionBenefits(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.FREE:
        return {
          'maxRepositories': 1,
          'maxBoxesPerRepository': 10,
          'hasAdvancedProperties': false,
          'hasWatermarkProtection': false,
          'maxFamilyMembers': 0,
        };
      case SubscriptionType.PERSONAL:
        return {
          'maxRepositories': 3,
          'maxBoxesPerRepository': -1,
          'hasAdvancedProperties': true,
          'hasWatermarkProtection': true,
          'maxFamilyMembers': 0,
        };
      case SubscriptionType.FAMILY:
        return {
          'maxRepositories': 5,
          'maxBoxesPerRepository': -1,
          'hasAdvancedProperties': true,
          'hasWatermarkProtection': true,
          'maxFamilyMembers': 5,
        };
    }
  }

  // 创建免费订阅
  Future<void> createFreeSubscription() async {
    try {
      final userId = Get.find<AuthController>().currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      final subscription = SubscriptionModel(
        userId: userId.toString(),
        type: SubscriptionType.FREE,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 365)), // 免费订阅一年有效期
      );

      await _databaseService.createSubscription(subscription);
      _subscription.value = subscription;
    } catch (e) {
      print('创建免费订阅失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
  }

  // 更新订阅信息
  Future<void> updateSubscription({
    required SubscriptionType type,
    required DateTime startDate,
    required DateTime endDate,
    String? expiryText,
  }) async {
    try {
      isUpgrading.value = true;
      final userId = Get.find<AuthController>().currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      // 创建新订阅
      final newSubscription = SubscriptionModel(
        userId: userId.toString(),
        type: type,
        startDate: startDate,
        endDate: endDate,
        expiryText: expiryText,
      );

      // 保存到数据库
      await _databaseService.updateSubscription(newSubscription);
      _subscription.value = newSubscription;

      Get.snackbar(
        '成功',
        '订阅信息已更新',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '更新订阅信息失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUpgrading.value = false;
    }
  }
}
