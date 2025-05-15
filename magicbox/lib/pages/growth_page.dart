import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/growth_controller.dart';
import '../models/checkin_model.dart';
import '../models/level_model.dart';

class GrowthPage extends StatelessWidget {
  final GrowthController _controller = Get.put(GrowthController());

  GrowthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成长系统'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.loadUserGrowth(),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLevelCard(),
              const SizedBox(height: 16),
              _buildCheckinCard(),
              const SizedBox(height: 16),
              _buildPrivilegesCard(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLevelCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _controller.currentLevel.value.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Lv.${_controller.currentLevel.value.level}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _controller.getLevelProgress(),
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            if (_controller.nextLevel.value != null)
              Text(
                '距离下一级还需${_controller.getExperienceToNextLevel()}经验',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  '积分倍率',
                  '${_controller.getPointsMultiplier()}x',
                  Icons.star,
                ),
                _buildStatItem(
                  '金币倍率',
                  '${_controller.getCoinsMultiplier()}x',
                  Icons.monetization_on,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckinCard() {
    final lastCheckin = _controller.lastCheckin.value;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final canCheckin = lastCheckin == null ||
        !DateTime(
          lastCheckin.checkinDate.year,
          lastCheckin.checkinDate.month,
          lastCheckin.checkinDate.day,
        ).isAtSameMomentAs(today);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '每日签到',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (lastCheckin != null) ...[
              Text(
                '连续签到：${lastCheckin.consecutiveDays}天',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '上次签到：${_formatDate(lastCheckin.checkinDate)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canCheckin ? _controller.checkin : null,
                child: Text(canCheckin ? '签到' : '今日已签到'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivilegesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前特权',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._controller.currentLevel.value.privileges.map((privilege) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(privilege),
                  ],
                ),
              );
            }),
            if (_controller.nextLevel.value != null) ...[
              const SizedBox(height: 16),
              const Text(
                '下一级特权',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ..._controller.nextLevel.value!.privileges
                  .where((privilege) =>
                      !_controller.currentLevel.value.privileges.contains(privilege))
                  .map((privilege) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        privilege,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 