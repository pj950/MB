import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/follow_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../models/follow_model.dart';
import '../services/database_service.dart';
import 'profile_page.dart';

class FollowPage extends StatelessWidget {
  final bool isFollowers;
  final FollowController _followController = Get.find<FollowController>();
  final AuthController _authController = Get.find<AuthController>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  FollowPage({super.key, required this.isFollowers});

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authController.currentUser?.id ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(isFollowers ? '粉丝' : '关注'),
      ),
      body: FutureBuilder<List<FollowModel>>(
        future: isFollowers
            ? _databaseService.getFollowers(currentUserId)
            : _databaseService.getFollowing(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                isFollowers ? '还没有粉丝' : '还没有关注任何人',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final follow = snapshot.data![index];
              final userId = isFollowers ? follow.followerId : follow.followingId;
              return FutureBuilder<UserModel?>(
                future: _databaseService.getUserById(userId.toString()),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  final user = userSnapshot.data!;
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
                    subtitle: Text(user.email ?? ''),
                    trailing: Obx(() {
                      final isFollowing = _followController.isFollowing(int.parse(user.id!));
                      if (user.id == currentUserId) {
                        return const Text('我');
                      }
                      return TextButton(
                        onPressed: () {
                          if (isFollowing) {
                            _followController.unfollowUser(int.parse(user.id!));
                          } else {
                            _followController.followUser(int.parse(user.id!));
                          }
                        },
                        child: Text(isFollowing ? '取消关注' : '关注'),
                      );
                    }),
                    onTap: () => Get.to(() => ProfilePage(user: user)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
