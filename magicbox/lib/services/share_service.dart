import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/material.dart';

class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  final _screenshotController = ScreenshotController();

  Future<void> shareText(String text) async {
    await Share.share(text);
  }

  Future<void> shareImage(String imagePath) async {
    await Share.shareXFiles([XFile(imagePath)]);
  }

  Future<void> shareMultipleImages(List<String> imagePaths) async {
    final files = imagePaths.map((path) => XFile(path)).toList();
    await Share.shareXFiles(files);
  }

  Future<void> shareWidget(Widget widget) async {
    final bytes = await _screenshotController.captureFromWidget(widget);
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/screenshot.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> shareItem({
    required String name,
    required String description,
    List<String>? imagePaths,
  }) async {
    final text = '''
物品名称：$name
描述：$description
''';

    if (imagePaths != null && imagePaths.isNotEmpty) {
      await shareMultipleImages(imagePaths);
    } else {
      await shareText(text);
    }
  }

  Future<void> shareBox({
    required String name,
    required String description,
    required String type,
    List<String>? imagePaths,
  }) async {
    final text = '''
仓库名称：$name
类型：$type
描述：$description
''';

    if (imagePaths != null && imagePaths.isNotEmpty) {
      await shareMultipleImages(imagePaths);
    } else {
      await shareText(text);
    }
  }

  Future<void> sharePost({
    required String title,
    required String content,
    List<String>? imagePaths,
  }) async {
    final text = '''
$title

$content
''';

    if (imagePaths != null && imagePaths.isNotEmpty) {
      await shareMultipleImages(imagePaths);
    } else {
      await shareText(text);
    }
  }
} 