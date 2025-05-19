import 'package:uuid/uuid.dart';

enum SubscriptionType {
  FREE,
  PERSONAL,
  FAMILY,
}

class SubscriptionModel {
  final String id;
  final String userId;
  final SubscriptionType type;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final String? familyMemberIds;
  final int maxRepositories;
  final int maxBoxesPerRepository;
  final bool hasAdvancedProperties;
  final bool hasWatermarkProtection;
  final int maxFamilyMembers;
  final String? paymentId;
  final String? paymentStatus;
  final double? paymentAmount;
  final String? paymentCurrency;
  final DateTime? paymentDate;
  final bool autoRenew;
  final int trialPeriod;
  final String? expiryText;
  final DateTime created_at;
  final DateTime updated_at;

  SubscriptionModel({
    String? id,
    required this.userId,
    required this.type,
    DateTime? startDate,
    DateTime? endDate,
    this.isActive = true,
    String? familyMemberIds,
    int? maxRepositories,
    int? maxBoxesPerRepository,
    bool? hasAdvancedProperties,
    bool? hasWatermarkProtection,
    int? maxFamilyMembers,
    this.paymentId,
    this.paymentStatus,
    this.paymentAmount,
    this.paymentCurrency,
    this.paymentDate,
    this.autoRenew = false,
    this.trialPeriod = 0,
    this.expiryText,
    DateTime? created_at,
    DateTime? updated_at,
  })  : id = id ?? const Uuid().v4(),
        startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now().add(const Duration(days: 30)),
        familyMemberIds = familyMemberIds,
        maxRepositories = maxRepositories ?? _getDefaultMaxRepositories(type),
        maxBoxesPerRepository =
            maxBoxesPerRepository ?? _getDefaultMaxBoxes(type),
        hasAdvancedProperties =
            hasAdvancedProperties ?? _getDefaultHasAdvancedProperties(type),
        hasWatermarkProtection =
            hasWatermarkProtection ?? _getDefaultHasWatermarkProtection(type),
        maxFamilyMembers =
            maxFamilyMembers ?? _getDefaultMaxFamilyMembers(type),
        created_at = created_at ?? DateTime.now(),
        updated_at = updated_at ?? DateTime.now();

