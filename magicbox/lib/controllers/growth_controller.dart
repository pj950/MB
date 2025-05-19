import 'package:get/get.dart';
import '../models/level_model.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../models/checkin_model.dart';
import 'package:uuid/uuid.dart';

class GrowthController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel? currentUser = Get.find<UserModel?>();

  final Rx<UserLevelModel?> _userLevel = Rx<UserLevelModel?>(null);
  final RxList<LevelModel> _levels = <LevelModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _canCheckin = false.obs;
  final Rx<LevelModel?> _currentLevel = Rx<LevelModel?>(null);
  final Rx<LevelModel?> _nextLevel = Rx<LevelModel?>(null);
  final Rx<CheckinModel?> _lastCheckin = Rx<CheckinModel?>(null);

  UserLevelModel? get userLevel => _userLevel.value;
  List<LevelModel> get levels => _levels;
  bool get isLoading => _isLoading.value;
  bool get canCheckin => _canCheckin.value;
  LevelModel get currentLevel => _currentLevel.value!;
  LevelModel? get nextLevel => _nextLevel.value;
  CheckinModel? get lastCheckin => _lastCheckin.value;

  @override
  void onInit() {
    super.onInit();
    loadUserLevel();
    loadLevels();
    checkCheckinStatus();
  }

  Future<void> loadUserGrowth() async {
    await Future.wait([
      loadUserLevel(),
      loadLevels(),
      checkCheckinStatus(),
    ]);
  }

  Future<void> loadUserLevel() async {
    try {
      _isLoading.value = true;

      if (currentUser == null) return;

      final userId = currentUser!.id!.toString();
      final userLevel = await _databaseService.getUserLevel(userId);
      _userLevel.value = userLevel;

      // 更新当前等级和下一等级
      if (userLevel != null) {
        _currentLevel.value = _levels.firstWhere(
          (level) => level.level == userLevel.level,
          orElse: () => _levels.first,
        );

        final nextLevelIndex = _levels.indexWhere(
              (level) => level.level == _currentLevel.value!.level,
            ) +
            1;
        if (nextLevelIndex < _levels.length) {
          _nextLevel.value = _levels[nextLevelIndex];
        } else {
          _nextLevel.value = null;
        }
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载用户等级失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadLevels() async {
    try {
      _isLoading.value = true;

      final levels = await _databaseService.getLevels();
      _levels.value = levels;
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载等级列表失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> checkCheckinStatus() async {
    try {
      if (currentUser == null) return;

      final userId = currentUser!.id!.toString();
      final checkins = await _databaseService.getCheckinHistory(userId);
      if (checkins.isNotEmpty) {
        _lastCheckin.value = checkins.first;
      }

      final now = DateTime.now();
      final lastCheckinDate =
          checkins.isNotEmpty ? checkins.first.checkinDate : null;
      _canCheckin.value = lastCheckinDate == null ||
          now.difference(lastCheckinDate).inDays >= 1;
    } catch (e) {
      Get.snackbar(
        '错误',
        '检查签到状态失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> checkin() async {
    try {
      if (currentUser == null) {
        Get.snackbar(
          '错误',
          '请先登录',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (!_canCheckin.value) {
        Get.snackbar(
          '提示',
          '今天已经签到过了',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final userId = currentUser!.id!.toString();
      final checkin = CheckinModel(
        id: const Uuid().v4(),
        userId: userId,
        checkinDate: DateTime.now(),
        pointsEarned: 10,
        coinsEarned: 5,
        consecutiveDays: (_lastCheckin.value?.consecutiveDays ?? 0) + 1,
      );
      await _databaseService.createCheckin(checkin);
      _lastCheckin.value = checkin;
      _canCheckin.value = false;

      // 更新用户等级和经验
      await loadUserLevel();

      Get.snackbar(
        '成功',
        '签到成功',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '签到失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  double getLevelProgress() {
    if (_userLevel.value == null) return 0.0;

    final currentLevel = _currentLevel.value;
    final nextLevel = _nextLevel.value;

    if (currentLevel == null || nextLevel == null) return 0.0;

    final currentExp = _userLevel.value!.exp;
    final requiredExp = nextLevel.requiredExp - currentLevel.requiredExp;
    final userExp = currentExp - currentLevel.requiredExp;

    return userExp / requiredExp;
  }

  int getExperienceToNextLevel() {
    if (_userLevel.value == null) return 0;

    final currentLevel = _currentLevel.value;
    final nextLevel = _nextLevel.value;

    if (currentLevel == null || nextLevel == null) return 0;

    final currentExp = _userLevel.value!.exp;
    final requiredExp = nextLevel.requiredExp - currentLevel.requiredExp;
    final userExp = currentExp - currentLevel.requiredExp;

    return requiredExp - userExp;
  }

  double getPointsMultiplier() {
    if (_currentLevel.value == null) return 1.0;
    return _currentLevel.value!.pointsMultiplier;
  }

  double getCoinsMultiplier() {
    if (_currentLevel.value == null) return 1.0;
    return _currentLevel.value!.coinsMultiplier;
  }

  Future<void> addExperience(int exp) async {
    try {
      if (currentUser == null) return;

      final userId = currentUser!.id!;
      final user = await _databaseService.getUser(userId.toString());
      if (user == null) return;

      final newExp = user.experience + exp;
      user.experience = newExp;
      await _databaseService.updateUser(user);
      await loadUserLevel();
    } catch (e) {
      Get.snackbar(
        '错误',
        '添加经验失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void refresh() {
    super.refresh();
    loadUserGrowth();
  }
}
