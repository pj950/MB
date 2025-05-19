import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../controllers/follow_controller.dart';
import '../services/database_service.dart';
import 'follow_page.dart';

class ProfilePage extends StatelessWidget {
  final UserModel? user;
  final AuthController authController = Get.find<AuthController>();
  final FollowController _followController = Get.find<FollowController>();
  final DatabaseService _databaseService = Get.find<DatabaseService>();

  ProfilePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final currentUser = user ?? authController.currentUser;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('请先登录'),
        ),
      );
    }

    final isCurrentUser = user == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人中心'),
        actions: [
          if (isCurrentUser)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _showLogoutDialog,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 用户信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: currentUser.avatarUrl != null
                          ? NetworkImage(currentUser.avatarUrl!)
                          : null,
                      child: currentUser.avatarUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentUser.username,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentUser.email ?? '未设置邮箱',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!isCurrentUser)
                      Obx(() {
                        final isFollowing = _followController.isFollowing(int.parse(currentUser.id!));
                        return ElevatedButton(
                          onPressed: () {
                            if (isFollowing) {
                              _followController.unfollowUser(int.parse(currentUser.id!));
                            } else {
                              _followController.followUser(int.parse(currentUser.id!));
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 基本信息卡片
            _buildInfoCard(
              context,
              '基本信息',
              [
                _buildInfoRow('邮箱', currentUser.email ?? '未设置'),
                if (currentUser.phoneNumber != null)
                  _buildInfoRow('电话', currentUser.phoneNumber!),
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
                    () => _showEditDialog('邮箱', currentUser.email ?? ''),
                  ),
                  if (currentUser.phoneNumber != null)
                    _buildActionRow(
                      '修改电话',
                      Icons.phone,
                      () => _showEditDialog('电话', currentUser.phoneNumber!),
                    ),
                  _buildActionRow(
                    '修改密码',
                    Icons.lock,
                    _showChangePasswordDialog,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // 功能列表
            _buildInfoCard(
              context,
              '功能',
              [
                _buildActionRow(
                  '设置',
                  Icons.settings,
                  () => Get.toNamed('/settings'),
                ),
                _buildActionRow(
                  '帮助',
                  Icons.help,
                  () => Get.toNamed('/help'),
                ),
                _buildActionRow(
                  '统计',
                  Icons.analytics,
                  () => Get.toNamed('/statistics'),
                ),
                _buildActionRow(
                  '订阅',
                  Icons.card_membership,
                  () => Get.toNamed('/subscription'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatButton(BuildContext context, String label, VoidCallback onTap) {
    return FutureBuilder<int>(
      future: label == '关注'
          ? _databaseService.getFollowingCount(user?.id ?? authController.currentUser?.id ?? '')
          : _databaseService.getFollowerCount(user?.id ?? authController.currentUser?.id ?? ''),
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
              if (controller.text.isEmpty) {
                Get.snackbar('错误', '请输入$field');
                return;
              }
              Get.back(result: controller.text);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result != null) {
      final user = authController.currentUser;
      if (user != null) {
        UserModel updatedUser;
        if (field == '邮箱') {
          updatedUser = user.copyWith(email: result);
        } else if (field == '电话') {
          updatedUser = user.copyWith(phoneNumber: result);
        } else {
          return;
        }
        await _databaseService.updateUser(updatedUser);
        authController.updateProfile(updatedUser);
        Get.snackbar('成功', '修改$field成功');
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
                labelText: '确认密码',
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
              if (currentPasswordController.text.isEmpty ||
                  newPasswordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {
                Get.snackbar('错误', '请填写所有密码字段');
                return;
              }

              if (newPasswordController.text != confirmPasswordController.text) {
                Get.snackbar('错误', '两次输入的新密码不一致');
                return;
              }

              // TODO: 验证当前密码
              Get.back(result: true);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result == true) {
      // TODO: 实现密码修改逻辑
      Get.snackbar('成功', '密码修改成功');
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
      await authController.logout();
      Get.offAllNamed('/login');
    }
  }
}
