import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/community_controller.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class PostDetailPage extends StatelessWidget {
  final int postId;
  final CommunityController _controller = Get.find<CommunityController>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final TextEditingController _commentController = TextEditingController();
  final UserModel? currentUser = Get.find<UserModel?>();

  PostDetailPage({super.key, required this.postId}) {
    _controller.loadComments(postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('帖子详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadComments(postId),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final post = _controller.posts.firstWhere(
          (p) => p.id == postId,
          orElse: () => PostModel(
            channelId: 0,
            authorId: 0,
            title: '加载中...',
            content: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPostContent(post),
              const Divider(),
              _buildCommentSection(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPostContent(PostModel post) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '发布于 ${_formatDate(post.createdAt)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          if (post.imageUrls != null && post.imageUrls!.isNotEmpty)
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: post.imageUrls!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.network(
                      post.imageUrls![index],
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Text(
            post.content,
            style: const TextStyle(fontSize: 16),
          ),
          if (post.tags != null && post.tags!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: post.tags!.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: Colors.blue.withAlpha(26),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up_outlined),
                    onPressed: () => _controller.likePost(postId),
                  ),
                  Text('${post.likeCount}'),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.visibility_outlined),
                  const SizedBox(width: 4),
                  Text('${post.viewCount}'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '评论',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: '写下你的评论...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_commentController.text.isEmpty) {
                    Get.snackbar(
                      '错误',
                      '请输入评论内容',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  if (currentUser == null) {
                    Get.snackbar(
                      '错误',
                      '请先登录',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                    return;
                  }

                  _controller.createComment(
                    postId: postId,
                    userId: currentUser!.id!,
                    content: _commentController.text,
                  );
                  _commentController.clear();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (_controller.comments.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('暂无评论'),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _controller.comments.length,
            itemBuilder: (context, index) {
              final comment = _controller.comments[index];
              return _buildCommentItem(comment);
            },
          );
        }),
      ],
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FutureBuilder<UserModel?>(
                  future: _databaseService.getUser(comment.authorId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('加载中...');
                    }
                    return Text(
                      snapshot.data?.username ?? '未知用户',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                Text(
                  _formatDate(comment.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment.content),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _showReplyDialog(comment),
                  child: const Text('回复'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReplyDialog(CommentModel parentComment) {
    final TextEditingController replyController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('回复评论'),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(
            hintText: '写下你的回复...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (replyController.text.isEmpty) {
                Get.snackbar(
                  '错误',
                  '请输入回复内容',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              if (currentUser == null) {
                Get.snackbar(
                  '错误',
                  '请先登录',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              _controller.createComment(
                postId: postId,
                userId: currentUser!.id!,
                content: replyController.text,
              );
              Get.back();
            },
            child: const Text('发送'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
