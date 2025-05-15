import 'package:get/get.dart';

class ChannelModel {
  final int? id;
  final String name;
  final String description;
  final String coverImage;
  final String themeColor;
  final int ownerId;
  final int moderatorId;
  final int postCount;
  final int memberCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChannelModel({
    this.id,
    required this.name,
    required this.description,
    required this.coverImage,
    required this.themeColor,
    required this.ownerId,
    required this.moderatorId,
    this.postCount = 0,
    this.memberCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  ChannelModel copyWith({
    int? id,
    String? name,
    String? description,
    String? coverImage,
    String? themeColor,
    int? ownerId,
    int? moderatorId,
    int? postCount,
    int? memberCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChannelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      themeColor: themeColor ?? this.themeColor,
      ownerId: ownerId ?? this.ownerId,
      moderatorId: moderatorId ?? this.moderatorId,
      postCount: postCount ?? this.postCount,
      memberCount: memberCount ?? this.memberCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'themeColor': themeColor,
      'ownerId': ownerId,
      'moderatorId': moderatorId,
      'postCount': postCount,
      'memberCount': memberCount,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChannelModel.fromMap(Map<String, dynamic> map) {
    return ChannelModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      coverImage: map['coverImage'],
      themeColor: map['themeColor'],
      ownerId: map['ownerId'],
      moderatorId: map['moderatorId'],
      postCount: map['postCount'],
      memberCount: map['memberCount'],
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
} 