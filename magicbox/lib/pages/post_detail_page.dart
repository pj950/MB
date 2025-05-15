import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/community_controller.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';

class PostDetailPage extends StatelessWidget {
  final int postId;
  final CommunityController _controller = Get.find<CommunityController>();
  final TextEditingController _commentController = TextEditingController();

  PostDetailPage({Key? key, required this.postId}) : super(key: key) {
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
                  backgroundColor: Colors.blue.withOpacity(0.1),
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
                    onPressed: () => _controller.likePost(1, post.id!),
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

                  final comment = CommentModel(
                    postId: postId,
                    authorId: 1, // TODO: 使用当前用户ID
                    content: _commentController.text,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  _controller.createComment(comment);
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
                Text(
                  '用户 ${comment.authorId}', // TODO: 显示用户名
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
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
              children: [
                IconButton(
                  icon: const Icon(Icons.thumb_up_outlined),
                  onPressed: () => _controller.likeComment(1, comment.id!),
                ),
                Text('${comment.likeCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.reply),
                  onPressed: () {
                    // TODO: 实现回复功能
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
} 