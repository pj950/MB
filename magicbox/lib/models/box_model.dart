// lib/models/box_model.dart
import 'package:uuid/uuid.dart';

enum BoxType {
  WARDROBE,    // 衣柜
  BOOKSHELF,   // 书架
  COLLECTION,  // 收藏
  CUSTOM      // 自定义
}

enum BoxAccessLevel {
  PRIVATE,
  PUBLIC,
  PASSWORD_PROTECTED,
  MEMBERS_ONLY,
}

class BoxModel {
  final String id;
  final String name;
  final String repositoryId;
  final BoxType type;
  final String? description;
  final int orderIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;
  final BoxAccessLevel accessLevel;
  final String? password;
  final List<String> allowedUserIds;
  final Map<String, dynamic>? shareSettings;
  final bool isPinned;
  final int itemCount;
  final List<String> tags;

  BoxModel({
    String? id,
    required this.name,
    required this.repositoryId,
    required this.type,
    this.description,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.metadata,
    this.accessLevel = BoxAccessLevel.PRIVATE,
    this.password,
    List<String>? allowedUserIds,
    this.shareSettings,
    this.isPinned = false,
    this.itemCount = 0,
    List<String>? tags,
  })  : id = id ?? const Uuid().v4(),
        orderIndex = orderIndex ?? 0,
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        allowedUserIds = allowedUserIds ?? [],
        tags = tags ?? [];

  // 将数据库记录转成Box对象
  factory BoxModel.fromMap(Map<String, dynamic> map) {
    return BoxModel(
      id: map['id'],
      name: map['name'],
      repositoryId: map['repository_id'],
      type: BoxType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => BoxType.CUSTOM,
      ),
      description: map['description'],
      orderIndex: map['order_index'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      metadata: map['metadata'],
      accessLevel: BoxAccessLevel.values.firstWhere(
        (e) => e.toString() == map['access_level'],
        orElse: () => BoxAccessLevel.PRIVATE,
      ),
      password: map['password'],
      allowedUserIds: List<String>.from(map['allowed_user_ids'] ?? []),
      shareSettings: map['share_settings'],
      isPinned: map['is_pinned'] ?? false,
      itemCount: map['item_count'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  // 将Box对象转成可插入数据库的Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'repository_id': repositoryId,
      'type': type.toString(),
      'description': description,
      'order_index': orderIndex,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
      'access_level': accessLevel.toString(),
      'password': password,
      'allowed_user_ids': allowedUserIds,
      'share_settings': shareSettings,
      'is_pinned': isPinned,
      'item_count': itemCount,
      'tags': tags,
    };
  }

  BoxModel copyWith({
    String? name,
    BoxType? type,
    String? description,
    int? orderIndex,
    Map<String, dynamic>? metadata,
    BoxAccessLevel? accessLevel,
    String? password,
    List<String>? allowedUserIds,
    Map<String, dynamic>? shareSettings,
    bool? isPinned,
    int? itemCount,
    List<String>? tags,
  }) {
    return BoxModel(
      id: id,
      name: name ?? this.name,
      repositoryId: repositoryId,
      type: type ?? this.type,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      metadata: metadata ?? this.metadata,
      accessLevel: accessLevel ?? this.accessLevel,
      password: password ?? this.password,
      allowedUserIds: allowedUserIds ?? this.allowedUserIds,
      shareSettings: shareSettings ?? this.shareSettings,
      isPinned: isPinned ?? this.isPinned,
      itemCount: itemCount ?? this.itemCount,
      tags: tags ?? this.tags,
    );
  }

  // 检查用户是否有权限访问
  bool hasAccess(String userId, {String? inputPassword}) {
    switch (accessLevel) {
      case BoxAccessLevel.PRIVATE:
        return allowedUserIds.contains(userId);
      case BoxAccessLevel.PUBLIC:
        return true;
      case BoxAccessLevel.PASSWORD_PROTECTED:
        return inputPassword == password;
      case BoxAccessLevel.MEMBERS_ONLY:
        return allowedUserIds.contains(userId);
    }
  }

  // 检查用户是否有编辑权限
  bool hasEditPermission(String userId) {
    return allowedUserIds.contains(userId);
  }

  // 检查是否允许复制物品
  bool allowsItemCopy() {
    return shareSettings?['allow_copy'] ?? false;
  }

  // 检查是否允许下载原图
  bool allowsOriginalImageDownload() {
    return shareSettings?['allow_download'] ?? false;
  }

  // 检查是否启用水印
  bool hasWatermarkEnabled() {
    return shareSettings?['watermark'] ?? false;
  }
}
