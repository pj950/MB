import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/moderator_controller.dart';
import '../models/moderator_model.dart';
import '../models/moderator_application_model.dart';
import '../models/moderator_log_model.dart';

class ModeratorPage extends StatelessWidget {
  final ModeratorController _controller = Get.put(ModeratorController());

  ModeratorPage({Key? key}) : super(key: key);

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

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.moderators.length,
        itemBuilder: (context, index) {
          final moderator = _controller.moderators[index];
          return _buildModeratorCard(moderator);
        },
      );
    });
  }

  Widget _buildModeratorCard(ModeratorModel moderator) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '用户ID：${moderator.userId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildRoleChip(moderator.role),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '权限：${moderator.permissions.join(", ")}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '创建时间：${_formatDate(moderator.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (_controller.isOwner() || _controller.isAdmin()) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showUpdatePermissionsDialog(moderator),
                    child: const Text('更新权限'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _showRemoveModeratorDialog(moderator),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('移除版主'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.applications.length,
        itemBuilder: (context, index) {
          final application = _controller.applications[index];
          return _buildApplicationCard(application);
        },
      );
    });
  }

  Widget _buildApplicationCard(ModeratorApplicationModel application) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '申请人ID：${application.userId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(application.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '申请理由：${application.reason}',
              style: const TextStyle(fontSize: 14),
            ),
            if (application.rejectReason != null) ...[
              const SizedBox(height: 8),
              Text(
                '拒绝理由：${application.rejectReason}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '申请时间：${_formatDate(application.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (application.status == 'pending' && (_controller.isOwner() || _controller.isAdmin())) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _showRejectDialog(application),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('拒绝'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _controller.approveApplication(application),
                    child: const Text('通过'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.logs.length,
        itemBuilder: (context, index) {
          final log = _controller.logs[index];
          return _buildLogCard(log);
        },
      );
    });
  }

  Widget _buildLogCard(ModeratorLogModel log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '操作：${_getActionText(log.action)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildTargetTypeChip(log.targetType),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '目标ID：${log.targetId}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '原因：${log.reason}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '操作时间：${_formatDate(log.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    Color color;
    String text;

    switch (role) {
      case 'owner':
        color = Colors.red;
        text = '所有者';
        break;
      case 'admin':
        color = Colors.orange;
        text = '管理员';
        break;
      case 'moderator':
        color = Colors.blue;
        text = '版主';
        break;
      default:
        color = Colors.grey;
        text = '未知';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = '待审核';
        break;
      case 'approved':
        color = Colors.green;
        text = '已通过';
        break;
      case 'rejected':
        color = Colors.red;
        text = '已拒绝';
        break;
      default:
        color = Colors.grey;
        text = '未知';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTargetTypeChip(String targetType) {
    Color color;
    String text;

    switch (targetType) {
      case 'post':
        color = Colors.blue;
        text = '帖子';
        break;
      case 'comment':
        color = Colors.green;
        text = '评论';
        break;
      case 'user':
        color = Colors.orange;
        text = '用户';
        break;
      default:
        color = Colors.grey;
        text = '未知';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showApplyDialog() {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('申请成为版主'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: '申请理由',
            hintText: '请说明您想成为版主的原因',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Get.back();
                _controller.applyForModerator(reasonController.text);
              } else {
                Get.snackbar(
                  '错误',
                  '请输入申请理由',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('提交'),
          ),
        ],
      ),
    );
  }

  void _showUpdatePermissionsDialog(ModeratorModel moderator) {
    final List<String> selectedPermissions = List.from(moderator.permissions);

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('更新权限'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                title: const Text('删除帖子'),
                value: selectedPermissions.contains('delete_post'),
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      selectedPermissions.add('delete_post');
                    } else {
                      selectedPermissions.remove('delete_post');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('删除评论'),
                value: selectedPermissions.contains('delete_comment'),
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      selectedPermissions.add('delete_comment');
                    } else {
                      selectedPermissions.remove('delete_comment');
                    }
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('封禁用户'),
                value: selectedPermissions.contains('ban_user'),
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      selectedPermissions.add('ban_user');
                    } else {
                      selectedPermissions.remove('ban_user');
                    }
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _controller.updateModeratorPermissions(moderator, selectedPermissions);
            },
            child: const Text('更新'),
          ),
        ],
      ),
    );
  }

  void _showRemoveModeratorDialog(ModeratorModel moderator) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('移除版主'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: '移除原因',
            hintText: '请输入移除该版主的原因',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Get.back();
                _controller.removeModerator(moderator, reasonController.text);
              } else {
                Get.snackbar(
                  '错误',
                  '请输入移除原因',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('移除'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(ModeratorApplicationModel application) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('拒绝申请'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: '拒绝原因',
            hintText: '请输入拒绝该申请的原因',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                Get.back();
                _controller.rejectApplication(application, reasonController.text);
              } else {
                Get.snackbar(
                  '错误',
                  '请输入拒绝原因',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('拒绝'),
          ),
        ],
      ),
    );
  }

  String _getActionText(String action) {
    switch (action) {
      case 'delete_post':
        return '删除帖子';
      case 'delete_comment':
        return '删除评论';
      case 'ban_user':
        return '封禁用户';
      case 'approve_application':
        return '通过申请';
      case 'reject_application':
        return '拒绝申请';
      case 'remove_moderator':
        return '移除版主';
      case 'update_permissions':
        return '更新权限';
      default:
        return action;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 