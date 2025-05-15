import 'package:flutter/material.dart';

class VoteModel {
  final int? id;
  final int channelId;
  final int creatorId;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final bool isMultipleChoice;
  final bool isAnonymous;
  final String status; // 'active', 'ended', 'cancelled'
  final int totalVotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  VoteModel({
    this.id,
    required this.channelId,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.startTime,
    required this.endTime,
    this.isMultipleChoice = false,
    this.isAnonymous = false,
    this.status = 'active',
    this.totalVotes = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  VoteModel copyWith({
    int? id,
    int? channelId,
    int? creatorId,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    bool? isMultipleChoice,
    bool? isAnonymous,
    String? status,
    int? totalVotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VoteModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isMultipleChoice: isMultipleChoice ?? this.isMultipleChoice,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      totalVotes: totalVotes ?? this.totalVotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'channel_id': channelId,
      'creator_id': creatorId,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'is_multiple_choice': isMultipleChoice ? 1 : 0,
      'is_anonymous': isAnonymous ? 1 : 0,
      'status': status,
      'total_votes': totalVotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory VoteModel.fromMap(Map<String, dynamic> map) {
    return VoteModel(
      id: map['id'] as int,
      channelId: map['channel_id'] as int,
      creatorId: map['creator_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      startTime: DateTime.parse(map['start_time'] as String),
      endTime: DateTime.parse(map['end_time'] as String),
      isMultipleChoice: map['is_multiple_choice'] == 1,
      isAnonymous: map['is_anonymous'] == 1,
      status: map['status'] as String,
      totalVotes: map['total_votes'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class VoteOptionModel {
  final int? id;
  final int voteId;
  final String content;
  final int voteCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  VoteOptionModel({
    this.id,
    required this.voteId,
    required this.content,
    this.voteCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  VoteOptionModel copyWith({
    int? id,
    int? voteId,
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
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory VoteOptionModel.fromMap(Map<String, dynamic> map) {
    return VoteOptionModel(
      id: map['id'] as int,
      voteId: map['vote_id'] as int,
      content: map['content'] as String,
      voteCount: map['vote_count'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class VoteRecordModel {
  final int? id;
  final int voteId;
  final int userId;
  final List<int> optionIds;
  final DateTime createdAt;

  VoteRecordModel({
    this.id,
    required this.voteId,
    required this.userId,
    required this.optionIds,
    required this.createdAt,
  });

  VoteRecordModel copyWith({
    int? id,
    int? voteId,
    int? userId,
    List<int>? optionIds,
    DateTime? createdAt,
  }) {
    return VoteRecordModel(
      id: id ?? this.id,
      voteId: voteId ?? this.voteId,
      userId: userId ?? this.userId,
      optionIds: optionIds ?? this.optionIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vote_id': voteId,
      'user_id': userId,
      'option_ids': optionIds.join(','),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory VoteRecordModel.fromMap(Map<String, dynamic> map) {
    return VoteRecordModel(
      id: map['id'] as int,
      voteId: map['vote_id'] as int,
      userId: map['user_id'] as int,
      optionIds: (map['option_ids'] as String).split(',').map((e) => int.parse(e)).toList(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
} 