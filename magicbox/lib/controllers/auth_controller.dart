// lib/controllers/auth_controller.dart
import 'package:get/get.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;

  // 登录方法（Mock）
  void login(String method, String account, String code) {
    if ((method == 'phone' && account == '18812345678' && code == '1234') ||
        (method == 'email' && account == 'testuser@example.com' && code == '1234')) {
      isLoggedIn.value = true;
      Get.offAllNamed('/home');
    } else {
      Get.snackbar('登录失败', '账号或验证码错误');
    }
  }
}
