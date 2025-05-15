import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/checkin_controller.dart';
import '../models/checkin_model.dart';

class CheckinPage extends StatelessWidget {
  final CheckinController _controller = Get.put(CheckinController());

  CheckinPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('每日签到'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckinCard(),
              const SizedBox(height: 24),
              _buildRewardRules(),
              const SizedBox(height: 24),
              _buildCheckinHistory(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCheckinCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '连续签到：${_controller.consecutiveDays.value}天',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '累计签到：${_controller.totalCheckins.value}天',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: _controller.canCheckin.value
                      ? () => _controller.checkin()
                      : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    _controller.canCheckin.value ? '立即签到' : '今日已签到',
                  ),
                ),
              ],
            ),
            if (_controller.lastCheckin.value != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRewardItem(
                    '积分',
                    _controller.lastCheckin.value!.pointsEarned.toString(),
                    Icons.star,
                    Colors.amber,
                  ),
                  _buildRewardItem(
                    '金币',
                    _controller.lastCheckin.value!.coinsEarned.toString(),
                    Icons.monetization_on,
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardRules() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '签到规则',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildRuleItem('第1天', '10积分 + 5金币'),
            _buildRuleItem('第2天', '20积分 + 10金币'),
            _buildRuleItem('第3天', '30积分 + 15金币'),
            _buildRuleItem('第4天', '40积分 + 20金币'),
            _buildRuleItem('第5天', '50积分 + 25金币'),
            _buildRuleItem('第6天', '60积分 + 30金币'),
            _buildRuleItem('第7天', '100积分 + 50金币'),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(String day, String reward) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              day,
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            reward,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckinHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '签到记录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_controller.checkinHistory.isEmpty)
              const Center(
                child: Text(
                  '暂无签到记录',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _controller.checkinHistory.length,
                itemBuilder: (context, index) {
                  final checkin = _controller.checkinHistory[index];
                  return _buildHistoryItem(checkin);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(CheckinModel checkin) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                checkin.consecutiveDays.toString(),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(checkin.checkinDate),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '获得 ${checkin.pointsEarned}积分 ${checkin.coinsEarned}金币',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 