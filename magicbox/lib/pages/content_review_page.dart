import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/content_review_controller.dart';
import '../models/content_report_model.dart';
import '../models/content_review_model.dart';

class ContentReviewPage extends StatelessWidget {
  final ContentReviewController _controller = Get.put(ContentReviewController());

  ContentReviewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('内容审核'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '待审核'),
              Tab(text: '已审核'),
              Tab(text: '已驳回'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildReportList('pending'),
            _buildReportList('reviewed'),
            _buildReportList('dismissed'),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList(String status) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final reports = _controller.reports
          .where((r) => r.status == status)
          .toList();

      if (reports.isEmpty) {
        return Center(
          child: Text(status == 'pending' ? '暂无待审核内容' : '暂无已审核内容'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return _buildReportCard(report);
        },
      );
    });
  }

  Widget _buildReportCard(ContentReportModel report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showReportDetails(report),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${report.targetType == 'post' ? '帖子' : '评论'} #${report.targetId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(report.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.reason,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '举报时间：${_formatDate(report.createdAt)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (report.reviewResult != null)
                    Text(
                      '审核结果：${_getReviewResultText(report.reviewResult!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getReviewResultColor(report.reviewResult!),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetails(ContentReportModel report) async {
    await _controller.loadReportDetails(report.id!);
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${report.targetType == 'post' ? '帖子' : '评论'} #${report.targetId}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '举报原因：',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                report.reason,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              if (report.reviewNote != null) ...[
                Text(
                  '审核备注：',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  report.reviewNote!,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
              ],
              if (report.status == 'pending' && _controller.isModerator())
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        _showDismissDialog(report.id!);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey,
                      ),
                      child: const Text('驳回'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        _showRejectDialog(report.id!);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('拒绝'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _controller.reviewReport(
                          reportId: report.id!,
                          action: 'approve',
                        );
                      },
                      child: const Text('通过'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRejectDialog(int reportId) {
    final noteController = TextEditingController();

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('拒绝举报'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: '拒绝原因',
            hintText: '请输入拒绝原因',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.isEmpty) {
                Get.snackbar(
                  '错误',
                  '请输入拒绝原因',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back();
              _controller.reviewReport(
                reportId: reportId,
                action: 'reject',
                note: noteController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('确认拒绝'),
          ),
        ],
      ),
    );
  }

  void _showDismissDialog(int reportId) {
    final noteController = TextEditingController();

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('驳回举报'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            labelText: '驳回原因',
            hintText: '请输入驳回原因',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (noteController.text.isEmpty) {
                Get.snackbar(
                  '错误',
                  '请输入驳回原因',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back();
              _controller.reviewReport(
                reportId: reportId,
                action: 'dismiss',
                note: noteController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: const Text('确认驳回'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = '待审核';
        break;
      case 'reviewed':
        color = Colors.green;
        text = '已审核';
        break;
      case 'dismissed':
        color = Colors.grey;
        text = '已驳回';
        break;
      default:
        color = Colors.grey;
        text = '未知';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getReviewResultText(String result) {
    switch (result) {
      case 'approved':
        return '已通过';
      case 'rejected':
        return '已拒绝';
      default:
        return '未知';
    }
  }

  Color _getReviewResultColor(String result) {
    switch (result) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
} 