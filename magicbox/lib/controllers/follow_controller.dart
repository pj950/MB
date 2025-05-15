import 'package:get/get.dart';
import '../models/follow_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class FollowController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final RxList<FollowModel> _followers = <FollowModel>[].obs;
  final RxList<FollowModel> _following = <FollowModel>[].obs;
  final RxList<UserModel> _followerUsers = <UserModel>[].obs;
  final RxList<UserModel> _followingUsers = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;

  List<FollowModel> get followers => _followers;
  List<FollowModel> get following => _following;
  List<UserModel> get followerUsers => _followerUsers;
  List<UserModel> get followingUsers => _followingUsers;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadFollowData();
  }

  Future<void> loadFollowData() async {
    try {
      _isLoading.value = true;
      
      // 获取当前用户ID
      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) return;

      // 加载关注者和被关注者数据
      final followers = await _databaseService.getFollowers(currentUser.id!);
      final following = await _databaseService.getFollowing(currentUser.id!);
      
      _followers.value = followers;
      _following.value = following;

      // 加载用户详细信息
      final followerUsers = await Future.wait(
        followers.map((f) => _databaseService.getUser(f.followerId))
      );
      final followingUsers = await Future.wait(
        following.map((f) => _databaseService.getUser(f.followingId))
      );

      _followerUsers.value = followerUsers.whereType<UserModel>().toList();
      _followingUsers.value = followingUsers.whereType<UserModel>().toList();
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载关注数据失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> followUser(int userId) async {
    try {
      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) return;

      final follow = FollowModel(
        followerId: currentUser.id!,
        followingId: userId,
      );

      await _databaseService.createFollow(follow);
      await loadFollowData();

      Get.snackbar(
        '成功',
        '关注成功',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '关注失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> unfollowUser(int userId) async {
    try {
      final currentUser = await _databaseService.getCurrentUser();
      if (currentUser == null) return;

      await _databaseService.deleteFollow(currentUser.id!, userId);
      await loadFollowData();

      Get.snackbar(
        '成功',
        '取消关注成功',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '取消关注失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  bool isFollowing(int userId) {
    return _following.any((f) => f.followingId == userId);
  }

  Future<void> refresh() async {
    await loadFollowData();
  }
} 