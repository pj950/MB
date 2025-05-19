// lib/models/box_model.dart
import 'package:uuid/uuid.dart';

enum BoxType {
  WARDROBE, // 衣柜
  BOOKSHELF, // 书架
  COLLECTION, // 收藏
  CUSTOM // 自定义
}

enum BoxAccessLevel {
  PRIVATE,
  PUBLIC,
  PASSWORD_PROTECTED,
  MEMBERS_ONLY,
}

class BoxModel {
  final String id;
  final String userId;
  final String repositoryId;
  final String creatorId;
  final String name;
  final String? description;
  final String? imagePath;
  final BoxType type;
  final bool isPublic;
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? shareSettings;
  final Map<String, dynamic>? advancedProperties;
  final List<String> tags;
  final int viewCount;
  final int copyCount;
  final int itemCount;
  final bool hasExpiredItems;
  final int orderIndex;
  final String themeColor;
  final BoxAccessLevel accessLevel;
  final String? password;
  final List<String> allowedUserIds;

  BoxModel({
    String? id,
    required this.userId,
    required this.repositoryId,
    required this.creatorId,
    required this.name,
    this.description,
    this.imagePath,
    this.type = BoxType.CUSTOM,
    this.isPublic = false,
    this.isPinned = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.shareSettings,
    this.advancedProperties,
    List<String>? tags,
    this.viewCount = 0,
    this.copyCount = 0,
    this.itemCount = 0,
    this.hasExpiredItems = false,
    this.orderIndex = 0,
    this.themeColor = '#4A90E2',
    this.accessLevel = BoxAccessLevel.PRIVATE,
    this.password,
    List<String>? allowedUserIds,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tags = tags ?? [],
        allowedUserIds = allowedUserIds ?? [];

  // 将数据库记录转成Box对象
  factory BoxModel.fromMap(Map<String, dynamic> map) {
    return BoxModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      repositoryId: map['repository_id'] as String,
      creatorId: map['creator_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      imagePath: map['image_path'] as String?,
      type: BoxType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => BoxType.CUSTOM,
      ),
      isPublic: map['isPublic'] == 1,
      isPinned: map['isPinned'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      shareSettings: map['share_settings'] as Map<String, dynamic>?,
      advancedProperties: map['advanced_properties'] as Map<String, dynamic>?,
      tags: (map['tags'] as String?)?.split(',') ?? [],
      viewCount: map['view_count'] ?? 0,
      copyCount: map['copy_count'] ?? 0,
      itemCount: map['item_count'] ?? 0,
      hasExpiredItems: map['has_expired_items'] == 1,
      orderIndex: map['order_index'] ?? 0,
      themeColor: map['theme_color'] as String? ?? '#4A90E2',
      accessLevel: BoxAccessLevel.values.firstWhere(
        (e) => e.toString() == map['access_level'],
        orElse: () => BoxAccessLevel.PRIVATE,
      ),
      password: map['password'] as String?,
      allowedUserIds: (map['allowed_user_ids'] as String?)?.split(',') ?? [],
    );
  }

  // 将Box对象转成可插入数据库的Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'repository_id': repositoryId,
      'creator_id': creatorId,
      'name': name,
      'description': description,
      'image_path': imagePath,
      'type': type.toString(),
      'isPublic': isPublic ? 1 : 0,
      'isPinned': isPinned ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'share_settings': shareSettings,
      'advanced_properties': advancedProperties,
      'tags': tags.join(','),
      'view_count': viewCount,
      'copy_count': copyCount,
      'item_count': itemCount,
      'has_expired_items': hasExpiredItems ? 1 : 0,
      'order_index': orderIndex,
      'theme_color': themeColor,
      'access_level': accessLevel.toString(),
      'password': password,
      'allowed_user_ids': allowedUserIds.join(','),
    };
  }

  BoxModel copyWith({
    String? id,
    String? userId,
    String? repositoryId,
    String? creatorId,
    String? name,
    String? description,
    String? imagePath,
    BoxType? type,
    bool? isPublic,
    bool? isPinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? shareSettings,
    Map<String, dynamic>? advancedProperties,
    List<String>? tags,
    int? viewCount,
    int? copyCount,
    int? itemCount,
    bool? hasExpiredItems,
    int? orderIndex,
    String? themeColor,
    BoxAccessLevel? accessLevel,
    String? password,
    List<String>? allowedUserIds,
  }) {
    return BoxModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      repositoryId: repositoryId ?? this.repositoryId,
      creatorId: creatorId ?? this.creatorId,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      type: type ?? this.type,
      isPublic: isPublic ?? this.isPublic,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shareSettings: shareSettings ?? this.shareSettings,
      advancedProperties: advancedProperties ?? this.advancedProperties,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      copyCount: copyCount ?? this.copyCount,
      itemCount: itemCount ?? this.itemCount,
      hasExpiredItems: hasExpiredItems ?? this.hasExpiredItems,
      orderIndex: orderIndex ?? this.orderIndex,
      themeColor: themeColor ?? this.themeColor,
      accessLevel: accessLevel ?? this.accessLevel,
      password: password ?? this.password,
      allowedUserIds: allowedUserIds ?? this.allowedUserIds,
    );
  }

  // 检查用户是否有权限访问
  bool hasAccess(String userId) {
    if (isPublic) return true;
    return shareSettings?['allowed_viewers']?.contains(userId) ?? false;
  }

  // 检查用户是否有编辑权限
  bool hasEditPermission(String userId) {
    return shareSettings?['allowed_editors']?.contains(userId) ?? false;
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
