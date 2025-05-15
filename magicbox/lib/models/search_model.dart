class SearchHistoryModel {
  final String id;
  final String userId;
  final String keyword;
  final DateTime searchTime;

  SearchHistoryModel({
    required this.id,
    required this.userId,
    required this.keyword,
    required this.searchTime,
  });

  SearchHistoryModel copyWith({
    String? id,
    String? userId,
    String? keyword,
    DateTime? searchTime,
  }) {
    return SearchHistoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      keyword: keyword ?? this.keyword,
      searchTime: searchTime ?? this.searchTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'keyword': keyword,
      'search_time': searchTime.toIso8601String(),
    };
  }

  factory SearchHistoryModel.fromMap(Map<String, dynamic> map) {
    return SearchHistoryModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      keyword: map['keyword'] as String,
      searchTime: DateTime.parse(map['search_time'] as String),
    );
  }

  @override
  String toString() {
    return 'SearchHistoryModel(id: $id, userId: $userId, keyword: $keyword, searchTime: $searchTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SearchHistoryModel &&
      other.id == id &&
      other.userId == userId &&
      other.keyword == keyword &&
      other.searchTime == searchTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      userId.hashCode ^
      keyword.hashCode ^
      searchTime.hashCode;
  }
}

class SearchResultModel {
  final String id;
  final String type; // post, channel, user
  final String title;
  final String? description;
  final String? imageUrl;
  final Map<String, dynamic>? extraData;
  final DateTime createdAt;

  SearchResultModel({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.imageUrl,
    this.extraData,
    required this.createdAt,
  });

  SearchResultModel copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    String? imageUrl,
    Map<String, dynamic>? extraData,
    DateTime? createdAt,
  }) {
    return SearchResultModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      extraData: extraData ?? this.extraData,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'extra_data': extraData != null ? extraData.toString() : null,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SearchResultModel.fromMap(Map<String, dynamic> map) {
    return SearchResultModel(
      id: map['id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String?,
      extraData: map['extra_data'] != null
          ? Map<String, dynamic>.from(
              map['extra_data'] as Map<String, dynamic>,
            )
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  @override
  String toString() {
    return 'SearchResultModel(id: $id, type: $type, title: $title, description: $description, imageUrl: $imageUrl, extraData: $extraData, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SearchResultModel &&
      other.id == id &&
      other.type == type &&
      other.title == title &&
      other.description == description &&
      other.imageUrl == imageUrl &&
      other.extraData == extraData &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      type.hashCode ^
      title.hashCode ^
      description.hashCode ^
      imageUrl.hashCode ^
      extraData.hashCode ^
      createdAt.hashCode;
  }
} 