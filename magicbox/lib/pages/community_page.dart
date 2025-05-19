import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/community_controller.dart';
import '../models/channel_model.dart';
import 'channel_page.dart';

class CommunityPage extends StatelessWidget {
  final CommunityController controller = Get.find<CommunityController>();

  CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社区'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: 实现搜索功能
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.channels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.forum_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('暂无频道'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCreateChannelDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('创建频道'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.channels.length,
          itemBuilder: (context, index) {
            final channel = controller.channels[index];
            return _buildChannelCard(context, channel);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateChannelDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChannelCard(BuildContext context, ChannelModel channel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => Get.to(() => ChannelPage(channel: channel)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (channel.coverImage != null)
              Image.network(
                channel.coverImage!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    channel.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    channel.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: channel.tags
                        .map((tag) => Chip(
                              label: Text(tag),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateChannelDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    String? coverImage;
    bool isPrivate = false;
    const List<String> tags = [];

    showDialog(
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
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('私密频道'),
                value: isPrivate,
                onChanged: (value) {
                  isPrivate = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                Get.snackbar('错误', '请输入频道名称');
                return;
              }
              controller.createChannel(
                name: nameController.text,
                description: descriptionController.text,
                coverImage: coverImage,
                isPrivate: isPrivate,
                tags: tags,
              );
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}
