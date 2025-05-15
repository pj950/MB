import 'package:flutter/material.dart';

class ChannelApplicationModel {
  final int? id;
  final int userId;
  final String name;
  final String description;
  final String category;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChannelApplicationModel({
    this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.category,
    this.status = 'pending',
    this.rejectReason,
    required this.createdAt,
    required this.updatedAt,
  });

  ChannelApplicationModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? description,
    String? category,
    String? status,
    String? rejectReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChannelApplicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'category': category,
      'status': status,
      'reject_reason': rejectReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ChannelApplicationModel.fromMap(Map<String, dynamic> map) {
    return ChannelApplicationModel(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      status: map['status'] as String,
      rejectReason: map['reject_reason'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class ChannelApplicationReviewModel {
  final int? id;
  final int applicationId;
  final int reviewerId;
  final String action; // 'approve', 'reject'
  final String? reason;
  final DateTime createdAt;

  ChannelApplicationReviewModel({
    this.id,
    required this.applicationId,
    required this.reviewerId,
    required this.action,
    this.reason,
    required this.createdAt,
  });

  ChannelApplicationReviewModel copyWith({
    int? id,
    int? applicationId,
    int? reviewerId,
    String? action,
    String? reason,
    DateTime? createdAt,
  }) {
    return ChannelApplicationReviewModel(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      reviewerId: reviewerId ?? this.reviewerId,
      action: action ?? this.action,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'application_id': applicationId,
      'reviewer_id': reviewerId,
      'action': action,
      'reason': reason,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ChannelApplicationReviewModel.fromMap(Map<String, dynamic> map) {
    return ChannelApplicationReviewModel(
      id: map['id'] as int,
      applicationId: map['application_id'] as int,
      reviewerId: map['reviewer_id'] as int,
      action: map['action'] as String,
      reason: map['reason'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
} 