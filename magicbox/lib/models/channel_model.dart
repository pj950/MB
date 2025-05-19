import 'package:flutter/foundation.dart';

class ChannelModel {
  final String id;
  final String name;
  final String description;
  final String? coverImage;
  final bool isPrivate;
  final List<String> tags;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChannelModel({
    required this.id,
    required this.name,
    required this.description,
    this.coverImage,
    this.isPrivate = false,
    this.tags = const [],
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImage': coverImage,
      'isPrivate': isPrivate ? 1 : 0,
      'tags': tags.join(','),
      'ownerId': ownerId,
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
      isPrivate: map['isPrivate'] == 1,
      tags: map['tags']?.split(',') ?? [],
      ownerId: map['ownerId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  ChannelModel copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImage,
    bool? isPrivate,
    List<String>? tags,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChannelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      isPrivate: isPrivate ?? this.isPrivate,
      tags: tags ?? this.tags,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ChannelModel(id: $id, name: $name, description: $description, coverImage: $coverImage, isPrivate: $isPrivate, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ChannelModel &&
      other.id == id &&
      other.name == name &&
      other.description == description &&
      other.coverImage == coverImage &&
      other.isPrivate == isPrivate &&
      listEquals(other.tags, tags) &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      coverImage.hashCode ^
      isPrivate.hashCode ^
      tags.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
} 