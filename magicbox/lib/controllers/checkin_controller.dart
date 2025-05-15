import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/checkin_model.dart';
import '../models/user_model.dart';

class CheckinController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel _currentUser = Get.find<UserModel>();

  final RxList<CheckinModel> checkinHistory = <CheckinModel>[].obs;
  final Rx<CheckinModel?> lastCheckin = Rx<CheckinModel?>(null);
  final RxInt consecutiveDays = 0.obs;
  final RxInt totalCheckins = 0.obs;
  final RxBool canCheckin = true.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCheckinData();
  }

  Future<void> loadCheckinData() async {
    try {
      isLoading.value = true;
      
      // 加载签到历史
      final history = await _databaseService.getCheckinHistory(_currentUser.id);
      checkinHistory.value = history;
      
      // 计算连续签到天数
      _calculateConsecutiveDays();
      
      // 检查今日是否已签到
      _checkTodayCheckin();
      
      // 获取最近一次签到记录
      if (checkinHistory.isNotEmpty) {
        lastCheckin.value = checkinHistory.first;
      }
      
      // 计算总签到天数
      totalCheckins.value = checkinHistory.length;
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载签到数据失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateConsecutiveDays() {
    if (checkinHistory.isEmpty) {
      consecutiveDays.value = 0;
      return;
    }

    int days = 1;
    DateTime lastDate = checkinHistory[0].checkinDate;
    
    for (int i = 1; i < checkinHistory.length; i++) {
      final currentDate = checkinHistory[i].checkinDate;
      final difference = lastDate.difference(currentDate).inDays;
      
      if (difference == 1) {
        days++;
        lastDate = currentDate;
      } else {
        break;
      }
    }
    
    consecutiveDays.value = days;
  }

  void _checkTodayCheckin() {
    if (checkinHistory.isEmpty) {
      canCheckin.value = true;
      return;
    }

    final lastCheckinDate = checkinHistory[0].checkinDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCheckinDay = DateTime(
      lastCheckinDate.year,
      lastCheckinDate.month,
      lastCheckinDate.day,
    );

    canCheckin.value = today.isAfter(lastCheckinDay);
  }

  Future<void> checkin() async {
    if (!canCheckin.value) return;

    try {
      isLoading.value = true;

      // 计算奖励
      final rewards = _calculateRewards();
      
      // 创建签到记录
      final checkin = CheckinModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUser.id,
        checkinDate: DateTime.now(),
        consecutiveDays: consecutiveDays.value + 1,
        pointsEarned: rewards['points']!,
        coinsEarned: rewards['coins']!,
      );

      // 保存签到记录
      await _databaseService.createCheckin(checkin);
      
      // 更新用户积分和金币
      await _databaseService.updateUserPoints(
        _currentUser.id,
        _currentUser.points + rewards['points']!,
      );
      await _databaseService.updateUserCoins(
        _currentUser.id,
        _currentUser.coins + rewards['coins']!,
      );

      // 更新本地数据
      checkinHistory.insert(0, checkin);
      lastCheckin.value = checkin;
      consecutiveDays.value++;
      totalCheckins.value++;
      canCheckin.value = false;

      // 更新当前用户数据
      _currentUser.points += rewards['points']!;
      _currentUser.coins += rewards['coins']!;

      Get.snackbar(
        '签到成功',
        '获得 ${rewards['points']}积分 ${rewards['coins']}金币',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '签到失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, int> _calculateRewards() {
    final day = (consecutiveDays.value + 1) % 7;
    if (day == 0) day = 7;

    switch (day) {
      case 1:
        return {'points': 10, 'coins': 5};
      case 2:
        return {'points': 20, 'coins': 10};
      case 3:
        return {'points': 30, 'coins': 15};
      case 4:
        return {'points': 40, 'coins': 20};
      case 5:
        return {'points': 50, 'coins': 25};
      case 6:
        return {'points': 60, 'coins': 30};
      case 7:
        return {'points': 100, 'coins': 50};
      default:
        return {'points': 10, 'coins': 5};
    }
  }
} 