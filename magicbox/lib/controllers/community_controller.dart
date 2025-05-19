import 'package:get/get.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/database_service.dart';
import '../services/file_service.dart';
import 'package:flutter/material.dart';
import '../models/channel_model.dart';
import '../models/user_model.dart';

class CommunityController extends GetxController {
  final DatabaseService _db = DatabaseService();
  final FileService _fileService = FileService();
  final RxList<PostModel> _posts = <PostModel>[].obs;
  final RxList<CommentModel> _comments = <CommentModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxList<ChannelModel> _channels = <ChannelModel>[].obs;
  final UserModel currentUser = Get.find<UserModel>();

  List<PostModel> get posts => _posts;
  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  List<ChannelModel> get channels => _channels;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
    loadChannels();
  }

  void _showError(String message) {
    _error.value = message;
    Get.snackbar(
      '错误',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      '成功',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> loadPosts() async {
    _isLoading.value = true;
    _error.value = '';
    try {
      final posts = await _db.getPosts();
      _posts.value = posts;
    } catch (e) {
      _showError('加载帖子失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadComments(int postId) async {
    _isLoading.value = true;
    _error.value = '';
    try {
      final comments = await _db.getCommentsByPost(postId);
      _comments.value = comments;
    } catch (e) {
      _showError('加载评论失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createPost({
    required int userId,
    required String title,
    required String content,
    List<String> imageUrls = const [],
  }) async {
    if (!_checkUserLoggedIn()) return;
    _isLoading.value = true;
    _error.value = '';
    try {
      final now = DateTime.now();
      final post = PostModel(
        channelId: 1, // 默认频道ID
        authorId: userId,
        title: title,
        content: content,
        imageUrls: imageUrls,
        createdAt: now,
        updatedAt: now,
      );

      final postId = await _db.insertPost(post);
      final createdPost = post.copyWith(id: postId);
      _posts.insert(0, createdPost);

      Get.back();
      _showSuccess('发布成功');
    } catch (e) {
      _showError('发布失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updatePost(PostModel post) async {
    if (!_checkUserLoggedIn()) return;
    _isLoading.value = true;
    _error.value = '';
    try {
      await _db.updatePost(post);
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = post;
      }
      Get.back();
      _showSuccess('更新成功');
    } catch (e) {
      _showError('更新失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deletePost(int postId) async {
    if (!_checkUserPermission()) return;
    _isLoading.value = true;
    _error.value = '';
    try {
      final post = _posts.firstWhere((p) => p.id == postId);
      await _fileService.deleteImages(post.imageUrls ?? []);
      await _db.deletePost(postId);
      _posts.removeWhere((post) => post.id == postId);
      Get.back();
      _showSuccess('删除成功');
    } catch (e) {
      _showError('删除失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createComment({
    required int postId,
    required String userId,
    required String content,
  }) async {
    if (!_checkUserLoggedIn()) return;
    _isLoading.value = true;
    _error.value = '';
    try {
      final now = DateTime.now();
      final comment = CommentModel(
        postId: postId,
        authorId: userId,
        content: content,
        createdAt: now,
        updatedAt: now,
      );

      final commentId = await _db.insertComment(comment);
      final createdComment = comment.copyWith(id: commentId);
      _comments.add(createdComment);

      // 更新帖子评论数
      final post = _posts.firstWhere((p) => p.id == postId);
      final updatedPost = post.copyWith(
        commentCount: post.commentCount + 1,
        updatedAt: now,
      );
      await updatePost(updatedPost);

      _showSuccess('评论成功');
    } catch (e) {
      _showError('评论失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteComment(int commentId) async {
    if (!_checkUserPermission()) return;
    _isLoading.value = true;
    _error.value = '';
    try {
      final comment = _comments.firstWhere((c) => c.id == commentId);
      await _db.deleteComment(commentId);
      _comments.removeWhere((comment) => comment.id == commentId);

      // 更新帖子评论数
      final post = _posts.firstWhere((p) => p.id == comment.postId);
      final now = DateTime.now();
      final updatedPost = post.copyWith(
        commentCount: post.commentCount - 1,
        updatedAt: now,
      );
      await updatePost(updatedPost);

      _showSuccess('删除成功');
    } catch (e) {
      _showError('删除失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> likePost(int postId) async {
    if (!_checkUserLoggedIn()) return;
    _isLoading.value = true;
    _error.value = '';
    try {
      final post = _posts.firstWhere((p) => p.id == postId);
      final now = DateTime.now();
      final updatedPost = post.copyWith(
        likeCount: post.likeCount + 1,
        updatedAt: now,
      );
      await updatePost(updatedPost);
      _showSuccess('点赞成功');
    } catch (e) {
      _showError('点赞失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> likeComment(int commentId) async {
    if (!_checkUserLoggedIn()) return;
    _isLoading.value = true;
    _error.value = '';
    try {
      final comment = _comments.firstWhere((c) => c.id == commentId);
      final now = DateTime.now();
      final updatedComment = comment.copyWith(
        likeCount: comment.likeCount + 1,
        updatedAt: now,
      );
      await _db.updateComment(updatedComment);
      final index = _comments.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        _comments[index] = updatedComment;
      }
      _showSuccess('点赞成功');
    } catch (e) {
      _showError('点赞失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<String>> uploadImages() async {
    if (!_checkUserLoggedIn()) return [];
    _isLoading.value = true;
    _error.value = '';
    try {
      final paths = await _fileService.pickAndSaveMultipleImages();
      if (paths.isEmpty) {
        _showError('未选择图片');
      }
      return paths;
    } catch (e) {
      _showError('上传图片失败：$e');
      return [];
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadChannels() async {
    _isLoading.value = true;
    try {
      final channels = await _db.getChannels();
      _channels.value = channels;
    } catch (e) {
      Get.snackbar('错误', '加载频道失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createChannel({
    required String name,
    required String description,
    String? coverImage,
    bool isPrivate = false,
    List<String> tags = const [],
  }) async {
    if (!_checkUserPermission()) return;

    _isLoading.value = true;
    try {
      final channel = ChannelModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        description: description,
        coverImage: coverImage,
        isPrivate: isPrivate,
        tags: tags,
        ownerId: currentUser.id.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _db.insertChannel(channel);
      _channels.add(channel);

      Get.back();
      _showSuccess('频道创建成功');
    } catch (e) {
      _showError('创建频道失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateChannel(ChannelModel channel) async {
    if (!_checkUserPermission()) return;
    _isLoading.value = true;
    try {
      await _db.updateChannel(channel);
      final index = _channels.indexWhere((c) => c.id == channel.id);
      if (index != -1) {
        _channels[index] = channel;
      }
      Get.back();
      Get.snackbar('成功', '频道更新成功');
    } catch (e) {
      Get.snackbar('错误', '更新频道失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteChannel(String channelId) async {
    if (!_checkUserPermission()) return;
    _isLoading.value = true;
    try {
      await _db.deleteChannel(int.parse(channelId));
      _channels.removeWhere((channel) => channel.id == channelId);
      Get.back();
      Get.snackbar('成功', '频道删除成功');
    } catch (e) {
      Get.snackbar('错误', '删除频道失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  // 检查用户是否已登录
  bool _checkUserLoggedIn() {
    if (currentUser == null) {
      _showError('请先登录');
      return false;
    }
    return true;
  }

  // 检查用户是否有权限
  bool _checkUserPermission() {
    if (!_checkUserLoggedIn()) return false;

    // 检查用户类型
    if (currentUser.type != UserType.ADMIN &&
        currentUser.type != UserType.MODERATOR) {
      _showError('权限不足');
      return false;
    }
    return true;
  }
}
