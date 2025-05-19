import 'package:uuid/uuid.dart';

enum SearchResultType {
  POST,
  CHANNEL,
  USER,
  ITEM,
  BOX,
  REPOSITORY,
}

class SearchResultModel {
  final String id;
  final SearchResultType type;
  final String title;
  final String? description;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? relevanceScore;
  final List<String>? tags;
  final bool isActive;

  SearchResultModel({
    String? id,
    required this.type,
    required this.title,
    this.description,
    this.imageUrl,
    this.metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.relevanceScore,
    List<String>? tags,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tags = tags ?? [];

  SearchResultModel copyWith({
    String? id,
    SearchResultType? type,
    String? title,
    String? description,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? relevanceScore,
    List<String>? tags,
    bool? isActive,
  }) {
    return SearchResultModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      relevanceScore: relevanceScore ?? this.relevanceScore,
      tags: tags ?? this.tags,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'relevance_score': relevanceScore,
      'tags': tags,
      'isactive': isActive,
    };
  }

  factory SearchResultModel.fromMap(Map<String, dynamic> map) {
    return SearchResultModel(
      id: map['id'] as String,
      type: SearchResultType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => SearchResultType.POST,
      ),
      title: map['title'] as String,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      relevanceScore: map['relevance_score'] as double?,
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isActive: map['isactive'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'SearchResultModel(id: $id, type: $type, title: $title, description: $description, imageUrl: $imageUrl, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, relevanceScore: $relevanceScore, tags: $tags, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SearchResultModel &&
        other.id == id &&
        other.type == type &&
        other.title == title &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.metadata == metadata &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.relevanceScore == relevanceScore &&
        other.tags == tags &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        title.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        metadata.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        relevanceScore.hashCode ^
        tags.hashCode ^
        isActive.hashCode;
  }
}
