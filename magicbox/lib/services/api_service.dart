// lib/services/api_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class APIService {
  static const String baseUrl = 'http://192.168.1.8:3000'; // 本地服务器地址
  //static const String baseUrl = 'http://localhost:3000'; // 本地服务器地址

  // 图片上传
  static Future<String?> uploadImage(File imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path,
        filename: basename(imageFile.path)));
    var response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return respStr; // 返回服务器图片路径
    } else {
      return null;
    }
  }
}
