class ModeratorModel {
  final int? id;
  final int userId;
  final int channelId;
  final String role; // 'owner', 'admin', 'moderator'
  final List<String> permissions;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ModeratorModel({
    this.id,
    required this.userId,
    required this.channelId,
    required this.role,
    required this.permissions,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  ModeratorModel copyWith({
    int? id,
    int? userId,
    int? channelId,
    String? role,
    List<String>? permissions,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ModeratorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      channelId: channelId ?? this.channelId,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'channel_id': channelId,
      'role': role,
      'permissions': permissions.join(','),
      'isactive': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ModeratorModel.fromMap(Map<String, dynamic> map) {
    return ModeratorModel(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      channelId: map['channel_id'] as int,
      role: map['role'] as String,
      permissions: (map['permissions'] as String).split(','),
      isActive: map['isactive'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class ModeratorApplicationModel {
  final int? id;
  final int userId;
  final int channelId;
  final String reason;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  ModeratorApplicationModel({
    this.id,
    required this.userId,
    required this.channelId,
    required this.reason,
    required this.status,
    this.rejectReason,
    required this.createdAt,
    required this.updatedAt,
  });

  ModeratorApplicationModel copyWith({
    int? id,
    int? userId,
    int? channelId,
    String? reason,
    String? status,
    String? rejectReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ModeratorApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      channelId: channelId ?? this.channelId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'channel_id': channelId,
      'reason': reason,
      'status': status,
      'reject_reason': rejectReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ModeratorApplicationModel.fromMap(Map<String, dynamic> map) {
    return ModeratorApplicationModel(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      channelId: map['channel_id'] as int,
      reason: map['reason'] as String,
      status: map['status'] as String,
      rejectReason: map['reject_reason'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class ModeratorLogModel {
  final int? id;
  final int moderatorId;
  final int channelId;
  final String action; // 'delete_post', 'delete_comment', 'ban_user', etc.
  final String targetType; // 'post', 'comment', 'user'
  final int targetId;
  final String reason;
  final DateTime createdAt;

  ModeratorLogModel({
    this.id,
    required this.moderatorId,
    required this.channelId,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.reason,
    required this.createdAt,
  });

  ModeratorLogModel copyWith({
    int? id,
    int? moderatorId,
    int? channelId,
    String? action,
    String? targetType,
    int? targetId,
    String? reason,
    DateTime? createdAt,
  }) {
    return ModeratorLogModel(
      id: id ?? this.id,
      moderatorId: moderatorId ?? this.moderatorId,
      channelId: channelId ?? this.channelId,
      action: action ?? this.action,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moderator_id': moderatorId,
      'channel_id': channelId,
      'action': action,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ModeratorLogModel.fromMap(Map<String, dynamic> map) {
    return ModeratorLogModel(
      id: map['id'] as int,
      moderatorId: map['moderator_id'] as int,
      channelId: map['channel_id'] as int,
      action: map['action'] as String,
      targetType: map['target_type'] as String,
      targetId: map['target_id'] as int,
      reason: map['reason'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
