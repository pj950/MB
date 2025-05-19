import 'package:uuid/uuid.dart';

enum ModeratorActionType {
  DELETE_POST,
  DELETE_COMMENT,
  BAN_USER,
  UNBAN_USER,
  PIN_POST,
  UNPIN_POST,
  CLOSE_POST,
  REOPEN_POST,
  WARN_USER,
  MUTE_USER,
  UNMUTE_USER,
  CHANGE_ROLE,
}

class ModeratorLogModel {
  final String id;
  final String moderatorId;
  final String channelId;
  final ModeratorActionType action;
  final String targetType; // post, comment, user
  final String targetId;
  final String reason;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final bool isReversed;
  final String? reversedBy;
  final DateTime? reversedAt;
  final String? reversedReason;

  ModeratorLogModel({
    String? id,
    required this.moderatorId,
    required this.channelId,
    required this.action,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.metadata,
    DateTime? createdAt,
    this.isReversed = false,
    this.reversedBy,
    this.reversedAt,
    this.reversedReason,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  ModeratorLogModel copyWith({
    String? id,
    String? moderatorId,
    String? channelId,
    ModeratorActionType? action,
    String? targetType,
    String? targetId,
    String? reason,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    bool? isReversed,
    String? reversedBy,
    DateTime? reversedAt,
    String? reversedReason,
  }) {
    return ModeratorLogModel(
      id: id ?? this.id,
      moderatorId: moderatorId ?? this.moderatorId,
      channelId: channelId ?? this.channelId,
      action: action ?? this.action,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      reason: reason ?? this.reason,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      isReversed: isReversed ?? this.isReversed,
      reversedBy: reversedBy ?? this.reversedBy,
      reversedAt: reversedAt ?? this.reversedAt,
      reversedReason: reversedReason ?? this.reversedReason,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'moderator_id': moderatorId,
      'channel_id': channelId,
      'action': action.toString(),
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'isreversed': isReversed,
      'reversed_by': reversedBy,
      'reversed_at': reversedAt?.toIso8601String(),
      'reversed_reason': reversedReason,
    };
  }

  factory ModeratorLogModel.fromMap(Map<String, dynamic> map) {
    return ModeratorLogModel(
      id: map['id'] as String,
      moderatorId: map['moderator_id'] as String,
      channelId: map['channel_id'] as String,
      action: ModeratorActionType.values.firstWhere(
        (e) => e.toString() == map['action'],
        orElse: () => ModeratorActionType.DELETE_POST,
      ),
      targetType: map['target_type'] as String,
      targetId: map['target_id'] as String,
      reason: map['reason'] as String,
      metadata: map['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(map['created_at'] as String),
      isReversed: map['isreversed'] as bool? ?? false,
      reversedBy: map['reversed_by'] as String?,
      reversedAt: map['reversed_at'] != null
          ? DateTime.parse(map['reversed_at'] as String)
          : null,
      reversedReason: map['reversed_reason'] as String?,
    );
  }

  @override
  String toString() {
    return 'ModeratorLogModel(id: $id, moderatorId: $moderatorId, channelId: $channelId, action: $action, targetType: $targetType, targetId: $targetId, reason: $reason, metadata: $metadata, createdAt: $createdAt, isReversed: $isReversed, reversedBy: $reversedBy, reversedAt: $reversedAt, reversedReason: $reversedReason)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ModeratorLogModel &&
        other.id == id &&
        other.moderatorId == moderatorId &&
        other.channelId == channelId &&
        other.action == action &&
        other.targetType == targetType &&
        other.targetId == targetId &&
        other.reason == reason &&
        other.metadata == metadata &&
        other.createdAt == createdAt &&
        other.isReversed == isReversed &&
        other.reversedBy == reversedBy &&
        other.reversedAt == reversedAt &&
        other.reversedReason == reversedReason;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        moderatorId.hashCode ^
        channelId.hashCode ^
        action.hashCode ^
        targetType.hashCode ^
        targetId.hashCode ^
        reason.hashCode ^
        metadata.hashCode ^
        createdAt.hashCode ^
        isReversed.hashCode ^
        reversedBy.hashCode ^
        reversedAt.hashCode ^
        reversedReason.hashCode;
  }
}
