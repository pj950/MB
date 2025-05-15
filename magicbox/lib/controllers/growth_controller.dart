import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/checkin_model.dart';
import '../models/level_model.dart';
import '../models/user_model.dart';

class GrowthController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  
  final Rx<CheckinModel?> lastCheckin = Rx<CheckinModel?>(null);
  final Rx<LevelModel> currentLevel = Rx<LevelModel>(LevelModel(
    level: 1,
    name: '新手',
    requiredExperience: 0,
    pointsMultiplier: 1,
    coinsMultiplier: 1,
    privileges: ['基础功能'],
  ));
  final Rx<LevelModel?> nextLevel = Rx<LevelModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserGrowth();
  }

  Future<void> loadUserGrowth() async {
    isLoading.value = true;
    try {
      final userId = 1; // TODO: 使用当前用户ID
      final user = await _databaseService.getUser(userId);
      if (user != null) {
        lastCheckin.value = await _databaseService.getLastCheckin(userId);
        currentLevel.value = await _databaseService.getCurrentLevel(user.experience);
        nextLevel.value = await _databaseService.getNextLevel(user.experience);
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载成长信息失败',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkin() async {
    isLoading.value = true;
    try {
      final userId = 1; // TODO: 使用当前用户ID
      final lastCheckinDate = lastCheckin.value?.checkinDate;
      final now = DateTime.now();
      
      if (lastCheckinDate != null) {
        final lastDate = DateTime(
          lastCheckinDate.year,
          lastCheckinDate.month,
          lastCheckinDate.day,
        );
        final today = DateTime(now.year, now.month, now.day);
        
        if (today.isAtSameMomentAs(lastDate)) {
          Get.snackbar(
            '提示',
            '今天已经签到过了',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      await _databaseService.checkin(userId);
      await loadUserGrowth();
      
      Get.snackbar(
        '成功',
        '签到成功，获得${lastCheckin.value?.pointsEarned}积分和${lastCheckin.value?.coinsEarned}金币',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '签到失败',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addExperience(int experience) async {
    isLoading.value = true;
    try {
      final userId = 1; // TODO: 使用当前用户ID
      await _databaseService.addExperience(userId, experience);
      await loadUserGrowth();
      
      if (nextLevel.value != null && currentLevel.value.level > lastCheckin.value?.consecutiveDays ?? 0) {
        Get.snackbar(
          '恭喜',
          '升级到${currentLevel.value.name}！',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '添加经验失败',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool hasPrivilege(String privilege) {
    return currentLevel.value.privileges.contains(privilege);
  }

  int getPointsMultiplier() {
    return currentLevel.value.pointsMultiplier;
  }

  int getCoinsMultiplier() {
    return currentLevel.value.coinsMultiplier;
  }

  int getExperienceToNextLevel() {
    if (nextLevel.value == null) return 0;
    return nextLevel.value!.requiredExperience - currentLevel.value.requiredExperience;
  }

  double getLevelProgress() {
    if (nextLevel.value == null) return 1.0;
    final currentExp = currentLevel.value.requiredExperience;
    final nextExp = nextLevel.value!.requiredExperience;
    final totalExp = nextExp - currentExp;
    final user = _databaseService.getUser(1); // TODO: 使用当前用户ID
    if (user == null) return 0.0;
    return (user.experience - currentExp) / totalExp;
  }
} 