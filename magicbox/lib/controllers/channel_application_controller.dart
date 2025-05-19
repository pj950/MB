import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/channel_application_model.dart';
import '../models/channel_application_review_model.dart' as review;
import '../models/user_model.dart';

class ChannelApplicationController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel? currentUser = Get.find<UserModel?>();

  final RxList<ChannelApplicationModel> applications =
      <ChannelApplicationModel>[].obs;
  final RxList<review.ChannelApplicationReviewModel> reviews =
      <review.ChannelApplicationReviewModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<ChannelApplicationModel?> currentApplication =
      Rx<ChannelApplicationModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadApplications();
  }

  Future<void> loadApplications() async {
    try {
      isLoading.value = true;
      applications.value = await _databaseService.getChannelApplications(
        userId: currentUser?.id != null ? int.tryParse(currentUser!.id!) : null,
      );
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

  Future<void> loadApplicationDetails(int id) async {
    try {
      isLoading.value = true;
      currentApplication.value =
          await _databaseService.getChannelApplication(id);
      if (currentApplication.value != null) {
        final reviewList =
            await _databaseService.getChannelApplicationReviews(id);
        reviews.value = reviewList
            .map((item) =>
                review.ChannelApplicationReviewModel.fromMap(item.toMap()))
            .toList();
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载申请详情失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createApplication({
    required String name,
    required String description,
    required String category,
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

      final application = ChannelApplicationModel(
        userId: int.parse(currentUser!.id!),
        name: name,
        description: description,
        category: category,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.createChannelApplication(application);

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

  Future<void> approveApplication(int id) async {
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

      // 更新申请状态
      await _databaseService.updateChannelApplicationStatus(id, 'approved');

      // 创建审核记录
      final reviewModel = review.ChannelApplicationReviewModel(
        channelId: id.toString(),
        applicantId: currentApplication.value?.userId.toString() ?? '',
        applicationContent: currentApplication.value?.description ?? '',
        status: review.ApplicationStatus.APPROVED,
        reviewerId: currentUser!.id!.toString(),
        reviewedAt: DateTime.now(),
      );
      await _databaseService.createChannelApplicationReview(reviewModel);

      Get.snackbar(
        '成功',
        '已批准申请',
        snackPosition: SnackPosition.BOTTOM,
      );
      loadApplications();
    } catch (e) {
      Get.snackbar(
        '错误',
        '操作失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectApplication(int id, String reason) async {
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

      // 更新申请状态
      await _databaseService.updateChannelApplicationStatus(
        id,
        'rejected',
        rejectReason: reason,
      );

      // 创建审核记录
      final reviewModel = review.ChannelApplicationReviewModel(
        channelId: id.toString(),
        applicantId: currentApplication.value?.userId.toString() ?? '',
        applicationContent: currentApplication.value?.description ?? '',
        status: review.ApplicationStatus.REJECTED,
        reviewerId: currentUser!.id!.toString(),
        reviewNote: reason,
        reviewedAt: DateTime.now(),
      );
      await _databaseService.createChannelApplicationReview(reviewModel);

      Get.snackbar(
        '成功',
        '已拒绝申请',
        snackPosition: SnackPosition.BOTTOM,
      );
      loadApplications();
    } catch (e) {
      Get.snackbar(
        '错误',
        '操作失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool isModerator() {
    return currentUser?.type == UserType.ADMIN ||
        currentUser?.type == UserType.MODERATOR;
  }
}
