import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class CrossPlatformImagePicker {
  /// 返回 [File] 或 [Uint8List]（Web）
  static Future<dynamic> pickImageFromGallery(BuildContext context) async {
    if (kIsWeb) {
      // Web 使用 file_picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        return result.files.single.bytes; // 返回 Uint8List
      } else {
        return null;
      }
    } else {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) return File(image.path);
      return null;
    }
  }
}
