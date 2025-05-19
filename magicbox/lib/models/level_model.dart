class LevelModel {
  final int level;
  final int requiredExp;
  final String title;
  final String description;
  final List<String> privileges;
  final double pointsMultiplier;
  final double coinsMultiplier;

  LevelModel({
    required this.level,
    required this.requiredExp,
    required this.title,
    required this.description,
    required this.privileges,
    this.pointsMultiplier = 1.0,
    this.coinsMultiplier = 1.0,
  });

  LevelModel copyWith({
    int? level,
    int? requiredExp,
    String? title,
    String? description,
    List<String>? privileges,
    double? pointsMultiplier,
    double? coinsMultiplier,
  }) {
    return LevelModel(
      level: level ?? this.level,
      requiredExp: requiredExp ?? this.requiredExp,
      title: title ?? this.title,
      description: description ?? this.description,
      privileges: privileges ?? this.privileges,
      pointsMultiplier: pointsMultiplier ?? this.pointsMultiplier,
      coinsMultiplier: coinsMultiplier ?? this.coinsMultiplier,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'required_exp': requiredExp,
      'title': title,
      'description': description,
      'privileges': privileges.join(','),
      'points_multiplier': pointsMultiplier,
      'coins_multiplier': coinsMultiplier,
    };
  }

  factory LevelModel.fromMap(Map<String, dynamic> map) {
    return LevelModel(
      level: map['level'] as int,
      requiredExp: map['required_exp'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      privileges: (map['privileges'] as String).split(','),
      pointsMultiplier: map['points_multiplier'] as double? ?? 1.0,
      coinsMultiplier: map['coins_multiplier'] as double? ?? 1.0,
    );
  }

  @override
  String toString() {
    return 'LevelModel(level: $level, requiredExp: $requiredExp, title: $title, description: $description, privileges: $privileges, pointsMultiplier: $pointsMultiplier, coinsMultiplier: $coinsMultiplier)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is LevelModel &&
      other.level == level &&
      other.requiredExp == requiredExp &&
      other.title == title &&
      other.description == description &&
      other.privileges == privileges &&
      other.pointsMultiplier == pointsMultiplier &&
      other.coinsMultiplier == coinsMultiplier;
  }

  @override
  int get hashCode {
    return level.hashCode ^
      requiredExp.hashCode ^
      title.hashCode ^
      description.hashCode ^
      privileges.hashCode ^
      pointsMultiplier.hashCode ^
      coinsMultiplier.hashCode;
  }
}

class UserLevelModel {
  final String userId;
  final int level;
  final int exp;
  final int totalExp;
  final DateTime lastExpUpdate;

  UserLevelModel({
    required this.userId,
    required this.level,
    required this.exp,
    required this.totalExp,
    required this.lastExpUpdate,
  });

  UserLevelModel copyWith({
    String? userId,
    int? level,
    int? exp,
    int? totalExp,
    DateTime? lastExpUpdate,
  }) {
    return UserLevelModel(
      userId: userId ?? this.userId,
      level: level ?? this.level,
      exp: exp ?? this.exp,
      totalExp: totalExp ?? this.totalExp,
      lastExpUpdate: lastExpUpdate ?? this.lastExpUpdate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'level': level,
      'exp': exp,
      'total_exp': totalExp,
      'last_exp_update': lastExpUpdate.toIso8601String(),
    };
  }

  factory UserLevelModel.fromMap(Map<String, dynamic> map) {
    return UserLevelModel(
      userId: map['user_id'] as String,
      level: map['level'] as int,
      exp: map['exp'] as int,
      totalExp: map['total_exp'] as int,
      lastExpUpdate: DateTime.parse(map['last_exp_update'] as String),
    );
  }

  @override
  String toString() {
    return 'UserLevelModel(userId: $userId, level: $level, exp: $exp, totalExp: $totalExp, lastExpUpdate: $lastExpUpdate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserLevelModel &&
      other.userId == userId &&
      other.level == level &&
      other.exp == exp &&
      other.totalExp == totalExp &&
      other.lastExpUpdate == lastExpUpdate;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
      level.hashCode ^
      exp.hashCode ^
      totalExp.hashCode ^
      lastExpUpdate.hashCode;
  }
} 