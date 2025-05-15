import 'package:uuid/uuid.dart';

class SearchHistoryModel {
  final String id;
  final String userId;
  final String keyword;
  final DateTime searchTime;
  final int resultCount;
  final List<String>? filters;
  final String? category;

  SearchHistoryModel({
    String? id,
    required this.userId,
    required this.keyword,
    DateTime? searchTime,
    this.resultCount = 0,
    this.filters,
    this.category,
  })  : id = id ?? const Uuid().v4(),
        searchTime = searchTime ?? DateTime.now();

  SearchHistoryModel copyWith({
    String? id,
    String? userId,
    String? keyword,
    DateTime? searchTime,
    int? resultCount,
    List<String>? filters,
    String? category,
  }) {
    return SearchHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      keyword: keyword ?? this.keyword,
      searchTime: searchTime ?? this.searchTime,
      resultCount: resultCount ?? this.resultCount,
      filters: filters ?? this.filters,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'keyword': keyword,
      'search_time': searchTime.toIso8601String(),
      'result_count': resultCount,
      'filters': filters?.join(','),
      'category': category,
    };
  }

  factory SearchHistoryModel.fromMap(Map<String, dynamic> map) {
    return SearchHistoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      keyword: map['keyword'] as String,
      searchTime: DateTime.parse(map['search_time'] as String),
      resultCount: map['result_count'] as int? ?? 0,
      filters: (map['filters'] as String?)?.split(','),
      category: map['category'] as String?,
    );
  }

  @override
  String toString() {
    return 'SearchHistoryModel(id: $id, userId: $userId, keyword: $keyword, searchTime: $searchTime, resultCount: $resultCount, filters: $filters, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SearchHistoryModel &&
      other.id == id &&
      other.userId == userId &&
      other.keyword == keyword &&
      other.searchTime == searchTime &&
      other.resultCount == resultCount &&
      other.filters == filters &&
      other.category == category;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      keyword.hashCode ^
      searchTime.hashCode ^
      resultCount.hashCode ^
      filters.hashCode ^
      category.hashCode;
  }
} 