import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/statistics_controller.dart';
import '../models/statistics_model.dart';

class StatisticsPage extends StatelessWidget {
  final StatisticsController controller = Get.put(StatisticsController());

  StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据统计'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadStatistics,
            tooltip: '刷新数据',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserStatistics(),
              const SizedBox(height: 24),
              _buildContentStatistics(),
              const SizedBox(height: 24),
              _buildInteractionStatistics(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildUserStatistics() {
    final stats = controller.userStatistics.value;
    if (stats == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '用户统计',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow([
              _buildStatItem('总用户数', stats.totalUsers.toString()),
              _buildStatItem('活跃用户', stats.activeUsers.toString()),
              _buildStatItem('今日新增', stats.newUsersToday.toString()),
            ]),
            const SizedBox(height: 16),
            _buildStatRow([
              _buildStatItem('本周新增', stats.newUsersThisWeek.toString()),
              _buildStatItem('本月新增', stats.newUsersThisMonth.toString()),
            ]),
            const SizedBox(height: 24),
            _buildDistributionChart(
              '用户等级分布',
              stats.userLevelDistribution,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildDistributionChart(
              '用户类型分布',
              stats.userTypeDistribution,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentStatistics() {
    final stats = controller.contentStatistics.value;
    if (stats == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '内容统计',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow([
              _buildStatItem('总帖子数', stats.totalPosts.toString()),
              _buildStatItem('总评论数', stats.totalComments.toString()),
              _buildStatItem('今日新增帖子', stats.newPostsToday.toString()),
            ]),
            const SizedBox(height: 16),
            _buildStatRow([
              _buildStatItem('总频道数', stats.totalChannels.toString()),
              _buildStatItem('总盒子数', stats.totalBoxes.toString()),
              _buildStatItem('总物品数', stats.totalItems.toString()),
            ]),
            const SizedBox(height: 24),
            _buildDistributionChart(
              '帖子类型分布',
              stats.postTypeDistribution,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildDistributionChart(
              '频道分类分布',
              stats.channelCategoryDistribution,
              Colors.purple,
            ),
            const SizedBox(height: 16),
            _buildDistributionChart(
              '盒子类型分布',
              stats.boxTypeDistribution,
              Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionStatistics() {
    final stats = controller.interactionStatistics.value;
    if (stats == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '互动统计',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow([
              _buildStatItem('总点赞数', stats.totalLikes.toString()),
              _buildStatItem('总关注数', stats.totalFollows.toString()),
              _buildStatItem('今日新增点赞', stats.newLikesToday.toString()),
            ]),
            const SizedBox(height: 16),
            _buildStatRow([
              _buildStatItem('总举报数', stats.totalReports.toString()),
              _buildStatItem('总审核数', stats.totalReviews.toString()),
              _buildStatItem('今日新增举报', stats.newReportsToday.toString()),
            ]),
            const SizedBox(height: 24),
            _buildDistributionChart(
              '举报类型分布',
              stats.reportTypeDistribution,
              Colors.red,
            ),
            const SizedBox(height: 16),
            _buildDistributionChart(
              '审核操作分布',
              stats.reviewActionDistribution,
              Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: children,
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDistributionChart(String title, Map<String, int> distribution, Color color) {
    final total = distribution.values.fold<int>(0, (sum, count) => sum + count);
    final items = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: items.map((entry) {
                final percentage = (entry.value / total * 100).toStringAsFixed(1);
                return PieChartSectionData(
                  value: entry.value.toDouble(),
                  title: '$percentage%',
                  color: color.withOpacity(0.7),
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: items.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: color.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text('${entry.key}: ${entry.value}'),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
} 