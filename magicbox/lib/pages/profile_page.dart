import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../controllers/follow_controller.dart';
import '../services/database_service.dart';
import 'follow_page.dart';

class ProfilePage extends StatelessWidget {
  final int? userId;
  final FollowController _followController = Get.put(FollowController());
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  ProfilePage({Key? key, this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        actions: [
          if (userId == null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _showLogoutDialog,
            ),
        ],
      ),
      body: FutureBuilder<UserModel?>(
        future: userId != null
            ? _databaseService.getUser(userId!)
            : _databaseService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('用户不存在'));
          }

          final user = snapshot.data!;
          final isCurrentUser = userId == null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.username[0].toUpperCase(),
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  user.username,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  user.userType,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 24),
                if (!isCurrentUser)
                  Obx(() {
                    final isFollowing = _followController.isFollowing(user.id!);
                    return ElevatedButton(
                      onPressed: () {
                        if (isFollowing) {
                          _followController.unfollowUser(user.id!);
                        } else {
                          _followController.followUser(user.id!);
                        }
                      },
                      child: Text(isFollowing ? '取消关注' : '关注'),
                    );
                  }),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatButton(
                      context,
                      '关注',
                      () => Get.to(() => FollowPage(isFollowers: false)),
                    ),
                    _buildStatButton(
                      context,
                      '粉丝',
                      () => Get.to(() => FollowPage(isFollowers: true)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildInfoCard(
                  context,
                  '基本信息',
                  [
                    _buildInfoRow('邮箱', user.email),
                    if (user.phone != null)
                      _buildInfoRow('电话', user.phone!),
                  ],
                ),
                if (isCurrentUser) ...[
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    context,
                    '账号设置',
                    [
                      _buildActionRow(
                        '修改邮箱',
                        Icons.email,
                        () => _showEditDialog('邮箱', user.email),
                      ),
                      if (user.phone != null)
                        _buildActionRow(
                          '修改电话',
                          Icons.phone,
                          () => _showEditDialog('电话', user.phone!),
                        ),
                      _buildActionRow(
                        '修改密码',
                        Icons.lock,
                        _showChangePasswordDialog,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatButton(BuildContext context, String label, VoidCallback onTap) {
    return FutureBuilder<int>(
      future: label == '关注'
          ? _databaseService.getFollowingCount(userId ?? 0)
          : _databaseService.getFollowerCount(userId ?? 0),
      builder: (context, snapshot) {
        return InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                snapshot.hasData ? snapshot.data.toString() : '0',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label：',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildActionRow(String label, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _showEditDialog(String field, String currentValue) async {
    final controller = TextEditingController(text: currentValue);
    final result = await Get.dialog<String>(
      AlertDialog(
        title: Text('修改$field'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: field,
            hintText: '请输入新的$field',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Get.back(result: controller.text);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final currentUser = await _databaseService.getCurrentUser();
        if (currentUser == null) return;

        final updatedUser = currentUser.copyWith(
          email: field == '邮箱' ? result : currentUser.email,
          phone: field == '电话' ? result : currentUser.phone,
        );

        await _databaseService.updateUser(updatedUser);
        Get.snackbar('成功', '$field修改成功');
      } catch (e) {
        Get.snackbar('错误', '$field修改失败：$e');
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('修改密码'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              decoration: const InputDecoration(
                labelText: '当前密码',
                hintText: '请输入当前密码',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: '新密码',
                hintText: '请输入新密码',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: '确认新密码',
                hintText: '请再次输入新密码',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (currentPasswordController.text.isNotEmpty &&
                  newPasswordController.text.isNotEmpty &&
                  confirmPasswordController.text.isNotEmpty &&
                  newPasswordController.text == confirmPasswordController.text) {
                Get.back(result: true);
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final currentUser = await _databaseService.getCurrentUser();
        if (currentUser == null) return;

        // TODO: 验证当前密码
        await _databaseService.updateUser(
          currentUser.copyWith(password: newPasswordController.text),
        );
        Get.snackbar('成功', '密码修改成功');
      } catch (e) {
        Get.snackbar('错误', '密码修改失败：$e');
      }
    }
  }

  Future<void> _showLogoutDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await _databaseService.logout();
        Get.offAllNamed('/login');
      } catch (e) {
        Get.snackbar('错误', '退出登录失败：$e');
      }
    }
  }
} 