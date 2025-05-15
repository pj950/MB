import 'package:uuid/uuid.dart';

enum RepositoryType {
  PERSONAL,
  FAMILY,
}

class RepositoryModel {
  final String id;
  final String name;
  final String? coverImage;
  final String ownerId;
  final RepositoryType type;
  final int maxBoxes;
  final int maxItems;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? metadata;
  final bool isPublic;
  final String? password;
  final List<String> memberIds;
  final Map<String, dynamic>? visualizationSettings;

  RepositoryModel({
    String? id,
    required this.name,
    this.coverImage,
    required this.ownerId,
    required this.type,
    required this.maxBoxes,
    required this.maxItems,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.metadata,
    this.isPublic = false,
    this.password,
    List<String>? memberIds,
    this.visualizationSettings,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        memberIds = memberIds ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cover_image': coverImage,
      'owner_id': ownerId,
      'type': type.toString(),
      'max_boxes': maxBoxes,
      'max_items': maxItems,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'metadata': metadata,
      'is_public': isPublic,
      'password': password,
      'member_ids': memberIds,
      'visualization_settings': visualizationSettings,
    };
  }

  factory RepositoryModel.fromMap(Map<String, dynamic> map) {
    return RepositoryModel(
      id: map['id'],
      name: map['name'],
      coverImage: map['cover_image'],
      ownerId: map['owner_id'],
      type: RepositoryType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => RepositoryType.PERSONAL,
      ),
      maxBoxes: map['max_boxes'],
      maxItems: map['max_items'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      metadata: map['metadata'],
      isPublic: map['is_public'] ?? false,
      password: map['password'],
      memberIds: List<String>.from(map['member_ids'] ?? []),
      visualizationSettings: map['visualization_settings'],
    );
  }

  RepositoryModel copyWith({
    String? name,
    String? coverImage,
    RepositoryType? type,
    int? maxBoxes,
    int? maxItems,
    Map<String, dynamic>? metadata,
    bool? isPublic,
    String? password,
    List<String>? memberIds,
    Map<String, dynamic>? visualizationSettings,
  }) {
    return RepositoryModel(
      id: id,
      name: name ?? this.name,
      coverImage: coverImage ?? this.coverImage,
      ownerId: ownerId,
      type: type ?? this.type,
      maxBoxes: maxBoxes ?? this.maxBoxes,
      maxItems: maxItems ?? this.maxItems,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      metadata: metadata ?? this.metadata,
      isPublic: isPublic ?? this.isPublic,
      password: password ?? this.password,
      memberIds: memberIds ?? this.memberIds,
      visualizationSettings: visualizationSettings ?? this.visualizationSettings,
    );
  }

  // 检查是否达到盒子数量限制
  bool hasReachedBoxLimit(int currentBoxCount) {
    return currentBoxCount >= maxBoxes;
  }

  // 检查是否达到物品数量限制
  bool hasReachedItemLimit(int currentItemCount) {
    return currentItemCount >= maxItems;
  }

  // 检查用户是否有权限访问
  bool hasAccess(String userId) {
    return ownerId == userId || memberIds.contains(userId);
  }

  // 检查用户是否是管理员
  bool isAdmin(String userId) {
    return ownerId == userId;
  }
} 