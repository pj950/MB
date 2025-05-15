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
  final Map<String, dynamic>? metadata;
  final List<String> familyMemberIds;
  final int maxRepositories;
  final int maxBoxesPerRepository;
  final bool hasAdvancedProperties;
  final bool hasWatermarkProtection;
  final int maxFamilyMembers;

  SubscriptionModel({
    String? id,
    required this.userId,
    required this.type,
    DateTime? startDate,
    DateTime? endDate,
    this.isActive = true,
    this.metadata,
    List<String>? familyMemberIds,
    int? maxRepositories,
    int? maxBoxesPerRepository,
    bool? hasAdvancedProperties,
    bool? hasWatermarkProtection,
    int? maxFamilyMembers,
  })  : id = id ?? const Uuid().v4(),
        startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now().add(const Duration(days: 30)),
        familyMemberIds = familyMemberIds ?? [],
        maxRepositories = maxRepositories ?? _getDefaultMaxRepositories(type),
        maxBoxesPerRepository = maxBoxesPerRepository ?? _getDefaultMaxBoxes(type),
        hasAdvancedProperties = hasAdvancedProperties ?? _getDefaultHasAdvancedProperties(type),
        hasWatermarkProtection = hasWatermarkProtection ?? _getDefaultHasWatermarkProtection(type),
        maxFamilyMembers = maxFamilyMembers ?? _getDefaultMaxFamilyMembers(type);

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
        return 10;
      case SubscriptionType.PERSONAL:
      case SubscriptionType.FAMILY:
        return -1; // 无限制
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
      'is_active': isActive,
      'metadata': metadata,
      'family_member_ids': familyMemberIds,
      'max_repositories': maxRepositories,
      'max_boxes_per_repository': maxBoxesPerRepository,
      'has_advanced_properties': hasAdvancedProperties,
      'has_watermark_protection': hasWatermarkProtection,
      'max_family_members': maxFamilyMembers,
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'],
      userId: map['user_id'],
      type: SubscriptionType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => SubscriptionType.FREE,
      ),
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      isActive: map['is_active'] ?? true,
      metadata: map['metadata'],
      familyMemberIds: List<String>.from(map['family_member_ids'] ?? []),
      maxRepositories: map['max_repositories'],
      maxBoxesPerRepository: map['max_boxes_per_repository'],
      hasAdvancedProperties: map['has_advanced_properties'],
      hasWatermarkProtection: map['has_watermark_protection'],
      maxFamilyMembers: map['max_family_members'],
    );
  }

  SubscriptionModel copyWith({
    SubscriptionType? type,
    DateTime? endDate,
    bool? isActive,
    Map<String, dynamic>? metadata,
    List<String>? familyMemberIds,
    int? maxRepositories,
    int? maxBoxesPerRepository,
    bool? hasAdvancedProperties,
    bool? hasWatermarkProtection,
    int? maxFamilyMembers,
  }) {
    return SubscriptionModel(
      id: id,
      userId: userId,
      type: type ?? this.type,
      startDate: startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      metadata: metadata ?? this.metadata,
      familyMemberIds: familyMemberIds ?? this.familyMemberIds,
      maxRepositories: maxRepositories ?? this.maxRepositories,
      maxBoxesPerRepository: maxBoxesPerRepository ?? this.maxBoxesPerRepository,
      hasAdvancedProperties: hasAdvancedProperties ?? this.hasAdvancedProperties,
      hasWatermarkProtection: hasWatermarkProtection ?? this.hasWatermarkProtection,
      maxFamilyMembers: maxFamilyMembers ?? this.maxFamilyMembers,
    );
  }

  // 检查是否可以添加更多仓库
  bool canAddRepository(int currentCount) {
    if (maxRepositories == -1) return true;
    return currentCount < maxRepositories;
  }

  // 检查是否可以添加更多盒子
  bool canAddBox(int currentCount) {
    if (maxBoxesPerRepository == -1) return true;
    return currentCount < maxBoxesPerRepository;
  }

  // 检查是否可以添加更多家庭成员
  bool canAddFamilyMember() {
    if (maxFamilyMembers == 0) return false;
    return familyMemberIds.length < maxFamilyMembers;
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
    switch (type) {
      case SubscriptionType.FREE:
        return 0;
      case SubscriptionType.PERSONAL:
        return 5;
      case SubscriptionType.FAMILY:
        return 15;
    }
  }
} 