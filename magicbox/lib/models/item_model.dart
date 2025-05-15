// lib/models/item_model.dart
import 'package:uuid/uuid.dart';

enum ItemStatus {
  ACTIVE,
  ARCHIVED,
  DELETED,
}

class ItemModel {
  final String id;
  final String name;
  final String boxId;
  final String? description;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;
  final ItemStatus status;
  final bool isPublic;
  final Map<String, dynamic>? shareSettings;
  final Map<String, dynamic>? advancedProperties;
  final List<String> tags;
  final bool isFavorite;
  final int viewCount;
  final int copyCount;
  final String? watermarkText;

  ItemModel({
    String? id,
    required this.name,
    required this.boxId,
    this.description,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.metadata,
    this.status = ItemStatus.ACTIVE,
    this.isPublic = false,
    this.shareSettings,
    this.advancedProperties,
    List<String>? tags,
    this.isFavorite = false,
    this.viewCount = 0,
    this.copyCount = 0,
    this.watermarkText,
  })  : id = id ?? const Uuid().v4(),
        images = images ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tags = tags ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'box_id': boxId,
      'description': description,
      'images': images,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
      'status': status.toString(),
      'is_public': isPublic,
      'share_settings': shareSettings,
      'advanced_properties': advancedProperties,
      'tags': tags,
      'is_favorite': isFavorite,
      'view_count': viewCount,
      'copy_count': copyCount,
      'watermark_text': watermarkText,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'],
      name: map['name'],
      boxId: map['box_id'],
      description: map['description'],
      images: List<String>.from(map['images'] ?? []),
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      metadata: map['metadata'],
      status: ItemStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ItemStatus.ACTIVE,
      ),
      isPublic: map['is_public'] ?? false,
      shareSettings: map['share_settings'],
      advancedProperties: map['advanced_properties'],
      tags: List<String>.from(map['tags'] ?? []),
      isFavorite: map['is_favorite'] ?? false,
      viewCount: map['view_count'] ?? 0,
      copyCount: map['copy_count'] ?? 0,
      watermarkText: map['watermark_text'],
    );
  }

  ItemModel copyWith({
    String? name,
    String? description,
    List<String>? images,
    Map<String, dynamic>? metadata,
    ItemStatus? status,
    bool? isPublic,
    Map<String, dynamic>? shareSettings,
    Map<String, dynamic>? advancedProperties,
    List<String>? tags,
    bool? isFavorite,
    int? viewCount,
    int? copyCount,
    String? watermarkText,
  }) {
    return ItemModel(
      id: id,
      name: name ?? this.name,
      boxId: boxId,
      description: description ?? this.description,
      images: images ?? this.images,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      metadata: metadata ?? this.metadata,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      shareSettings: shareSettings ?? this.shareSettings,
      advancedProperties: advancedProperties ?? this.advancedProperties,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      viewCount: viewCount ?? this.viewCount,
      copyCount: copyCount ?? this.copyCount,
      watermarkText: watermarkText ?? this.watermarkText,
    );
  }

  // 检查是否允许查看
  bool isViewable(String userId) {
    if (isPublic) return true;
    return shareSettings?['allowed_viewers']?.contains(userId) ?? false;
  }

  // 检查是否允许编辑
  bool isEditable(String userId) {
    return shareSettings?['allowed_editors']?.contains(userId) ?? false;
  }

  // 检查是否允许下载原图
  bool allowsOriginalImageDownload(String userId) {
    if (!isViewable(userId)) return false;
    return shareSettings?['allow_download'] ?? false;
  }

  // 检查是否允许复制
  bool allowsCopy(String userId) {
    if (!isViewable(userId)) return false;
    return shareSettings?['allow_copy'] ?? false;
  }

  // 获取高级属性值
  dynamic getAdvancedProperty(String key) {
    return advancedProperties?[key];
  }

  // 设置高级属性值
  ItemModel setAdvancedProperty(String key, dynamic value) {
    final newProperties = Map<String, dynamic>.from(advancedProperties ?? {});
    newProperties[key] = value;
    return copyWith(advancedProperties: newProperties);
  }

  // 增加查看次数
  ItemModel incrementViewCount() {
    return copyWith(viewCount: viewCount + 1);
  }

  // 增加复制次数
  ItemModel incrementCopyCount() {
    return copyWith(copyCount: copyCount + 1);
  }
}
