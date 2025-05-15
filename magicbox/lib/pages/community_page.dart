import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/community_controller.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/user_model.dart';
import '../controllers/auth_controller.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/error_view.dart';
import '../utils/page_transitions.dart';
import '../models/channel_model.dart';
import 'channel_page.dart';
import 'post_detail_page.dart';

class CommunityPage extends StatelessWidget {
  final CommunityController _controller = Get.put(CommunityController());
  final AuthController _authController = Get.find<AuthController>();

  CommunityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadChannels(),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.channels.isEmpty) {
          return const Center(
            child: Text(
              '暂无频道',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: _controller.channels.length,
          itemBuilder: (context, index) {
            final channel = _controller.channels[index];
            return _buildChannelCard(channel);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateChannelDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChannelCard(ChannelModel channel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Get.to(() => ChannelPage(channelId: channel.id!)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  channel.coverImage,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Text(
                      channel.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('帖子：${channel.postCount}'),
                      Text('成员：${channel.memberCount}'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateChannelDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final themeColorController = TextEditingController(text: '#2196F3');

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建频道'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '频道名称',
                  hintText: '请输入频道名称',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '频道描述',
                  hintText: '请输入频道描述',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: themeColorController,
                decoration: const InputDecoration(
                  labelText: '主题颜色',
                  hintText: '请输入十六进制颜色代码',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  '错误',
                  '请输入频道名称',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              final channel = ChannelModel(
                name: nameController.text,
                description: descriptionController.text,
                coverImage: 'https://via.placeholder.com/300x120',
                themeColor: themeColorController.text,
                ownerId: 1, // TODO: 使用当前用户ID
                moderatorId: 1, // TODO: 使用当前用户ID
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              await _controller.createChannel(channel);
              Get.back();
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
} 