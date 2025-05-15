import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/channel_application_model.dart';
import '../models/channel_application_review_model.dart';
import '../models/user_model.dart';

class ChannelApplicationController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel? currentUser = Get.find<UserModel?>();

  final RxList<ChannelApplicationModel> applications = <ChannelApplicationModel>[].obs;
  final RxList<ChannelApplicationReviewModel> reviews = <ChannelApplicationReviewModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<ChannelApplicationModel?> currentApplication = Rx<ChannelApplicationModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadApplications();
  }

  Future<void> loadApplications() async {
    try {
      isLoading.value = true;
      applications.value = await _databaseService.getChannelApplications(
        userId: currentUser?.id,
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
      currentApplication.value = await _databaseService.getChannelApplication(id);
      if (currentApplication.value != null) {
        reviews.value = await _databaseService.getChannelApplicationReviews(id);
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
        userId: currentUser!.id!,
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
      final review = ChannelApplicationReviewModel(
        applicationId: id,
        reviewerId: currentUser!.id!,
        action: 'approve',
        createdAt: DateTime.now(),
      );
      await _databaseService.createChannelApplicationReview(review);

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
      final review = ChannelApplicationReviewModel(
        applicationId: id,
        reviewerId: currentUser!.id!,
        action: 'reject',
        reason: reason,
        createdAt: DateTime.now(),
      );
      await _databaseService.createChannelApplicationReview(review);

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
    return currentUser?.role == 'moderator' || currentUser?.role == 'admin';
  }
} 