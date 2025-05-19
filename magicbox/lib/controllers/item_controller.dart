import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/item_model.dart';
import '../services/database_service.dart';
import '../services/file_service.dart';
import 'package:uuid/uuid.dart';

class ItemController extends GetxController {
  final DatabaseService _db = DatabaseService();
  final FileService _fileService = FileService();
  final RxList<ItemModel> _items = <ItemModel>[].obs;
  final RxBool _isLoading = false.obs;

  List<ItemModel> get items => _items;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    _isLoading.value = true;
    try {
      final items = await _db.getAllItems();
      _items.value = items;
    } catch (e) {
      Get.snackbar('错误', '加载物品失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<ItemModel>> getItemsByBox(String boxId) async {
    try {
      return await _db.getItemsByBox(boxId);
    } catch (e) {
      Get.snackbar('错误', '获取物品失败：$e');
      return [];
    }
  }

  Future<void> createItem({
    required String boxId,
    required String name,
    required String description,
    String? imagePath,
    bool isPublic = false,
    Map<String, dynamic>? shareSettings,
    Map<String, dynamic>? advancedProperties,
    List<String> tags = const [],
    bool isFavorite = false,
  }) async {
    _isLoading.value = true;
    try {
      final now = DateTime.now();
      final item = ItemModel(
        id: const Uuid().v4(),
        boxId: boxId,
        name: name,
        description: description,
        imagePath: imagePath ?? 'assets/images/placeholder.png',
        createdAt: now,
        updatedAt: now,
        isPublic: isPublic,
        shareSettings: shareSettings,
        advancedProperties: advancedProperties,
        tags: tags,
        isFavorite: isFavorite,
      );

      await _db.insertItem(item);
      _items.add(item);

      Get.back();
      Get.snackbar('成功', '物品创建成功');
    } catch (e) {
      Get.snackbar('错误', '创建物品失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateItem(ItemModel item) async {
    _isLoading.value = true;
    try {
      await _db.updateItem(item);
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
      }
      Get.back();
      Get.snackbar('成功', '物品更新成功');
    } catch (e) {
      Get.snackbar('错误', '更新物品失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteItem(String itemId) async {
    _isLoading.value = true;
    try {
      final item = _items.firstWhere((i) => i.id == itemId);
      if (item.imagePath != 'assets/images/placeholder.png') {
        await _fileService.deleteImage(item.imagePath);
      }
      await _db.deleteItem(int.parse(itemId));
      _items.removeWhere((item) => item.id == itemId);
      Get.back();
      Get.snackbar('成功', '物品删除成功');
    } catch (e) {
      Get.snackbar('错误', '删除物品失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<String>> uploadImages() async {
    try {
      return await _fileService.pickAndSaveMultipleImages();
    } catch (e) {
      Get.snackbar('错误', '上传图片失败：$e');
      return [];
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      await _fileService.deleteImage(imagePath);
    } catch (e) {
      Get.snackbar('错误', '删除图片失败：$e');
    }
  }

  void showCreateItemDialog(String boxId) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String? imagePath;
    bool isPublic = false;
    bool isFavorite = false;
    const List<String> tags = [];

    Get.dialog(
      AlertDialog(
        title: const Text('添加物品'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '物品名称',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: '描述（选填）',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('公开'),
                  value: isPublic,
                  onChanged: (value) {
                    setState(() => isPublic = value);
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('收藏'),
                  value: isFavorite,
                  onChanged: (value) {
                    setState(() => isFavorite = value);
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final paths = await uploadImages();
                    if (paths.isNotEmpty) {
                      setState(() {
                        imagePath = paths.first;
                      });
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('添加图片'),
                ),
                if (imagePath != null) ...[
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      Image.file(
                        File(imagePath!),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              imagePath = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                Get.snackbar('错误', '请输入物品名称');
                return;
              }
              createItem(
                boxId: boxId,
                name: nameController.text,
                description: descriptionController.text,
                imagePath: imagePath,
                isPublic: isPublic,
                isFavorite: isFavorite,
                tags: tags,
              );
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Future<ItemModel?> getItem(String id) async {
    try {
      return await _db.getItem(int.parse(id));
    } catch (e) {
      Get.snackbar('错误', '获取物品失败：$e');
      return null;
    }
  }
}
