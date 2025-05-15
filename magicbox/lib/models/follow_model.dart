class FollowModel {
  final int? id;
  final int followerId;
  final int followingId;
  final DateTime createdAt;
  final DateTime updatedAt;

  FollowModel({
    this.id,
    required this.followerId,
    required this.followingId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  FollowModel copyWith({
    int? id,
    int? followerId,
    int? followingId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FollowModel(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followingId: followingId ?? this.followingId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FollowModel.fromMap(Map<String, dynamic> map) {
    return FollowModel(
      id: map['id'] as int,
      followerId: map['follower_id'] as int,
      followingId: map['following_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
} 