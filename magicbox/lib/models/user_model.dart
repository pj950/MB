// lib/models/user_model.dart
class UserModel {
  int? id;
  String username;
  String email;
  String? phoneNumber;
  String? avatarUrl;
  String? nickName;
  String? realName;
  UserType type;
  int points;
  int coins;
  int level;
  int experience;
  bool isActive;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.nickName,
    this.realName,
    this.type = UserType.PERSONAL,
    this.points = 0,
    this.coins = 0,
    this.level = 1,
    this.experience = 0,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      avatarUrl: map['avatarUrl'],
      nickName: map['nickName'],
      realName: map['realName'],
      type: UserType.values.firstWhere(
        (e) => e.toString() == 'UserType.${map['type']}',
        orElse: () => UserType.PERSONAL,
      ),
      points: map['points'] ?? 0,
      coins: map['coins'] ?? 0,
      level: map['level'] ?? 1,
      experience: map['experience'] ?? 0,
      isActive: map['isActive'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'nickName': nickName,
      'realName': realName,
      'type': type.toString().split('.').last,
      'points': points,
      'coins': coins,
      'level': level,
      'experience': experience,
      'isActive': isActive ? 1 : 0,
    };
  }
}

enum UserType {
  PERSONAL,
  ENTERPRISE
} 