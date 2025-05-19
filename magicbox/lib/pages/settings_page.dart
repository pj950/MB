import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final SettingsController controller = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children: [
            _buildSection(
              title: '外观',
              children: [
                _buildSwitchTile(
                  title: '深色模式',
                  value: controller.settings.value.darkMode,
                  onChanged: (value) => controller.toggleDarkMode(),
                ),
                _buildDropdownTile(
                  title: '字体大小',
                  value: controller.settings.value.fontSize,
                  items: const [
                    DropdownMenuItem(value: 'small', child: Text('小')),
                    DropdownMenuItem(value: 'medium', child: Text('中')),
                    DropdownMenuItem(value: 'large', child: Text('大')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.setFontSize(value);
                    }
                  },
                ),
              ],
            ),
            _buildSection(
              title: '通知',
              children: [
                _buildSwitchTile(
                  title: '启用通知',
                  value: controller.settings.value.notificationsEnabled,
                  onChanged: (value) => controller.toggleNotifications(),
                ),
                _buildSwitchTile(
                  title: '声音',
                  value: controller.settings.value.soundEnabled,
                  onChanged: (value) => controller.toggleSound(),
                ),
                _buildSwitchTile(
                  title: '震动',
                  value: controller.settings.value.vibrationEnabled,
                  onChanged: (value) => controller.toggleVibration(),
                ),
              ],
            ),
            _buildSection(
              title: '内容',
              children: [
                _buildSwitchTile(
                  title: '自动播放视频',
                  value: controller.settings.value.autoPlayVideos,
                  onChanged: (value) => controller.toggleAutoPlayVideos(),
                ),
                _buildSwitchTile(
                  title: '省流量模式',
                  value: controller.settings.value.dataSaver,
                  onChanged: (value) => controller.toggleDataSaver(),
                ),
              ],
            ),
            _buildSection(
              title: '其他',
              children: [
                _buildDropdownTile(
                  title: '语言',
                  value: controller.settings.value.language,
                  items: const [
                    DropdownMenuItem(value: 'zh_CN', child: Text('简体中文')),
                    DropdownMenuItem(value: 'en_US', child: Text('English')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.setLanguage(value);
                    }
                  },
                ),
                _buildSwitchTile(
                  title: '位置服务',
                  value: controller.settings.value.locationEnabled,
                  onChanged: (value) => controller.toggleLocation(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: controller.resetSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('恢复默认设置'),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}
