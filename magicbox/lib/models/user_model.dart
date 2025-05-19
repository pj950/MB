// lib/models/user_model.dart
import 'dart:convert';

class UserModel {
  final String? id;
  final String username;
  final String? avatarUrl;
  final String? email;
  final String password;
  final UserType type;
  final Map<String, bool>? moderatorPermissions;
  final DateTime createdAt;
  final DateTime updatedAt;
  String? phoneNumber;
  String? nickName;
  String? realName;
  int points;
  int coins;
  int level;
  int experience;
  bool isActive;

  UserModel({
    this.id,
    required this.username,
    this.avatarUrl,
    this.email,
    required this.password,
    this.type = UserType.PERSONAL,
    this.moderatorPermissions,
    required this.createdAt,
    required this.updatedAt,
    this.phoneNumber,
    this.nickName,
    this.realName,
    this.points = 0,
    this.coins = 0,
    this.level = 1,
    this.experience = 0,
    this.isActive = true,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? email,
    String? password,
    UserType? type,
    Map<String, bool>? moderatorPermissions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phoneNumber,
    String? nickName,
    String? realName,
    int? points,
    int? coins,
    int? level,
    int? experience,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      password: password ?? this.password,
      type: type ?? this.type,
      moderatorPermissions: moderatorPermissions ?? this.moderatorPermissions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      nickName: nickName ?? this.nickName,
      realName: realName ?? this.realName,
      points: points ?? this.points,
      coins: coins ?? this.coins,
      level: level ?? this.level,
      experience: experience ?? this.experience,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'avatar_url': avatarUrl,
      'email': email,
      'password': password,
      'type': type.toString(),
      'moderator_permissions': moderatorPermissions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'phone_number': phoneNumber,
      'nick_name': nickName,
      'real_name': realName,
      'points': points,
      'coins': coins,
      'level': level,
      'experience': experience,
      'isactive': isActive ? 1 : 0,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString(),
      username: map['username'] ?? '',
      avatarUrl: map['avatar_url']?.toString(),
      email: map['email']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      type: UserType.values.firstWhere(
        (e) => e.toString() == map['type']?.toString(),
        orElse: () => UserType.PERSONAL,
      ),
      moderatorPermissions:
          _parseModeratorPermissions(map['moderator_permissions']),
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      phoneNumber: map['phone_number']?.toString(),
      nickName: map['nick_name']?.toString(),
      realName: map['real_name']?.toString(),
      points: map['points'] is int
          ? map['points']
          : int.tryParse(map['points']?.toString() ?? '0') ?? 0,
      coins: map['coins'] is int
          ? map['coins']
          : int.tryParse(map['coins']?.toString() ?? '0') ?? 0,
      level: map['level'] is int
          ? map['level']
          : int.tryParse(map['level']?.toString() ?? '1') ?? 1,
      experience: map['experience'] is int
          ? map['experience']
          : int.tryParse(map['experience']?.toString() ?? '0') ?? 0,
      isActive: map['isactive'] == 1 || map['isActive'] == 1,
    );
  }

  static Map<String, bool>? _parseModeratorPermissions(dynamic input) {
    if (input is Map<String, dynamic>) {
      return input.map((k, v) => MapEntry(k, v == true || v == 1));
    }
    if (input is String) {
      try {
        final decoded = jsonDecode(input);
        if (decoded is Map<String, dynamic>) {
          return decoded.map((k, v) => MapEntry(k, v == true || v == 1));
        }
      } catch (_) {}
    }
    return null;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, phoneNumber: $phoneNumber, avatarUrl: $avatarUrl, nickName: $nickName, realName: $realName, type: $type, points: $points, coins: $coins, level: $level, experience: $experience, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.phoneNumber == phoneNumber &&
        other.avatarUrl == avatarUrl &&
        other.nickName == nickName &&
        other.realName == realName &&
        other.type == type &&
        other.points == points &&
        other.coins == coins &&
        other.level == level &&
        other.experience == experience &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        phoneNumber.hashCode ^
        avatarUrl.hashCode ^
        nickName.hashCode ^
        realName.hashCode ^
        type.hashCode ^
        points.hashCode ^
        coins.hashCode ^
        level.hashCode ^
        experience.hashCode ^
        isActive.hashCode;
  }
}

enum UserType { PERSONAL, ENTERPRISE, ADMIN, MODERATOR }
