import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

class NotificationController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel currentUser = Get.find<UserModel>();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      notifications.value = await _databaseService.getNotifications(currentUser.id);
      unreadCount.value = await _databaseService.getUnreadNotificationCount(currentUser.id);
    } catch (e) {
      Get.snackbar('错误', '加载通知失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _databaseService.markNotificationAsRead(notificationId);
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
        unreadCount.value = (unreadCount.value - 1).clamp(0, double.infinity);
      }
    } catch (e) {
      Get.snackbar('错误', '标记通知已读失败：$e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _databaseService.markAllNotificationsAsRead(currentUser.id);
      notifications.value = notifications.map((n) => n.copyWith(isRead: true)).toList();
      unreadCount.value = 0;
    } catch (e) {
      Get.snackbar('错误', '标记所有通知已读失败：$e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _databaseService.deleteNotification(notificationId);
      notifications.removeWhere((n) => n.id == notificationId);
      if (!notifications.any((n) => n.id == notificationId && !n.isRead)) {
        unreadCount.value = (unreadCount.value - 1).clamp(0, double.infinity);
      }
    } catch (e) {
      Get.snackbar('错误', '删除通知失败：$e');
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      await _databaseService.deleteAllNotifications(currentUser.id);
      notifications.clear();
      unreadCount.value = 0;
    } catch (e) {
      Get.snackbar('错误', '删除所有通知失败：$e');
    }
  }

  Future<void> createNotification({
    required String type,
    required String title,
    required String content,
    String? targetType,
    String? targetId,
  }) async {
    try {
      final notification = NotificationModel(
        id: const Uuid().v4(),
        userId: currentUser.id,
        type: type,
        title: title,
        content: content,
        targetType: targetType,
        targetId: targetId,
        isRead: false,
        createdAt: DateTime.now().toIso8601String(),
      );

      await _databaseService.createNotification(notification);
      notifications.insert(0, notification);
      unreadCount.value++;
    } catch (e) {
      Get.snackbar('错误', '创建通知失败：$e');
    }
  }

  void handleNotificationClick(NotificationModel notification) async {
    if (!notification.isRead) {
      await markAsRead(notification.id);
    }

    switch (notification.type) {
      case 'system':
        // 处理系统通知点击
        break;
      case 'interaction':
        // 处理互动通知点击
        if (notification.targetType != null && notification.targetId != null) {
          switch (notification.targetType) {
            case 'post':
              Get.toNamed('/post/${notification.targetId}');
              break;
            case 'comment':
              Get.toNamed('/comment/${notification.targetId}');
              break;
            case 'channel':
              Get.toNamed('/channel/${notification.targetId}');
              break;
            case 'user':
              Get.toNamed('/user/${notification.targetId}');
              break;
          }
        }
        break;
      case 'level_up':
        Get.toNamed('/level');
        break;
      case 'reward':
        Get.toNamed('/rewards');
        break;
    }
  }
} 