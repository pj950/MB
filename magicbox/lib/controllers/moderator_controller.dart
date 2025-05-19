import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import '../models/channel_model.dart';
import '../models/content_report_model.dart';
import '../models/moderator_application_model.dart' as app;
import '../models/moderator_log_model.dart' as log;

class ModeratorController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel? currentUser = Get.find<UserModel?>();

  final RxList<UserModel> moderators = <UserModel>[].obs;
  final RxList<ChannelModel> channels = <ChannelModel>[].obs;
  final RxList<ContentReportModel> reports = <ContentReportModel>[].obs;
  final RxList<app.ModeratorApplicationModel> applications =
      <app.ModeratorApplicationModel>[].obs;
  final RxList<log.ModeratorLogModel> logs = <log.ModeratorLogModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (isAdmin()) {
      loadModerators();
      loadApplications();
      loadLogs();
    }
    loadChannels();
    loadReports();
  }

  bool isAdmin() {
    return currentUser?.type == UserType.ADMIN;
  }

  bool isModerator() {
    return currentUser?.type == UserType.MODERATOR ||
        currentUser?.type == UserType.ADMIN;
  }

  bool isOwner(ChannelModel channel) {
    return channel.ownerId == currentUser?.id.toString();
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
      final List<dynamic> reportsList =
          await _databaseService.getContentReports();
      reports.value = reportsList.cast<ContentReportModel>();
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

  Future<void> loadApplications() async {
    if (!isAdmin()) return;

    try {
      isLoading.value = true;
      final List<dynamic> applicationsList =
          await _databaseService.getModeratorApplications();
      applications.value =
          applicationsList.cast<app.ModeratorApplicationModel>();
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载申请列表失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadLogs() async {
    if (!isAdmin()) return;

    try {
      isLoading.value = true;
      final List<dynamic> logsList = await _databaseService.getModeratorLogs();
      logs.value = logsList.cast<log.ModeratorLogModel>();
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载日志列表失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addModerator(String userId) async {
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

      if (user.type == UserType.MODERATOR || user.type == UserType.ADMIN) {
        throw Exception('该用户已经是版主或管理员');
      }

      await _databaseService.updateUser(
        user.copyWith(type: UserType.MODERATOR),
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

  Future<void> removeModerator(String userId) async {
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

      if (user.type != UserType.MODERATOR) {
        throw Exception('该用户不是版主');
      }

      await _databaseService.updateUser(
        user.copyWith(type: UserType.PERSONAL),
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
        channel.copyWith(isPrivate: status == 'private'),
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

  Future<void> applyForModerator(String reason) async {
    if (currentUser == null) {
      Get.snackbar(
        '错误',
        '请先登录',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final application = app.ModeratorApplicationModel(
        id: null,
        channelId: '0',
        applicantId: currentUser!.id!.toString(),
        applicationContent: reason,
        status: app.ModeratorApplicationStatus.PENDING,
        createdAt: DateTime.now(),
      );

      await _databaseService.createModeratorApplication(application);

      Get.snackbar(
        '成功',
        '申请已提交',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadApplications();
    } catch (e) {
      Get.snackbar(
        '错误',
        '提交申请失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveApplication(
      app.ModeratorApplicationModel application) async {
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

      final user = await _databaseService.getUser(application.applicantId);
      if (user == null) {
        throw Exception('用户不存在');
      }

      await _databaseService.updateUser(
        user.copyWith(type: UserType.MODERATOR),
      );

      await _databaseService.updateModeratorApplicationStatus(
        int.parse(application.id),
        'approved',
      );

      Get.snackbar(
        '成功',
        '已批准申请',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadApplications();
      loadModerators();
    } catch (e) {
      Get.snackbar(
        '错误',
        '批准申请失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectApplication(
      app.ModeratorApplicationModel application) async {
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

      await _databaseService.updateModeratorApplicationStatus(
        int.parse(application.id),
        'rejected',
      );

      Get.snackbar(
        '成功',
        '已拒绝申请',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadApplications();
    } catch (e) {
      Get.snackbar(
        '错误',
        '拒绝申请失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateModeratorPermissions(
      UserModel moderator, Map<String, bool> permissions) async {
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

      await _databaseService.updateUser(
        moderator.copyWith(moderatorPermissions: permissions),
      );

      Get.snackbar(
        '成功',
        '已更新权限',
        snackPosition: SnackPosition.BOTTOM,
      );

      loadModerators();
    } catch (e) {
      Get.snackbar(
        '错误',
        '更新权限失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
