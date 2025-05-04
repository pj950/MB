import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/item_controller.dart';
import '../controllers/speech_controller.dart';
import '../models/box_model.dart';
import '../models/item_model.dart';
import '../services/db_service.dart';
import '../utils/image_picker_helper.dart';
import '../widgets/draggable_item.dart';
import '../widgets/image_preview_3d.dart';

class BoxDetailPage extends StatelessWidget {
  final BoxModel box;

  BoxDetailPage({super.key, required this.box});

  final ItemController itemController = Get.put(ItemController());
  final SpeechController speechController = Get.put(SpeechController());

  @override
  Widget build(BuildContext context) {
    itemController.loadItems(box.id!);
    checkExpiredItems();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(box.name),
            if (box.hasExpiredItems)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              speechController.startListening();
              speechController.text.listen((value) {
                itemController.searchItems(value);
              });
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: addItem,
      ),
      body: Obx(() {
        final items = itemController.itemList;
        if (items.isEmpty) {
          return const Center(child: Text('暂无物品'));
        }

        return Stack(
          children: items.map((item) {
            final imgFile = File(item.imagePath);
            return DraggableItemWidget(
              key: ValueKey(item.id),
              initialPosition: Offset(item.posX ?? 50.0, item.posY ?? 100.0),
              onPositionChanged: (offset) {
                item.posX = offset.dx;
                item.posY = offset.dy;
                itemController.updateItem(item);
              },
              child: GestureDetector(
                onTap: () {
                  final ctx = Get.context ?? context;
                  showDialog(
                    context: ctx,
                    builder: (_) => ImagePreview3D(path: item.imagePath),
                  );
                },
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(0.1)
                    ..rotateY(0.2),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: imgFile.existsSync()
                            ? FileImage(imgFile)
                            : const AssetImage('assets/images/placeholder.png')
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 10,
                          offset: Offset(4, 8),
                        )
                      ],
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        color: Colors.black45,
                        child: Text(
                          item.note,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Future<void> addItem() async {
    final picked =
        await CrossPlatformImagePicker.pickImageFromGallery(Get.context!);
    if (picked != null) {
      final noteController = TextEditingController();
      final dateController = TextEditingController();

      await Get.dialog(AlertDialog(
        title: const Text('添加物品'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: '备注'),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: '过期时间 yyyy-MM-dd'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final note = noteController.text.trim();
              final date = dateController.text.trim();
              final random = Random();
              itemController.addItem(ItemModel(
                boxId: box.id!,
                imagePath: picked.path,
                note: note.isNotEmpty ? note : '新物品',
                expiryDate: date,
                posX: 50 + random.nextDouble() * 100,
                posY: 100 + random.nextDouble() * 200,
              ));
              Get.back();
              Get.snackbar('成功', '物品已添加到盒子中 ✅',
                  snackPosition: SnackPosition.BOTTOM);
              checkExpiredItems();
            },
            child: const Text('确认'),
          ),
        ],
      ));
    }
  }

  void checkExpiredItems() async {
    final items = await DBService.getItemsByBoxId(box.id!);
    final hasExpired = items.any((item) {
      try {
        return item.expiryDate != null &&
            item.expiryDate!.isNotEmpty &&
            DateTime.parse(item.expiryDate!).isBefore(DateTime.now());
      } catch (_) {
        return false;
      }
    });

    final updatedBox = BoxModel(
      id: box.id,
      name: box.name,
      coverImage: box.coverImage,
      themeColor: box.themeColor,
      itemCount: box.itemCount,
      hasExpiredItems: hasExpired,
    );
    await DBService.updateBox(updatedBox);
  }
}
