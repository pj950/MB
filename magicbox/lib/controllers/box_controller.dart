// lib/controllers/box_controller.dart
import 'package:get/get.dart';
import '../models/box_model.dart';
import '../services/database_service.dart';
import '../controllers/subscription_controller.dart';
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'package:flutter/foundation.dart';

class BoxController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final AuthController _authController = Get.find<AuthController>();
  final SubscriptionController _subscriptionController =
      Get.find<SubscriptionController>();
  final RxList<BoxModel> _boxes = <BoxModel>[].obs;
  final RxBool _isLoading = false.obs;

  List<BoxModel> get boxes => _boxes;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadBoxes();
  }

  Future<void> loadBoxes() async {
    _isLoading.value = true;
    try {
      final currentUserId = _authController.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('用户未登录');
      }
      final boxes =
          await _databaseService.getBoxesByOwner(currentUserId.toString());
      _boxes.value = boxes;
    } catch (e) {
      debugPrint('加载盒子列表失败: $e'); 
      Get.snackbar(
        '错误',
        '加载盒子列表失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createBox(BoxModel box) async {
    debugPrint('开始创建盒子: ${box.name}');
    _isLoading.value = true;
    try {
      // 检查数据库连接状态
      if (!await _databaseService.isDatabaseOpen()) {
        debugPrint('数据库未打开，尝试重新初始化');
        await _databaseService.initializeDatabase();
      }

      // 检查订阅信息
      final subscription = _subscriptionController.subscription;
      debugPrint('当前订阅信息: ${subscription?.type}');
      if (subscription == null) {
        throw Exception('未找到订阅信息，请先登录或检查订阅状态');
      }

      // 检查盒子数量限制
      final currentBoxCount =
          _boxes.where((b) => b.repositoryId == box.repositoryId).length;
      debugPrint(
          '当前盒子数量: $currentBoxCount, 最大允许数量: ${subscription.maxBoxesPerRepository}');
      if (currentBoxCount >= subscription.maxBoxesPerRepository) {
        throw Exception('已达到最大盒子数量限制 (${subscription.maxBoxesPerRepository}个)');
      }

      // 确保 creator_id 和 user_id 不为空
      final currentUser = _authController.currentUser;
      if (currentUser == null) {
        throw Exception('用户未登录');
      }
      
      // 更新盒子的用户ID
      box = box.copyWith(
        userId: currentUser.id.toString(),
        creatorId: currentUser.id.toString(),
        themeColor: '#4A90E2',
        accessLevel: BoxAccessLevel.PRIVATE,
        password: null,
        allowedUserIds: [],
      );

      debugPrint('正在保存盒子到数据库...');
      debugPrint('盒子信息: ${box.toMap()}');
      
      // 尝试创建盒子
      final boxId = await _databaseService.insertBox(box);
      if (boxId == null) {
        throw Exception('创建盒子失败：数据库操作返回空ID');
      }
      
      debugPrint('盒子保存成功，ID: $boxId');

      // 更新本地盒子列表
      final updatedBox = box.copyWith(id: boxId.toString());
      _boxes.add(updatedBox);
      debugPrint('本地盒子列表已更新');

      // 刷新盒子列表
      await loadBoxes();

      Get.snackbar(
        '成功',
        '盒子创建成功',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green[100],
        colorText: Colors.green[900],
      );
    } catch (e) {
      debugPrint('创建盒子失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
      
      String errorMessage = '创建盒子失败';
      if (e.toString().contains('SQLITE_READONLY_DBMOVED')) {
        errorMessage = '数据库文件被移动或删除，请重启应用';
      } else if (e.toString().contains('No such file or directory')) {
        errorMessage = '数据库文件不存在，请重启应用';
      } else {
        errorMessage = '创建盒子失败：${e.toString()}';
      }
      
      Get.snackbar(
        '错误',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        mainButton: TextButton(
          onPressed: () {
            Get.back();
            loadBoxes();
          },
          child: const Text('重试'),
        ),
      );
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateBox(BoxModel box) async {
    try {
      await _databaseService.updateBox(box);
      final index = boxes.indexWhere((b) => b.id == box.id);
      if (index != -1) {
        boxes[index] = box;
      }

      Get.snackbar(
        '成功',
        '仓库更新成功',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '更新仓库失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteBox(String boxId) async {
    try {
      await _databaseService.deleteBox(boxId);
      boxes.removeWhere((box) => box.id == boxId);

      Get.snackbar(
        '成功',
        '仓库删除成功',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '删除仓库失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showCreateBoxDialog(String repositoryId) {
    debugPrint('开始显示创建盒子对话框');
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final typeController = Rx<BoxType>(BoxType.CUSTOM);

    final currentUserId = _authController.currentUser?.id;
    debugPrint('当前用户ID: $currentUserId');
    if (currentUserId == null) {
      debugPrint('用户未登录，显示错误提示');
      Get.snackbar(
        '错误',
        '请先登录',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    // 检查订阅限制
    final subscription = _subscriptionController.subscription;
    if (subscription == null) {
      debugPrint('未找到订阅信息');
      Get.snackbar(
        '错误',
        '未找到订阅信息，请先登录或检查订阅状态',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    // 获取当前仓库的盒子数量
    final currentBoxes =
        _boxes.where((box) => box.repositoryId == repositoryId).length;
    debugPrint('当前仓库盒子数量: $currentBoxes');

    // 检查盒子数量限制
    if (!subscription.canAddBox(currentBoxes)) {
      debugPrint('已达到盒子数量限制');
      Get.snackbar(
        '提示',
        '当前订阅类型（${_subscriptionController.getSubscriptionTypeName(subscription.type)}）每个仓库最多支持 ${subscription.maxBoxesPerRepository} 个盒子，请升级订阅以创建更多盒子',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/subscription'),
          child: const Text('升级订阅'),
        ),
      );
      return;
    }

    try {
      Get.dialog(
        AlertDialog(
          title: const Text('创建盒子'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '盒子名称',
                  hintText: '请输入盒子名称',
                ),
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<BoxType>(
                    value: typeController.value,
                    items: BoxType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_getBoxTypeName(type)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        typeController.value = value;
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: '盒子类型',
                    ),
                  )),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '盒子描述',
                  hintText: '请输入盒子描述（可选）',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                nameController.dispose();
                descriptionController.dispose();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  Get.snackbar(
                    '错误',
                    '请输入盒子名称',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                try {
                  debugPrint('开始创建盒子');
                  final box = BoxModel(
                    name: nameController.text,
                    type: typeController.value,
                    description: descriptionController.text.isEmpty
                        ? null
                        : descriptionController.text,
                    isPublic: false,
                    repositoryId: repositoryId,
                    userId: currentUserId.toString(),
                    creatorId: currentUserId.toString(),
                    themeColor: '#4A90E2',
                    accessLevel: BoxAccessLevel.PRIVATE,
                    password: null,
                    allowedUserIds: [],
                  );

                  // 先关闭对话框
                  Get.back();
                  
                  // 然后释放控制器
                  nameController.dispose();
                  descriptionController.dispose();

                  debugPrint('调用createBox方法');
                  await createBox(box);
                  debugPrint('createBox方法调用成功');
                  
                  // 最后显示成功提示
                  Get.snackbar(
                    '成功',
                    '盒子创建成功',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } catch (e) {
                  debugPrint('创建盒子过程中发生错误: $e');
                  debugPrint('错误堆栈: ${StackTrace.current}');
                  Get.snackbar(
                    '错误',
                    '创建盒子失败：${e.toString()}',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red[100],
                    colorText: Colors.red[900],
                  );
                }
              },
              child: const Text('创建'),
            ),
          ],
        ),
      );
      debugPrint('对话框显示成功');
    } catch (e) {
      debugPrint('显示对话框时发生错误: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
      Get.snackbar(
        '错误',
        '显示创建盒子对话框失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  String _getBoxTypeName(BoxType type) {
    switch (type) {
      case BoxType.WARDROBE:
        return '衣柜';
      case BoxType.BOOKSHELF:
        return '书架';
      case BoxType.COLLECTION:
        return '收藏';
      case BoxType.CUSTOM:
        return '自定义';
    }
  }

  Future<BoxModel?> getBox(String id) async {
    try {
      return await _databaseService.getBox(id);
    } catch (e) {
      Get.snackbar('错误', '获取盒子失败：$e');
      return null;
    }
  }
}
