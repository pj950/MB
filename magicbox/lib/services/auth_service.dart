import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final DatabaseService _db = DatabaseService();
  UserModel? _currentUser;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  factory AuthService() => _instance;

  AuthService._internal();

  UserModel? get currentUser => _currentUser;

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    if (userId == null) return null;

    _currentUser = await _db.getUser(userId);
    return _currentUser;
  }

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
    UserType type = UserType.PERSONAL,
  }) async {
    // 检查用户名是否已存在
    final existingUser = await _db.getUserByUsername(username);
    if (existingUser != null) {
      throw Exception('用户名已存在');
    }

    // 创建新用户
    final user = UserModel(
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      type: type,
    );

    // 保存用户到数据库
    final userId = await _db.insertUser(user);
    user.id = userId;

    // 生成认证令牌
    final token = _generateToken(user);

    // 保存认证信息
    await _saveAuthInfo(token, userId);

    _currentUser = user;
    return user;
  }

  Future<UserModel> login(String username, String password) async {
    // 获取用户信息
    final user = await _db.getUserByUsername(username);
    if (user == null) {
      throw Exception('用户不存在');
    }

    // 验证密码（这里应该使用加密后的密码比较）
    // TODO: 实现密码加密和验证

    // 生成认证令牌
    final token = _generateToken(user);

    // 保存认证信息
    await _saveAuthInfo(token, user.id!);

    _currentUser = user;
    return user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    _currentUser = null;
  }

  Future<void> updateProfile(UserModel user) async {
    await _db.updateUser(user);
    if (_currentUser?.id == user.id) {
      _currentUser = user;
    }
  }

  String _generateToken(UserModel user) {
    // TODO: 实现JWT令牌生成
    return 'dummy_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> _saveAuthInfo(String token, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
  }
}