  static int _getDefaultMaxRepositories(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.FREE:
        return 1;
      case SubscriptionType.PERSONAL:
        return 3;
      case SubscriptionType.FAMILY:
        return 5;
    }
  }

  static int _getDefaultMaxBoxes(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.FREE:
        return 5;
      case SubscriptionType.PERSONAL:
        return 20;
      case SubscriptionType.FAMILY:
        return 50;
    }
  }

  static bool _getDefaultHasAdvancedProperties(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.FREE:
        return false;
      case SubscriptionType.PERSONAL:
      case SubscriptionType.FAMILY:
        return true;
    }
  }

  static bool _getDefaultHasWatermarkProtection(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.FREE:
        return false;
      case SubscriptionType.PERSONAL:
      case SubscriptionType.FAMILY:
        return true;
    }
  }

  static int _getDefaultMaxFamilyMembers(SubscriptionType type) {
    switch (type) {
      case SubscriptionType.FREE:
      case SubscriptionType.PERSONAL:
        return 0;
      case SubscriptionType.FAMILY:
        return 5;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.toString(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'family_member_ids': familyMemberIds,
      'max_repositories': maxRepositories,
      'max_boxes_per_repository': maxBoxesPerRepository,
      'has_advanced_properties': hasAdvancedProperties ? 1 : 0,
      'has_watermark_protection': hasWatermarkProtection ? 1 : 0,
      'max_family_members': maxFamilyMembers,
      'payment_id': paymentId,
      'payment_status': paymentStatus,
      'payment_amount': paymentAmount,
      'payment_currency': paymentCurrency,
      'payment_date': paymentDate?.toIso8601String(),
      'auto_renew': autoRenew ? 1 : 0,
      'trial_period': trialPeriod,
      'expiry_text': expiryText,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      type: SubscriptionType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => SubscriptionType.FREE,
      ),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      isActive: map['is_active'] == 1,
      familyMemberIds: map['family_member_ids'] as String?,
      maxRepositories: map['max_repositories'] as int,
      maxBoxesPerRepository: map['max_boxes_per_repository'] as int,
      hasAdvancedProperties: map['has_advanced_properties'] == 1,
      hasWatermarkProtection: map['has_watermark_protection'] == 1,
      maxFamilyMembers: map['max_family_members'] as int,
      paymentId: map['payment_id'] as String?,
      paymentStatus: map['payment_status'] as String?,
      paymentAmount: map['payment_amount'] as double?,
      paymentCurrency: map['payment_currency'] as String?,
      paymentDate: map['payment_date'] != null
          ? DateTime.parse(map['payment_date'] as String)
          : null,
      autoRenew: map['auto_renew'] == 1,
      trialPeriod: map['trial_period'] as int,
      expiryText: map['expiry_text'] as String?,
      created_at: DateTime.parse(map['created_at'] as String),
      updated_at: DateTime.parse(map['updated_at'] as String),
    );
  }

  SubscriptionModel copyWith({
    SubscriptionType? type,
    DateTime? endDate,
    bool? isActive,
    String? familyMemberIds,
    int? maxRepositories,
    int? maxBoxesPerRepository,
    bool? hasAdvancedProperties,
    bool? hasWatermarkProtection,
    int? maxFamilyMembers,
    String? paymentId,
    String? paymentStatus,
    double? paymentAmount,
    String? paymentCurrency,
    DateTime? paymentDate,
    bool? autoRenew,
    int? trialPeriod,
    String? expiryText,
    DateTime? created_at,
    DateTime? updated_at,
  }) {
    return SubscriptionModel(
      id: id,
      userId: userId,
      type: type ?? this.type,
      startDate: startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      familyMemberIds: familyMemberIds ?? this.familyMemberIds,
      maxRepositories: maxRepositories ?? this.maxRepositories,
      maxBoxesPerRepository:
          maxBoxesPerRepository ?? this.maxBoxesPerRepository,
      hasAdvancedProperties:
          hasAdvancedProperties ?? this.hasAdvancedProperties,
      hasWatermarkProtection:
          hasWatermarkProtection ?? this.hasWatermarkProtection,
      maxFamilyMembers: maxFamilyMembers ?? this.maxFamilyMembers,
      paymentId: paymentId ?? this.paymentId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentAmount: paymentAmount ?? this.paymentAmount,
      paymentCurrency: paymentCurrency ?? this.paymentCurrency,
      paymentDate: paymentDate ?? this.paymentDate,
      autoRenew: autoRenew ?? this.autoRenew,
      trialPeriod: trialPeriod ?? this.trialPeriod,
      expiryText: expiryText ?? this.expiryText,
      created_at: created_at ?? this.created_at,
      updated_at: updated_at ?? this.updated_at,
    );
  }

  // 检查是否可以添加更多仓库
  bool canAddRepository(int currentCount) {
    return currentCount < maxRepositories;
  }

  // 检查是否可以添加更多盒子
  bool canAddBox(int currentCount) {
    return currentCount < maxBoxesPerRepository;
  }

  // 检查是否可以添加更多家庭成员
  bool canAddFamilyMember() {
    if (maxFamilyMembers == 0) return false;
    return (familyMemberIds?.split(',') ?? []).length < maxFamilyMembers;
  }

  // 检查订阅是否过期
  bool isExpired() {
    return DateTime.now().isAfter(endDate);
  }

  // 获取剩余天数
  int getRemainingDays() {
    return endDate.difference(DateTime.now()).inDays;
  }

  // 获取订阅价格
  double getPrice() {
    return paymentAmount ?? 0;
  }
}
