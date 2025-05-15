import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/follow_controller.dart';
import '../models/user_model.dart';
import 'profile_page.dart';

class FollowPage extends StatelessWidget {
  final FollowController _controller = Get.put(FollowController());
  final bool isFollowers;

  FollowPage({Key? key, required this.isFollowers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isFollowers ? '我的粉丝' : '我的关注'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.refresh,
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = isFollowers ? _controller.followerUsers : _controller.followingUsers;
        
        if (users.isEmpty) {
          return Center(
            child: Text(
              isFollowers ? '暂无粉丝' : '暂无关注',
              style: const TextStyle(fontSize: 16),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _controller.refresh,
          child: ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserTile(user);
            },
          ),
        );
      }),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.avatarUrl != null
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null
            ? Text(user.username[0].toUpperCase())
            : null,
      ),
      title: Text(user.username),
      subtitle: Text(user.email),
      trailing: !isFollowers
          ? TextButton(
              onPressed: () => _controller.unfollowUser(user.id!),
              child: const Text('取消关注'),
            )
          : null,
      onTap: () => Get.to(() => ProfilePage(userId: user.id)),
    );
  }
} 