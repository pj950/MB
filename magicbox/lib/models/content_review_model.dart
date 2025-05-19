class ContentReportModel {
  final int? id;
  final int reporterId;
  final String targetType; // 'post', 'comment'
  final int targetId;
  final String reason;
  final String status; // 'pending', 'reviewed', 'dismissed'
  final String? reviewResult; // 'approved', 'rejected'
  final String? reviewNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  ContentReportModel({
    this.id,
    required this.reporterId,
    required this.targetType,
    required this.targetId,
    required this.reason,
    this.status = 'pending',
    this.reviewResult,
    this.reviewNote,
    required this.createdAt,
    required this.updatedAt,
  });

  ContentReportModel copyWith({
    int? id,
    int? reporterId,
    String? targetType,
    int? targetId,
    String? reason,
    String? status,
    String? reviewResult,
    String? reviewNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContentReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      reviewResult: reviewResult ?? this.reviewResult,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'target_type': targetType,
      'target_id': targetId,
      'reason': reason,
      'status': status,
      'review_result': reviewResult,
      'review_note': reviewNote,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ContentReportModel.fromMap(Map<String, dynamic> map) {
    return ContentReportModel(
      id: map['id'] as int,
      reporterId: map['reporter_id'] as int,
      targetType: map['target_type'] as String,
      targetId: map['target_id'] as int,
      reason: map['reason'] as String,
      status: map['status'] as String,
      reviewResult: map['review_result'] as String?,
      reviewNote: map['review_note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}

class ContentReviewModel {
  final int? id;
  final int reportId;
  final int reviewerId;
  final String action; // 'approve', 'reject', 'dismiss'
  final String? note;
  final DateTime createdAt;

  ContentReviewModel({
    this.id,
    required this.reportId,
    required this.reviewerId,
    required this.action,
    this.note,
    required this.createdAt,
  });

  ContentReviewModel copyWith({
    int? id,
    int? reportId,
    int? reviewerId,
    String? action,
    String? note,
    DateTime? createdAt,
  }) {
    return ContentReviewModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      reviewerId: reviewerId ?? this.reviewerId,
      action: action ?? this.action,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'report_id': reportId,
      'reviewer_id': reviewerId,
      'action': action,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ContentReviewModel.fromMap(Map<String, dynamic> map) {
    return ContentReviewModel(
      id: map['id'] as int,
      reportId: map['report_id'] as int,
      reviewerId: map['reviewer_id'] as int,
      action: map['action'] as String,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
