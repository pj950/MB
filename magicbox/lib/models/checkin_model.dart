class CheckinModel {
  final String id;
  final String userId;
  final DateTime checkinDate;
  final int consecutiveDays;
  final int pointsEarned;
  final int coinsEarned;

  CheckinModel({
    required this.id,
    required this.userId,
    required this.checkinDate,
    required this.consecutiveDays,
    required this.pointsEarned,
    required this.coinsEarned,
  });

  CheckinModel copyWith({
    String? id,
    String? userId,
    DateTime? checkinDate,
    int? consecutiveDays,
    int? pointsEarned,
    int? coinsEarned,
  }) {
    return CheckinModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkinDate: checkinDate ?? this.checkinDate,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      coinsEarned: coinsEarned ?? this.coinsEarned,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'checkin_date': checkinDate.toIso8601String(),
      'consecutive_days': consecutiveDays,
      'points_earned': pointsEarned,
      'coins_earned': coinsEarned,
    };
  }

  factory CheckinModel.fromMap(Map<String, dynamic> map) {
    return CheckinModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      checkinDate: DateTime.parse(map['checkin_date'] as String),
      consecutiveDays: map['consecutive_days'] as int,
      pointsEarned: map['points_earned'] as int,
      coinsEarned: map['coins_earned'] as int,
    );
  }

  @override
  String toString() {
    return 'CheckinModel(id: $id, userId: $userId, checkinDate: $checkinDate, consecutiveDays: $consecutiveDays, pointsEarned: $pointsEarned, coinsEarned: $coinsEarned)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is CheckinModel &&
      other.id == id &&
      other.userId == userId &&
      other.checkinDate == checkinDate &&
      other.consecutiveDays == consecutiveDays &&
      other.pointsEarned == pointsEarned &&
      other.coinsEarned == coinsEarned;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      checkinDate.hashCode ^
      consecutiveDays.hashCode ^
      pointsEarned.hashCode ^
      coinsEarned.hashCode;
  }
} 