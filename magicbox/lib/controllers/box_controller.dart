// lib/controllers/box_controller.dart
import 'package:get/get.dart';
import '../models/box_model.dart';
import '../services/database_service.dart';
import '../controllers/subscription_controller.dart';
import 'package:flutter/material.dart';

class BoxController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final SubscriptionController _subscriptionController = Get.find<SubscriptionController>();
  
  final RxList<BoxModel> boxes = <BoxModel>[].obs;
  final RxBool isLoading = false.obs;

  List<BoxModel> get boxes => this.boxes;
  bool get isLoading => isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadBoxes();
  }

  Future<void> loadBoxes() async {
    try {
      isLoading.value = true;
      final userId = Get.find<AuthController>().currentUser?.id;
      if (userId == null) {
        throw Exception('用户未登录');
      }

      final boxes = await _databaseService.getBoxesByOwner(userId);
      this.boxes.value = boxes;
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载仓库失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createBox(BoxModel box) async {
    try {
      // 检查订阅限制
      final subscription = _subscriptionController.subscription;
      if (subscription == null) {
        throw Exception('未找到订阅信息');
      }

      // 检查仓库数量限制
      if (subscription.maxRepositories != -1 && 
          boxes.length >= subscription.maxRepositories) {
        throw Exception('已达到仓库数量限制，请升级订阅');
      }

      // 检查盒子数量限制
      if (subscription.maxBoxesPerRepository != -1) {
        final boxCount = await _databaseService.getBoxCount(box.ownerId);
        if (boxCount >= subscription.maxBoxesPerRepository) {
          throw Exception('已达到盒子数量限制，请升级订阅');
        }
      }

      final boxId = await _databaseService.insertBox(box);
      box = box.copyWith(id: boxId);
      boxes.add(box);

      Get.snackbar(
        '成功',
        '仓库创建成功',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '创建仓库失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
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

  Future<void> deleteBox(int boxId) async {
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

  void showCreateBoxDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    BoxType selectedType = BoxType.CUSTOM;

    Get.dialog(
      AlertDialog(
        title: const Text('创建仓库'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '仓库名称',
                  hintText: '请输入仓库名称',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                  hintText: '请输入仓库描述',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BoxType>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: '仓库类型',
                ),
                items: BoxType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getBoxTypeName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedType = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  '错误',
                  '请输入仓库名称',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              final box = BoxModel(
                name: nameController.text,
                description: descriptionController.text,
                type: selectedType,
                ownerId: Get.find<AuthController>().currentUser?.id ?? 0,
                coverImage: 'assets/images/default_box_cover.png',
                themeColor: '#4A90E2',
              );

              try {
                await createBox(box);
                Get.back();
              } catch (e) {
                // 错误已在createBox中处理
              }
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
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
}
