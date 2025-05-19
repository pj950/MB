import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/moderator_controller.dart';
import '../models/user_model.dart';

class ModeratorPage extends StatelessWidget {
  final ModeratorController _controller = Get.put(ModeratorController());

  ModeratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('版主管理'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '版主'),
              Tab(text: '申请'),
              Tab(text: '日志'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildModeratorsTab(),
            _buildApplicationsTab(),
            _buildLogsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeratorsTab() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!_controller.isModerator()) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('您不是版主，无法查看此页面'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showApplyDialog(),
                child: const Text('申请成为版主'),
              ),
            ],
          ),
        );
      }

      if (_controller.moderators.isEmpty) {
        return const Center(child: Text('暂无版主'));
      }

      return _buildModeratorList();
    });
  }

  Widget _buildModeratorList() {
    return ListView.builder(
      itemCount: _controller.moderators.length,
      itemBuilder: (context, index) {
        final moderator = _controller.moderators[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: moderator.avatarUrl != null
                ? NetworkImage(moderator.avatarUrl!)
                : null,
            child: moderator.avatarUrl == null
                ? Text(moderator.username[0].toUpperCase())
                : null,
          ),
          title: Text(moderator.username),
          subtitle: Text(moderator.type.toString()),
          trailing: _controller.isAdmin()
              ? IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditPermissionsDialog(moderator),
                )
              : null,
        );
      },
    );
  }

  Widget _buildApplicationsTab() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!_controller.isModerator()) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('您不是版主，无法查看此页面'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showApplyDialog(),
                child: const Text('申请成为版主'),
              ),
            ],
          ),
        );
      }

      if (_controller.applications.isEmpty) {
        return const Center(child: Text('暂无申请'));
      }

      return _buildApplicationList();
    });
  }

  Widget _buildApplicationList() {
    return ListView.builder(
      itemCount: _controller.applications.length,
      itemBuilder: (context, index) {
        final application = _controller.applications[index];
        return ListTile(
          title: Text('申请ID: ${application.id}'),
          subtitle: Text(application.applicationContent),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_controller.isAdmin())
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => _controller.approveApplication(application),
                ),
              if (_controller.isAdmin())
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _controller.rejectApplication(application),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogsTab() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!_controller.isModerator()) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('您不是版主，无法查看此页面'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showApplyDialog(),
                child: const Text('申请成为版主'),
              ),
            ],
          ),
        );
      }

      if (_controller.logs.isEmpty) {
        return const Center(child: Text('暂无日志'));
      }

      return _buildLogList();
    });
  }

  Widget _buildLogList() {
    return ListView.builder(
      itemCount: _controller.logs.length,
      itemBuilder: (context, index) {
        final log = _controller.logs[index];
        return ListTile(
          title: Text(log.action.toString()),
          subtitle: Text(log.reason),
          trailing: Text(log.createdAt.toString()),
        );
      },
    );
  }

  void _showApplyDialog() {
    final TextEditingController reasonController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('申请成为版主'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: '申请理由',
            hintText: '请简要说明您申请成为版主的理由',
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
              if (reasonController.text.isEmpty) {
                Get.snackbar(
                  '错误',
                  '请填写申请理由',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }
              _controller.applyForModerator(reasonController.text);
              Get.back();
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  void _showEditPermissionsDialog(UserModel moderator) {
    final Map<String, bool> permissions =
        Map<String, bool>.from(moderator.moderatorPermissions ?? {});

    Get.dialog(
      AlertDialog(
        title: Text('编辑${moderator.username}的权限'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('管理用户'),
              value: permissions['manage_users'] ?? false,
              onChanged: (value) {
                permissions['manage_users'] = value ?? false;
              },
            ),
            CheckboxListTile(
              title: const Text('管理内容'),
              value: permissions['manage_content'] ?? false,
              onChanged: (value) {
                permissions['manage_content'] = value ?? false;
              },
            ),
            CheckboxListTile(
              title: const Text('管理评论'),
              value: permissions['manage_comments'] ?? false,
              onChanged: (value) {
                permissions['manage_comments'] = value ?? false;
              },
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
              _controller.updateModeratorPermissions(moderator, permissions);
              Get.back();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
