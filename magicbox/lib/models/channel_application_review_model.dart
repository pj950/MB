import 'package:uuid/uuid.dart';

enum ApplicationStatus {
  PENDING,
  APPROVED,
  REJECTED,
  WITHDRAWN,
}

class ChannelApplicationReviewModel {
  final String id;
  final String channelId;
  final String applicantId;
  final String? reviewerId;
  final ApplicationStatus status;
  final String applicationContent;
  final String? reviewNote;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final Map<String, dynamic>? metadata;

  ChannelApplicationReviewModel({
    String? id,
    required this.channelId,
    required this.applicantId,
    this.reviewerId,
    ApplicationStatus? status,
    required this.applicationContent,
    this.reviewNote,
    DateTime? createdAt,
    this.reviewedAt,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? ApplicationStatus.PENDING,
        createdAt = createdAt ?? DateTime.now();

  ChannelApplicationReviewModel copyWith({
    String? id,
    String? channelId,
    String? applicantId,
    String? reviewerId,
    ApplicationStatus? status,
    String? applicationContent,
    String? reviewNote,
    DateTime? createdAt,
    DateTime? reviewedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ChannelApplicationReviewModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      applicantId: applicantId ?? this.applicantId,
      reviewerId: reviewerId ?? this.reviewerId,
      status: status ?? this.status,
      applicationContent: applicationContent ?? this.applicationContent,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'channel_id': channelId,
      'applicant_id': applicantId,
      'reviewer_id': reviewerId,
      'status': status.toString(),
      'application_content': applicationContent,
      'review_note': reviewNote,
      'created_at': createdAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ChannelApplicationReviewModel.fromMap(Map<String, dynamic> map) {
    return ChannelApplicationReviewModel(
      id: map['id'] as String,
      channelId: map['channel_id'] as String,
      applicantId: map['applicant_id'] as String,
      reviewerId: map['reviewer_id'] as String?,
      status: ApplicationStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ApplicationStatus.PENDING,
      ),
      applicationContent: map['application_content'] as String,
      reviewNote: map['review_note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      reviewedAt: map['reviewed_at'] != null
          ? DateTime.parse(map['reviewed_at'] as String)
          : null,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'ChannelApplicationReviewModel(id: $id, channelId: $channelId, applicantId: $applicantId, reviewerId: $reviewerId, status: $status, applicationContent: $applicationContent, reviewNote: $reviewNote, createdAt: $createdAt, reviewedAt: $reviewedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ChannelApplicationReviewModel &&
      other.id == id &&
      other.channelId == channelId &&
      other.applicantId == applicantId &&
      other.reviewerId == reviewerId &&
      other.status == status &&
      other.applicationContent == applicationContent &&
      other.reviewNote == reviewNote &&
      other.createdAt == createdAt &&
      other.reviewedAt == reviewedAt &&
      other.metadata == metadata;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      channelId.hashCode ^
      applicantId.hashCode ^
      reviewerId.hashCode ^
      status.hashCode ^
      applicationContent.hashCode ^
      reviewNote.hashCode ^
      createdAt.hashCode ^
      reviewedAt.hashCode ^
      metadata.hashCode;
  }
} 