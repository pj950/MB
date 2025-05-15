import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import '../models/channel_model.dart';
import '../models/content_report_model.dart';

class ModeratorController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel? currentUser = Get.find<UserModel?>();

  final RxList<UserModel> moderators = <UserModel>[].obs;
  final RxList<ChannelModel> channels = <ChannelModel>[].obs;
  final RxList<ContentReportModel> reports = <ContentReportModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (isAdmin()) {
      loadModerators();
    }
    loadChannels();
    loadReports();
  }

  bool isAdmin() {
    return currentUser?.role == 'admin';
  }

  bool isModerator() {
    return currentUser?.role == 'moderator' || currentUser?.role == 'admin';
  }

  Future<void> loadModerators() async {
    if (!isAdmin()) return;

    try {
      isLoading.value = true;
      moderators.value = await _databaseService.getModerators();
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载版主列表失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadChannels() async {
    if (!isModerator()) return;

    try {
      isLoading.value = true;
      channels.value = await _databaseService.getChannels();
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载频道列表失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadReports() async {
    if (!isModerator()) return;

    try {
      isLoading.value = true;
      reports.value = await _databaseService.getContentReports(status: 'pending');
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载举报列表失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addModerator(int userId) async {
    if (!isAdmin()) {
      Get.snackbar(
        '错误',
        '权限不足',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final user = await _databaseService.getUser(userId);
      if (user == null) {
        throw Exception('用户不存在');
      }

      if (user.role == 'moderator' || user.role == 'admin') {
        throw Exception('该用户已经是版主或管理员');
      }

      await _databaseService.updateUser(
        user.copyWith(role: 'moderator'),
      );

      Get.snackbar(
        '成功',
        '已添加版主',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadModerators();
    } catch (e) {
      Get.snackbar(
        '错误',
        '添加版主失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeModerator(int userId) async {
    if (!isAdmin()) {
      Get.snackbar(
        '错误',
        '权限不足',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final user = await _databaseService.getUser(userId);
      if (user == null) {
        throw Exception('用户不存在');
      }

      if (user.role != 'moderator') {
        throw Exception('该用户不是版主');
      }

      await _databaseService.updateUser(
        user.copyWith(role: 'user'),
      );

      Get.snackbar(
        '成功',
        '已移除版主',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadModerators();
    } catch (e) {
      Get.snackbar(
        '错误',
        '移除版主失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateChannelStatus(int channelId, String status) async {
    if (!isModerator()) {
      Get.snackbar(
        '错误',
        '权限不足',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final channel = await _databaseService.getChannel(channelId);
      if (channel == null) {
        throw Exception('频道不存在');
      }

      await _databaseService.updateChannel(
        channel.copyWith(status: status),
      );

      Get.snackbar(
        '成功',
        '已更新频道状态',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadChannels();
    } catch (e) {
      Get.snackbar(
        '错误',
        '更新频道状态失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleReport(int reportId, String action, {String? note}) async {
    if (!isModerator()) {
      Get.snackbar(
        '错误',
        '权限不足',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final report = await _databaseService.getContentReport(reportId);
      if (report == null) {
        throw Exception('举报不存在');
      }

      if (report.status != 'pending') {
        throw Exception('该举报已处理');
      }

      String status = 'reviewed';
      String? reviewResult;
      if (action == 'approve') {
        reviewResult = 'approved';
      } else if (action == 'reject') {
        reviewResult = 'rejected';
      } else if (action == 'dismiss') {
        status = 'dismissed';
      }

      await _databaseService.updateContentReportStatus(
        reportId,
        status,
        reviewResult: reviewResult,
        reviewNote: note,
      );

      Get.snackbar(
        '成功',
        '已处理举报',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadReports();
    } catch (e) {
      Get.snackbar(
        '错误',
        '处理举报失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 