import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/content_report_model.dart' as report_model;
import '../models/content_review_model.dart';
import '../models/user_model.dart';

class ContentReviewController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel? currentUser = Get.find<UserModel?>();

  final RxList<report_model.ContentReportModel> reports =
      <report_model.ContentReportModel>[].obs;
  final RxList<ContentReviewModel> reviews = <ContentReviewModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<report_model.ContentReportModel?> currentReport =
      Rx<report_model.ContentReportModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports({String? status}) async {
    try {
      isLoading.value = true;
      final List<dynamic> rawReports =
          await _databaseService.getContentReports(status: status);
      reports.value = rawReports
          .map((r) => report_model.ContentReportModel.fromMap(r))
          .toList();
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

  Future<void> loadReportDetails(int id) async {
    try {
      isLoading.value = true;
      final rawReport = await _databaseService.getContentReport(id);
      currentReport.value = rawReport != null
          ? report_model.ContentReportModel.fromMap(rawReport.toMap())
          : null;
      if (currentReport.value != null) {
        reviews.value = await _databaseService.getContentReviews(id);
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载举报详情失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createReport({
    required String targetType,
    required int targetId,
    required String reason,
  }) async {
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

      final newReport = report_model.ContentReportModel(
        reporterId: currentUser!.id.toString(),
        targetType: targetType,
        targetId: targetId.toString(),
        type: report_model.ReportType.OTHER,
        description: reason,
        createdAt: DateTime.now(),
      );

      await _databaseService.createContentReport(newReport);

      Get.snackbar(
        '成功',
        '举报已提交',
        snackPosition: SnackPosition.BOTTOM,
      );
      loadReports();
    } catch (e) {
      Get.snackbar(
        '错误',
        '提交举报失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reviewReport({
    required int reportId,
    required String action,
    String? note,
  }) async {
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

      // 创建审核记录
      final review = ContentReviewModel(
        reportId: reportId,
        reviewerId: int.parse(currentUser!.id!),
        action: action,
        note: note,
        createdAt: DateTime.now(),
      );
      await _databaseService.createContentReview(review);

      // 更新举报状态
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
        '审核完成',
        snackPosition: SnackPosition.BOTTOM,
      );
      loadReports();
    } catch (e) {
      Get.snackbar(
        '错误',
        '审核失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool isModerator() {
    return currentUser?.type == UserType.MODERATOR ||
        currentUser?.type == UserType.ADMIN;
  }
}
