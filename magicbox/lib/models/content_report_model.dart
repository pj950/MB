import 'package:uuid/uuid.dart';

enum ReportType {
  SPAM,
  HARASSMENT,
  HATE_SPEECH,
  VIOLENCE,
  ILLEGAL_CONTENT,
  COPYRIGHT,
  OTHER,
}

enum ReportStatus {
  PENDING,
  REVIEWING,
  RESOLVED,
  REJECTED,
}

class ContentReportModel {
  final String id;
  final String reporterId;
  final String targetType; // post, comment, user, channel
  final String targetId;
  final ReportType type;
  final String description;
  final List<String>? evidenceUrls;
  final ReportStatus status;
  final String? reviewerId;
  final String? reviewNote;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final Map<String, dynamic>? metadata;

  ContentReportModel({
    String? id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.type,
    required this.description,
    this.evidenceUrls,
    ReportStatus? status,
    this.reviewerId,
    this.reviewNote,
    DateTime? createdAt,
    this.reviewedAt,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        status = status ?? ReportStatus.PENDING,
        createdAt = createdAt ?? DateTime.now();

  ContentReportModel copyWith({
    String? id,
    String? reporterId,
    String? targetType,
    String? targetId,
    ReportType? type,
    String? description,
    List<String>? evidenceUrls,
    ReportStatus? status,
    String? reviewerId,
    String? reviewNote,
    DateTime? createdAt,
    DateTime? reviewedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ContentReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      type: type ?? this.type,
      description: description ?? this.description,
      evidenceUrls: evidenceUrls ?? this.evidenceUrls,
      status: status ?? this.status,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'target_type': targetType,
      'target_id': targetId,
      'type': type.toString(),
      'description': description,
      'evidence_urls': evidenceUrls,
      'status': status.toString(),
      'reviewer_id': reviewerId,
      'review_note': reviewNote,
      'created_at': createdAt.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ContentReportModel.fromMap(Map<String, dynamic> map) {
    return ContentReportModel(
      id: map['id'] as String,
      reporterId: map['reporter_id'] as String,
      targetType: map['target_type'] as String,
      targetId: map['target_id'] as String,
      type: ReportType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => ReportType.OTHER,
      ),
      description: map['description'] as String,
      evidenceUrls: (map['evidence_urls'] as List<dynamic>?)?.map((e) => e as String).toList(),
      status: ReportStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ReportStatus.PENDING,
      ),
      reviewerId: map['reviewer_id'] as String?,
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
    return 'ContentReportModel(id: $id, reporterId: $reporterId, targetType: $targetType, targetId: $targetId, type: $type, description: $description, evidenceUrls: $evidenceUrls, status: $status, reviewerId: $reviewerId, reviewNote: $reviewNote, createdAt: $createdAt, reviewedAt: $reviewedAt, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ContentReportModel &&
      other.id == id &&
      other.reporterId == reporterId &&
      other.targetType == targetType &&
      other.targetId == targetId &&
      other.type == type &&
      other.description == description &&
      other.evidenceUrls == evidenceUrls &&
      other.status == status &&
      other.reviewerId == reviewerId &&
      other.reviewNote == reviewNote &&
      other.createdAt == createdAt &&
      other.reviewedAt == reviewedAt &&
      other.metadata == metadata;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      reporterId.hashCode ^
      targetType.hashCode ^
      targetId.hashCode ^
      type.hashCode ^
      description.hashCode ^
      evidenceUrls.hashCode ^
      status.hashCode ^
      reviewerId.hashCode ^
      reviewNote.hashCode ^
      createdAt.hashCode ^
      reviewedAt.hashCode ^
      metadata.hashCode;
  }
} 