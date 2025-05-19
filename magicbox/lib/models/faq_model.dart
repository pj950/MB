import 'package:uuid/uuid.dart';

class FAQModel {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int order;
  final List<String>? tags;
  final String? author;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublished;
  final int viewCount;
  final int helpfulCount;
  final int notHelpfulCount;
  final List<String>? relatedFAQs;
  final Map<String, dynamic>? metadata;

  FAQModel({
    String? id,
    required this.question,
    required this.answer,
    required this.category,
    required this.order,
    this.tags,
    this.author,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isPublished = true,
    this.viewCount = 0,
    this.helpfulCount = 0,
    this.notHelpfulCount = 0,
    this.relatedFAQs,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  FAQModel copyWith({
    String? id,
    String? question,
    String? answer,
    String? category,
    int? order,
    List<String>? tags,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublished,
    int? viewCount,
    int? helpfulCount,
    int? notHelpfulCount,
    List<String>? relatedFAQs,
    Map<String, dynamic>? metadata,
  }) {
    return FAQModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      order: order ?? this.order,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      viewCount: viewCount ?? this.viewCount,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      notHelpfulCount: notHelpfulCount ?? this.notHelpfulCount,
      relatedFAQs: relatedFAQs ?? this.relatedFAQs,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'order': order,
      'tags': tags,
      'author': author,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'ispublished': isPublished,
      'view_count': viewCount,
      'helpful_count': helpfulCount,
      'not_helpful_count': notHelpfulCount,
      'related_faqs': relatedFAQs,
      'metadata': metadata,
    };
  }

  factory FAQModel.fromMap(Map<String, dynamic> map) {
    return FAQModel(
      id: map['id'] as String,
      question: map['question'] as String,
      answer: map['answer'] as String,
      category: map['category'] as String,
      order: map['order'] as int,
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      author: map['author'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      isPublished: map['ispublished'] as bool? ?? true,
      viewCount: map['view_count'] as int? ?? 0,
      helpfulCount: map['helpful_count'] as int? ?? 0,
      notHelpfulCount: map['not_helpful_count'] as int? ?? 0,
      relatedFAQs: (map['related_faqs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'FAQModel(id: $id, question: $question, answer: $answer, category: $category, order: $order, tags: $tags, author: $author, createdAt: $createdAt, updatedAt: $updatedAt, isPublished: $isPublished, viewCount: $viewCount, helpfulCount: $helpfulCount, notHelpfulCount: $notHelpfulCount, relatedFAQs: $relatedFAQs, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FAQModel &&
        other.id == id &&
        other.question == question &&
        other.answer == answer &&
        other.category == category &&
        other.order == order &&
        other.tags == tags &&
        other.author == author &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isPublished == isPublished &&
        other.viewCount == viewCount &&
        other.helpfulCount == helpfulCount &&
        other.notHelpfulCount == notHelpfulCount &&
        other.relatedFAQs == relatedFAQs &&
        other.metadata == metadata;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        question.hashCode ^
        answer.hashCode ^
        category.hashCode ^
        order.hashCode ^
        tags.hashCode ^
        author.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isPublished.hashCode ^
        viewCount.hashCode ^
        helpfulCount.hashCode ^
        notHelpfulCount.hashCode ^
        relatedFAQs.hashCode ^
        metadata.hashCode;
  }
}
