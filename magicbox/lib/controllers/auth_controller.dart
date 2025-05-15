// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;

  UserModel? get currentUser => _currentUser.value;
  bool get isAuthenticated => _currentUser.value != null;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    _isLoading.value = true;
    try {
      _currentUser.value = await _authService.getCurrentUser();
    } catch (e) {
      print('加载用户信息失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
    UserType type = UserType.PERSONAL,
  }) async {
    _isLoading.value = true;
    try {
      final user = await _authService.register(
        username: username,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        type: type,
      );
      _currentUser.value = user;
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('注册失败', e.toString());
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> login(String username, String password) async {
    _isLoading.value = true;
    try {
      final user = await _authService.login(username, password);
      _currentUser.value = user;
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('登录失败', e.toString());
      rethrow;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> logout() async {
    _isLoading.value = true;
    try {
      await _authService.logout();
      _currentUser.value = null;
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar('退出失败', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProfile(UserModel user) async {
    _isLoading.value = true;
    try {
      await _authService.updateProfile(user);
      _currentUser.value = user;
      Get.snackbar('成功', '个人信息已更新');
    } catch (e) {
      Get.snackbar('更新失败', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }
}
