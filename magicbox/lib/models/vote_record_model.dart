class VoteRecordModel {
  final String id;
  final String voteId;
  final String optionId;
  final String userId;
  final DateTime createdAt;

  VoteRecordModel({
    required this.id,
    required this.voteId,
    required this.optionId,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vote_id': voteId,
      'option_id': optionId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VoteRecordModel.fromMap(Map<String, dynamic> map) {
    return VoteRecordModel(
      id: map['id'] as String,
      voteId: map['vote_id'] as String,
      optionId: map['option_id'] as String,
      userId: map['user_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  VoteRecordModel copyWith({
    String? id,
    String? voteId,
    String? optionId,
    String? userId,
    DateTime? createdAt,
  }) {
    return VoteRecordModel(
      id: id ?? this.id,
      voteId: voteId ?? this.voteId,
      optionId: optionId ?? this.optionId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 