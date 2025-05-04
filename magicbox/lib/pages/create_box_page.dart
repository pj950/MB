import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/box_controller.dart';
import '../models/box_model.dart';
import '../utils/image_picker_helper.dart';
import '../utils/theme_helper.dart';

class CreateBoxPage extends StatefulWidget {
  const CreateBoxPage({super.key});

  @override
  State<CreateBoxPage> createState() => _CreateBoxPageState();
}

class _CreateBoxPageState extends State<CreateBoxPage> {
  final nameController = TextEditingController();
  File? coverImage;
  Uint8List? coverImageBytes;

  String selectedColor = 'orange'; // 默认主题色

  final BoxController boxController = Get.find();

  final colors = ['orange', 'purple', 'blue', 'green', 'pink'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('创建盒子')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            GestureDetector(
              onTap: pickCoverImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    if (coverImageBytes != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(coverImageBytes!,
                            fit: BoxFit.cover, width: double.infinity),
                      )
                    else if (coverImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(coverImage!,
                            fit: BoxFit.cover, width: double.infinity),
                      )
                    else
                      const Center(child: Text('点击添加封面')),
                    if (coverImage != null || coverImageBytes != null)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              coverImage = null;
                              coverImageBytes = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    if (coverImage != null || coverImageBytes != null)
                      Container(
                        decoration: BoxDecoration(
                          color: ThemeHelper.getMaterialForTheme(selectedColor)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '盒子名称'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: colors.map((color) {
                return ChoiceChip(
                  label: Text(color),
                  selected: selectedColor == color,
                  onSelected: (selected) {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: createBox,
              child: const Text('创建'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> pickCoverImage() async {
    final picked =
        await CrossPlatformImagePicker.pickImageFromGallery(Get.context!);

    if (picked != null) {
      setState(() {
        if (kIsWeb && picked is Uint8List) {
          coverImage = null;
          coverImageBytes = picked;
        } else if (picked is File) {
          coverImage = picked;
          coverImageBytes = null;
        }
      });
      print('✅ 封面图片选择完成');
    } else {
      print('❌ 没有选择图片');
    }
  }

  void createBox() {
    print('🚀 createBox triggered');
    print('📸 coverImage: $coverImage');
    print('📦 coverImageBytes: $coverImageBytes');
    print('📝 name: ${nameController.text.trim()}');

    if ((coverImage != null || coverImageBytes != null) &&
        nameController.text.trim().isNotEmpty) {
      boxController.addBox(BoxModel(
        name: nameController.text.trim(),
        coverImage: kIsWeb ? 'web_memory_image' : coverImage!.path,
        themeColor: selectedColor,
      ));
      print('✅ 已调用 boxController.addBox');
      Get.back();
    } else {
      print('❌ 未通过验证，封面或名称为空');
      Get.snackbar('提示', '请完善信息');
    }
  }
}
