import 'package:get/get.dart';
import '../models/settings_model.dart';

class SettingsController extends GetxController {
  final Rx<UserSettings> settings = UserSettings.defaultSettings().obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      isLoading.value = true;
      settings.value = await UserSettings.load();
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载设置失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSettings(UserSettings newSettings) async {
    try {
      isLoading.value = true;
      await newSettings.save();
      settings.value = newSettings;
      Get.snackbar(
        '成功',
        '设置已更新',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '更新设置失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetSettings() async {
    try {
      isLoading.value = true;
      final defaultSettings = UserSettings.defaultSettings();
      await defaultSettings.save();
      settings.value = defaultSettings;
      Get.snackbar(
        '成功',
        '设置已重置为默认值',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '重置设置失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void toggleDarkMode() {
    final newSettings = settings.value.copyWith(
      darkMode: !settings.value.darkMode,
    );
    updateSettings(newSettings);
  }

  void toggleNotifications() {
    final newSettings = settings.value.copyWith(
      notificationsEnabled: !settings.value.notificationsEnabled,
    );
    updateSettings(newSettings);
  }

  void toggleAutoPlayVideos() {
    final newSettings = settings.value.copyWith(
      autoPlayVideos: !settings.value.autoPlayVideos,
    );
    updateSettings(newSettings);
  }

  void setLanguage(String language) {
    final newSettings = settings.value.copyWith(
      language: language,
    );
    updateSettings(newSettings);
  }

  void setFontSize(String fontSize) {
    final newSettings = settings.value.copyWith(
      fontSize: fontSize,
    );
    updateSettings(newSettings);
  }

  void toggleDataSaver() {
    final newSettings = settings.value.copyWith(
      dataSaver: !settings.value.dataSaver,
    );
    updateSettings(newSettings);
  }

  void toggleLocation() {
    final newSettings = settings.value.copyWith(
      locationEnabled: !settings.value.locationEnabled,
    );
    updateSettings(newSettings);
  }

  void toggleSound() {
    final newSettings = settings.value.copyWith(
      soundEnabled: !settings.value.soundEnabled,
    );
    updateSettings(newSettings);
  }

  void toggleVibration() {
    final newSettings = settings.value.copyWith(
      vibrationEnabled: !settings.value.vibrationEnabled,
    );
    updateSettings(newSettings);
  }
} 