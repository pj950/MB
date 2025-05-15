import 'package:uuid/uuid.dart';

class HelpArticle {
  final String id;
  final String title;
  final String content;
  final String category;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  HelpArticle({
    String? id,
    required this.title,
    required this.content,
    required this.category,
    required this.order,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory HelpArticle.fromMap(Map<String, dynamic> map) {
    return HelpArticle(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      order: map['order'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  HelpArticle copyWith({
    String? title,
    String? content,
    String? category,
    int? order,
    DateTime? updatedAt,
  }) {
    return HelpArticle(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      order: order ?? this.order,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

class FAQ {
  final String id;
  final String question;
  final String answer;
  final String category;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  FAQ({
    String? id,
    required this.question,
    required this.answer,
    required this.category,
    required this.order,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'order': order,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory FAQ.fromMap(Map<String, dynamic> map) {
    return FAQ(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
      category: map['category'],
      order: map['order'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  FAQ copyWith({
    String? question,
    String? answer,
    String? category,
    int? order,
    DateTime? updatedAt,
  }) {
    return FAQ(
      id: id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      order: order ?? this.order,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
} 