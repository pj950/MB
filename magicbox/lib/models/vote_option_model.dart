class VoteOptionModel {
  final String id;
  final String voteId;
  final String content;
  final int voteCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VoteOptionModel({
    required this.id,
    required this.voteId,
    required this.content,
    required this.voteCount,
    required this.createdAt,
    this.updatedAt,
  });

  VoteOptionModel copyWith({
    String? id,
    String? voteId,
    String? content,
    int? voteCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VoteOptionModel(
      id: id ?? this.id,
      voteId: voteId ?? this.voteId,
      content: content ?? this.content,
      voteCount: voteCount ?? this.voteCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vote_id': voteId,
      'content': content,
      'vote_count': voteCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory VoteOptionModel.fromMap(Map<String, dynamic> map) {
    return VoteOptionModel(
      id: map['id'] as String,
      voteId: map['vote_id'] as String,
      content: map['content'] as String,
      voteCount: map['vote_count'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'VoteOptionModel(id: $id, voteId: $voteId, content: $content, voteCount: $voteCount, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is VoteOptionModel &&
      other.id == id &&
      other.voteId == voteId &&
      other.content == content &&
      other.voteCount == voteCount &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      voteId.hashCode ^
      content.hashCode ^
      voteCount.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
  }
} 