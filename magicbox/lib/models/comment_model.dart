class CommentModel {
  final int? id;
  final int postId;
  final String authorId;
  final String content;
  final int? parentId;
  final int likeCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentModel({
    this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    this.parentId,
    this.likeCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  CommentModel copyWith({
    int? id,
    int? postId,
    String? authorId,
    String? content,
    int? parentId,
    int? likeCount,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      parentId: parentId ?? this.parentId,
      likeCount: likeCount ?? this.likeCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'post_id': postId,
      'author_id': authorId,
      'content': content,
      'parent_id': parentId,
      'like_count': likeCount,
      'isactive': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] as int,
      postId: map['post_id'] as int,
      authorId: map['author_id'] as String,
      content: map['content'] as String,
      parentId: map['parent_id'] as int?,
      likeCount: map['like_count'] as int,
      isActive: map['isactive'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
