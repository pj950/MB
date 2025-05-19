import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/level_model.dart';
import '../models/user_model.dart';

class LevelController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel _currentUser = Get.find<UserModel>();

  final RxList<LevelModel> levels = <LevelModel>[].obs;
  final Rx<UserLevelModel?> userLevel = Rx<UserLevelModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadLevelData();
  }

  Future<void> loadLevelData() async {
    try {
      isLoading.value = true;

      // 加载所有等级
      final allLevels = await _databaseService.getLevels();
      levels.value = allLevels;

      // 加载用户等级信息
      final userLevelData =
          await _databaseService.getUserLevel(_currentUser.id.toString());
      if (userLevelData == null) {
        // 如果用户没有等级记录，创建初始等级
        final initialLevel = UserLevelModel(
          userId: _currentUser.id.toString(),
          level: 1,
          exp: 0,
          totalExp: 0,
          lastExpUpdate: DateTime.now(),
        );
        await _databaseService.createUserLevel(initialLevel);
        userLevel.value = initialLevel;
      } else {
        userLevel.value = userLevelData;
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载等级数据失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 获取当前等级信息
  LevelModel? getCurrentLevel() {
    if (userLevel.value == null) return null;
    return levels.firstWhere(
      (level) => level.level == userLevel.value!.level,
      orElse: () => levels.first,
    );
  }

  // 获取下一等级信息
  LevelModel? getNextLevel() {
    if (userLevel.value == null) return null;
    return levels.firstWhere(
      (level) => level.level > userLevel.value!.level,
      orElse: () => levels.last,
    );
  }

  // 计算升级进度
  double getLevelProgress() {
    if (userLevel.value == null) return 0.0;

    final currentLevel = getCurrentLevel();
    final nextLevel = getNextLevel();

    if (currentLevel == null || nextLevel == null) return 1.0;

    final currentExp = userLevel.value!.totalExp;
    final requiredExp = nextLevel.requiredExp - currentLevel.requiredExp;
    final userExp = currentExp - currentLevel.requiredExp;

    return (userExp / requiredExp).clamp(0.0, 1.0);
  }

  // 添加经验值
  Future<void> addExp(int exp) async {
    if (exp <= 0) return;

    try {
      isLoading.value = true;

      final oldLevel = userLevel.value!.level;
      await _databaseService.addUserExp(_currentUser.id.toString(), exp);

      // 重新加载用户等级信息
      final updatedUserLevel =
          await _databaseService.getUserLevel(_currentUser.id.toString());
      if (updatedUserLevel != null) {
        userLevel.value = updatedUserLevel;

        // 如果升级了，显示升级提示
        if (updatedUserLevel.level > oldLevel) {
          final newLevel = getCurrentLevel();
          if (newLevel != null) {
            Get.snackbar(
              '恭喜升级！',
              '你已升级到 ${newLevel.title}',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 3),
            );
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '添加经验值失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 检查用户是否有特定权限
  bool hasPrivilege(String privilege) {
    final currentLevel = getCurrentLevel();
    if (currentLevel == null) return false;
    return currentLevel.privileges.contains(privilege);
  }
}
