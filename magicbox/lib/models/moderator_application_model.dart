import 'package:uuid/uuid.dart';

enum ModeratorApplicationStatus {
  PENDING,
  APPROVED,
  REJECTED,
  WITHDRAWN,
}

class ModeratorApplicationModel {
  final String id;
  final String channelId;
  final String applicantId;
  final String? reviewerId;
  final ModeratorApplicationStatus status;
  final String applicationContent;
  final String? reviewNote;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final List<String>? qualifications;
  final int? experienceYears;
  final List<String>? previousModeratorRoles;
  final Map<String, dynamic>? metadata;

  ModeratorApplicationModel({
    String? id,
    required this.channelId,
    required this.applicantId,
    this.reviewerId,
    ModeratorApplicationStatus? status,
    required this.applicationContent,
    this.reviewNote,
    DateTime? createdAt,
    this.reviewedAt,
    this.qualifications,
    this.experienceYears,
    this.previousModeratorRoles,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? ModeratorApplicationStatus.PENDING,
        createdAt = createdAt ?? DateTime.now();

  ModeratorApplicationModel copyWith({
    String? id,
    String? channelId,
    String? applicantId,
    String? reviewerId,
    ModeratorApplicationStatus? status,
    String? applicationContent,
    String? reviewNote,
    DateTime? createdAt,
    DateTime? reviewedAt,
    List<String>? qualifications,
    int? experienceYears,
    List<String>? previousModeratorRoles,
    Map<String, dynamic>? metadata,
  }) {
    return ModeratorApplicationModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      applicantId: applicantId ?? this.applicantId,
      reviewerId: reviewerId ?? this.reviewerId,
      status: status ?? this.status,
      applicationContent: applicationContent ?? this.applicationContent,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      qualifications: qualifications ?? this.qualifications,
      experienceYears: experienceYears ?? this.experienceYears,
      previousModeratorRoles: previousModeratorRoles ?? this.previousModeratorRoles,
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
      'qualifications': qualifications,
      'experience_years': experienceYears,
      'previous_moderator_roles': previousModeratorRoles,
      'metadata': metadata,
    };
  }

  factory ModeratorApplicationModel.fromMap(Map<String, dynamic> map) {
    return ModeratorApplicationModel(
      id: map['id'] as String,
      channelId: map['channel_id'] as String,
      applicantId: map['applicant_id'] as String,
      reviewerId: map['reviewer_id'] as String?,
      status: ModeratorApplicationStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ModeratorApplicationStatus.PENDING,
      ),
      applicationContent: map['application_content'] as String,
      reviewNote: map['review_note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      reviewedAt: map['reviewed_at'] != null
          ? DateTime.parse(map['reviewed_at'] as String)
          : null,
      qualifications: (map['qualifications'] as List<dynamic>?)?.map((e) => e as String).toList(),
      experienceYears: map['experience_years'] as int?,
      previousModeratorRoles: (map['previous_moderator_roles'] as List<dynamic>?)?.map((e) => e as String).toList(),
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'ModeratorApplicationModel(id: $id, channelId: $channelId, applicantId: $applicantId, reviewerId: $reviewerId, status: $status, applicationContent: $applicationContent, reviewNote: $reviewNote, createdAt: $createdAt, reviewedAt: $reviewedAt, qualifications: $qualifications, experienceYears: $experienceYears, previousModeratorRoles: $previousModeratorRoles, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ModeratorApplicationModel &&
      other.id == id &&
      other.channelId == channelId &&
      other.applicantId == applicantId &&
      other.reviewerId == reviewerId &&
      other.status == status &&
      other.applicationContent == applicationContent &&
      other.reviewNote == reviewNote &&
      other.createdAt == createdAt &&
      other.reviewedAt == reviewedAt &&
      other.qualifications == qualifications &&
      other.experienceYears == experienceYears &&
      other.previousModeratorRoles == previousModeratorRoles &&
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
      qualifications.hashCode ^
      experienceYears.hashCode ^
      previousModeratorRoles.hashCode ^
      metadata.hashCode;
  }
} 