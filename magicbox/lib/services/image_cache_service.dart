import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  Future<String> get _cacheDir async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  String _getCacheKey(String imagePath) {
    final bytes = utf8.encode(imagePath);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String?> getCachedImage(String imagePath) async {
    final cacheKey = _getCacheKey(imagePath);
    final cacheDir = await _cacheDir;
    final cachedPath = path.join(cacheDir, cacheKey);
    
    if (await File(cachedPath).exists()) {
      return cachedPath;
    }
    return null;
  }

  Future<String> cacheImage(String imagePath, {int maxWidth = 800}) async {
    final cacheKey = _getCacheKey(imagePath);
    final cacheDir = await _cacheDir;
    final cachedPath = path.join(cacheDir, cacheKey);

    if (await File(cachedPath).exists()) {
      return cachedPath;
    }

    final file = File(imagePath);
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception('无法解码图片');
    }

    var resizedImage = image;
    if (image.width > maxWidth) {
      resizedImage = img.copyResize(
        image,
        width: maxWidth,
        height: (image.height * maxWidth / image.width).round(),
      );
    }

    final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
    await File(cachedPath).writeAsBytes(compressedBytes);

    return cachedPath;
  }

  Future<void> clearCache() async {
    final cacheDir = await _cacheDir;
    final dir = Directory(cacheDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<void> removeCachedImage(String imagePath) async {
    final cacheKey = _getCacheKey(imagePath);
    final cacheDir = await _cacheDir;
    final cachedPath = path.join(cacheDir, cacheKey);
    
    final file = File(cachedPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
} 