import 'package:uuid/uuid.dart';

class HelpDocumentModel {
  final String id;
  final String title;
  final String content;
  final String category;
  final int order;
  final List<String>? tags;
  final String? author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final int viewCount;
  final double? rating;
  final int ratingCount;
  final List<String>? relatedDocuments;
  final Map<String, dynamic>? metadata;

  HelpDocumentModel({
    String? id,
    required this.title,
    required this.content,
    required this.category,
    required this.order,
    this.tags,
    this.author,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPublished = true,
    this.viewCount = 0,
    this.rating,
    this.ratingCount = 0,
    this.relatedDocuments,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  HelpDocumentModel copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    int? order,
    List<String>? tags,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    int? viewCount,
    double? rating,
    int? ratingCount,
    List<String>? relatedDocuments,
    Map<String, dynamic>? metadata,
  }) {
    return HelpDocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      order: order ?? this.order,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      viewCount: viewCount ?? this.viewCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      relatedDocuments: relatedDocuments ?? this.relatedDocuments,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'order': order,
      'tags': tags,
      'author': author,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_published': isPublished,
      'view_count': viewCount,
      'rating': rating,
      'rating_count': ratingCount,
      'related_documents': relatedDocuments,
      'metadata': metadata,
    };
  }

  factory HelpDocumentModel.fromMap(Map<String, dynamic> map) {
    return HelpDocumentModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String,
      order: map['order'] as int,
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      author: map['author'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isPublished: map['is_published'] as bool? ?? true,
      viewCount: map['view_count'] as int? ?? 0,
      rating: map['rating'] as double?,
      ratingCount: map['rating_count'] as int? ?? 0,
      relatedDocuments: (map['related_documents'] as List<dynamic>?)?.map((e) => e as String).toList(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'HelpDocumentModel(id: $id, title: $title, content: $content, category: $category, order: $order, tags: $tags, author: $author, createdAt: $createdAt, updatedAt: $updatedAt, isPublished: $isPublished, viewCount: $viewCount, rating: $rating, ratingCount: $ratingCount, relatedDocuments: $relatedDocuments, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is HelpDocumentModel &&
      other.id == id &&
      other.title == title &&
      other.content == content &&
      other.category == category &&
      other.order == order &&
      other.tags == tags &&
      other.author == author &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.isPublished == isPublished &&
      other.viewCount == viewCount &&
      other.rating == rating &&
      other.ratingCount == ratingCount &&
      other.relatedDocuments == relatedDocuments &&
      other.metadata == metadata;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      category.hashCode ^
      order.hashCode ^
      tags.hashCode ^
      author.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      isPublished.hashCode ^
      viewCount.hashCode ^
      rating.hashCode ^
      ratingCount.hashCode ^
      relatedDocuments.hashCode ^
      metadata.hashCode;
  }
} 