class NotificationModel {
  final String id;
  final String userId;
  final String type; // system, interaction, level_up, reward
  final String title;
  final String content;
  final String? targetType; // post, comment, channel, user
  final String? targetId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    this.targetType,
    this.targetId,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? content,
    String? targetType,
    String? targetId,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'content': content,
      'target_type': targetType,
      'target_id': targetId,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      targetType: map['target_type'] as String?,
      targetId: map['target_id'] as String?,
      isRead: map['is_read'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, type: $type, title: $title, content: $content, targetType: $targetType, targetId: $targetId, isRead: $isRead, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is NotificationModel &&
      other.id == id &&
      other.userId == userId &&
      other.type == type &&
      other.title == title &&
      other.content == content &&
      other.targetType == targetType &&
      other.targetId == targetId &&
      other.isRead == isRead &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      type.hashCode ^
      title.hashCode ^
      content.hashCode ^
      targetType.hashCode ^
      targetId.hashCode ^
      isRead.hashCode ^
      createdAt.hashCode;
  }
} 