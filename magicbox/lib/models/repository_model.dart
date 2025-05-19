import 'package:uuid/uuid.dart';

class RepositoryModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final List<String> boxIds;

  RepositoryModel({
    String? id,
    required this.userId,
    required this.name,
    this.description,
    this.isPublic = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.isActive,
    required this.boxIds,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get boxCount => boxIds.length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'isPublic': isPublic ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'boxIds': boxIds.join(','),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RepositoryModel.fromMap(Map<String, dynamic> map) {
    return RepositoryModel(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString() ?? '',
      name: map['name'] ?? '',
      description: map['description']?.toString(),
      isPublic: map['isPublic'] == 1,
      isActive: map['isActive'] == 1,
      boxIds: (map['boxIds'] as String?)?.split(',') ?? [],
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  RepositoryModel copyWith({
    String? name,
    String? description,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? boxIds,
  }) {
    return RepositoryModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      boxIds: boxIds ?? this.boxIds,
    );
  }

  // 检查用户是否有权限访问
  bool hasAccess(String userId) {
    if (isPublic) return true;
    return this.userId == userId;
  }

  // 检查用户是否是管理员
  bool isAdmin(String userId) {
    return this.userId == userId;
  }
}
