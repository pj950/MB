import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class FileService {
  static final FileService _instance = FileService._internal();
  final ImagePicker _picker = ImagePicker();

  factory FileService() => _instance;

  FileService._internal();

  Future<String> pickAndSaveImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) {
        throw Exception('未选择图片');
      }

      // 获取应用文档目录
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final savedPath = path.join(directory.path, fileName);

      // 压缩和调整图片
      final File imageFile = File(image.path);
      final img.Image? originalImage = img.decodeImage(await imageFile.readAsBytes());
      
      if (originalImage == null) {
        throw Exception('无法读取图片');
      }

      // 调整图片大小
      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: 1920,
        height: 1080,
        interpolation: img.Interpolation.linear,
      );

      // 保存调整后的图片
      final File savedFile = File(savedPath);
      await savedFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 85));

      return savedPath;
    } catch (e) {
      throw Exception('图片处理失败：$e');
    }
  }

  Future<List<String>> pickAndSaveMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isEmpty) {
        throw Exception('未选择图片');
      }

      final List<String> savedPaths = [];
      final directory = await getApplicationDocumentsDirectory();

      for (var image in images) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final savedPath = path.join(directory.path, fileName);

        // 压缩和调整图片
        final File imageFile = File(image.path);
        final img.Image? originalImage = img.decodeImage(await imageFile.readAsBytes());
        
        if (originalImage == null) {
          continue;
        }

        // 调整图片大小
        final img.Image resizedImage = img.copyResize(
          originalImage,
          width: 1920,
          height: 1080,
          interpolation: img.Interpolation.linear,
        );

        // 保存调整后的图片
        final File savedFile = File(savedPath);
        await savedFile.writeAsBytes(img.encodeJpg(resizedImage, quality: 85));
        savedPaths.add(savedPath);
      }

      return savedPaths;
    } catch (e) {
      throw Exception('图片处理失败：$e');
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw Exception('删除图片失败：$e');
    }
  }

  Future<void> deleteImages(List<String> imagePaths) async {
    for (var path in imagePaths) {
      await deleteImage(path);
    }
  }
} 