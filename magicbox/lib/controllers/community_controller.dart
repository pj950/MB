import 'package:get/get.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/database_service.dart';
import '../services/file_service.dart';
import 'package:flutter/material.dart';

class CommunityController extends GetxController {
  final DatabaseService _db = DatabaseService();
  final FileService _fileService = FileService();
  final RxList<PostModel> _posts = <PostModel>[].obs;
  final RxList<CommentModel> _comments = <CommentModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;

  List<PostModel> get posts => _posts;
  List<CommentModel> get comments => _comments;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
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
      final posts = await _db.getAllPosts();
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
    _isLoading.value = true;
    _error.value = '';
    try {
      final post = PostModel(
        userId: userId,
        title: title,
        content: content,
        imageUrls: imageUrls,
      );
      
      final postId = await _db.insertPost(post);
      post.id = postId;
      _posts.insert(0, post);
      
      Get.back();
      _showSuccess('发布成功');
    } catch (e) {
      _showError('发布失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updatePost(PostModel post) async {
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
    _isLoading.value = true;
    _error.value = '';
    try {
      final post = _posts.firstWhere((p) => p.id == postId);
      await _fileService.deleteImages(post.imageUrls);
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
    required int userId,
    required String content,
  }) async {
    _isLoading.value = true;
    _error.value = '';
    try {
      final comment = CommentModel(
        postId: postId,
        userId: userId,
        content: content,
      );
      
      final commentId = await _db.insertComment(comment);
      comment.id = commentId;
      _comments.add(comment);
      
      // 更新帖子评论数
      final post = _posts.firstWhere((p) => p.id == postId);
      final updatedPost = post.copyWith(
        commentCount: post.commentCount + 1,
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
    _isLoading.value = true;
    _error.value = '';
    try {
      final comment = _comments.firstWhere((c) => c.id == commentId);
      await _db.deleteComment(commentId);
      _comments.removeWhere((comment) => comment.id == commentId);
      
      // 更新帖子评论数
      final post = _posts.firstWhere((p) => p.id == comment.postId);
      final updatedPost = post.copyWith(
        commentCount: post.commentCount - 1,
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
    _isLoading.value = true;
    _error.value = '';
    try {
      final post = _posts.firstWhere((p) => p.id == postId);
      final updatedPost = post.copyWith(
        likeCount: post.likeCount + 1,
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
    _isLoading.value = true;
    _error.value = '';
    try {
      final comment = _comments.firstWhere((c) => c.id == commentId);
      final updatedComment = comment.copyWith(
        likeCount: comment.likeCount + 1,
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
} 