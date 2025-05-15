import 'package:get/get.dart';

class PostModel {
  final int? id;
  final int channelId;
  final int authorId;
  final String title;
  final String content;
  final List<String>? imageUrls;
  final String? audioUrl;
  final String? videoUrl;
  final int? boxId;
  final List<String>? tags;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final bool isPinned;
  final bool isTop;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    this.id,
    required this.channelId,
    required this.authorId,
    required this.title,
    required this.content,
    this.imageUrls,
    this.audioUrl,
    this.videoUrl,
    this.boxId,
    this.tags,
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    this.isPinned = false,
    this.isTop = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  PostModel copyWith({
    int? id,
    int? channelId,
    int? authorId,
    String? title,
    String? content,
    List<String>? imageUrls,
    String? audioUrl,
    String? videoUrl,
    int? boxId,
    List<String>? tags,
    int? likeCount,
    int? commentCount,
    int? viewCount,
    bool? isPinned,
    bool? isTop,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      audioUrl: audioUrl ?? this.audioUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      boxId: boxId ?? this.boxId,
      tags: tags ?? this.tags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      isPinned: isPinned ?? this.isPinned,
      isTop: isTop ?? this.isTop,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'channelId': channelId,
      'authorId': authorId,
      'title': title,
      'content': content,
      'imageUrls': imageUrls?.join(','),
      'audioUrl': audioUrl,
      'videoUrl': videoUrl,
      'boxId': boxId,
      'tags': tags?.join(','),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'viewCount': viewCount,
      'isPinned': isPinned ? 1 : 0,
      'isTop': isTop ? 1 : 0,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map['id'],
      channelId: map['channelId'],
      authorId: map['authorId'],
      title: map['title'],
      content: map['content'],
      imageUrls: map['imageUrls']?.split(','),
      audioUrl: map['audioUrl'],
      videoUrl: map['videoUrl'],
      boxId: map['boxId'],
      tags: map['tags']?.split(','),
      likeCount: map['likeCount'],
      commentCount: map['commentCount'],
      viewCount: map['viewCount'],
      isPinned: map['isPinned'] == 1,
      isTop: map['isTop'] == 1,
      isActive: map['isActive'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
} 