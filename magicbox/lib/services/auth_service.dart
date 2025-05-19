import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final DatabaseService _db = DatabaseService();
  UserModel? _currentUser;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _jwtSecret = 'your_jwt_secret_key'; // 在生产环境中应该使用环境变量

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
    final userId = prefs.getString(_userIdKey);
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
    print('开始注册用户: $username');
    try {
      // 检查用户名是否已存在
      final existingUser = await _db.getUserByUsername(username);
      if (existingUser != null) {
        print('用户名已存在: $username');
        throw Exception('用户名已存在');
      }

      // 创建新用户
      final now = DateTime.now();
      final hashedPassword = _hashPassword(password);
      print('密码哈希完成');

      final user = UserModel(
        username: username,
        email: email,
        password: hashedPassword, // 使用哈希后的密码
        phoneNumber: phoneNumber,
        type: type,
        createdAt: now,
        updatedAt: now,
      );
      print('用户对象创建成功');

      // 保存用户到数据库
      final userId = await _db.insertUser(user);
      print('用户保存到数据库成功，ID: $userId');

      // 注意：不要直接修改 id，而是创建一个新的 UserModel 实例
      _currentUser = UserModel(
        id: userId.toString(),
        username: user.username,
        email: user.email,
        password: user.password,
        phoneNumber: user.phoneNumber,
        type: user.type,
        createdAt: user.createdAt,
        updatedAt: user.updatedAt,
      );
      print('当前用户设置成功');

      // 生成认证令牌
      final token = _generateToken(user);
      print('认证令牌生成成功');

      // 保存认证信息
      await _saveAuthInfo(token, userId.toString());
      print('认证信息保存成功');

      return user;
    } catch (e) {
      print('注册过程发生错误: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<UserModel> login(String username, String password) async {
    try {
      print('开始登录流程');
      print('用户名: $username');
      print('密码: $password');

      final user = await _db.getUserByUsername(username);
      if (user == null) {
        print('用户不存在: $username');
        throw Exception('用户名或密码错误');
      }

      if (user.id == null) {
        print('用户ID为空');
        throw Exception('用户数据错误');
      }

      print('找到用户: ${user.toMap()}');
      print('数据库中的密码: ${user.password}');

      final hashedPassword = _hashPassword(password);
      print('输入的密码哈希: $hashedPassword');

      if (user.password != hashedPassword) {
        print('密码不匹配');
        throw Exception('用户名或密码错误');
      }

      print('密码验证成功');
      final token = _generateToken(user);
      print('生成token: $token');

      await _saveAuthInfo(token, user.id!);
      print('保存token成功');

      _currentUser = user;
      print('设置当前用户成功: ${user.username}');
      return user;
    } catch (e) {
      print('登录失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
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

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateToken(UserModel user) {
    final header = {'alg': 'HS256', 'typ': 'JWT'};

    final payload = {
      'sub': user.id,
      'username': user.username,
      'email': user.email,
      'type': user.type.toString(),
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().add(const Duration(days: 7)))
              .millisecondsSinceEpoch ~/
          1000,
    };

    final encodedHeader = base64Url.encode(utf8.encode(json.encode(header)));
    final encodedPayload = base64Url.encode(utf8.encode(json.encode(payload)));

    final signature = Hmac(sha256, utf8.encode(_jwtSecret))
        .convert(utf8.encode('$encodedHeader.$encodedPayload'))
        .bytes;
    final encodedSignature = base64Url.encode(signature);

    return '$encodedHeader.$encodedPayload.$encodedSignature';
  }

  Future<void> _saveAuthInfo(String token, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
  }

  Future<UserModel?> getUserByUsername(String username) async {
    try {
      return await _db.getUserByUsername(username);
    } catch (e) {
      print('获取用户失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      return null;
    }
  }
}
