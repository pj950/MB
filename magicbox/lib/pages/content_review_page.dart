import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/content_report_model.dart' as report;
import '../controllers/content_review_controller.dart';

class ContentReviewPage extends StatelessWidget {
  final ContentReviewController controller = Get.find<ContentReviewController>();

  ContentReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('内容审核'),
          bottom: TabBar(
            tabs: const [
              Tab(text: '待审核'),
              Tab(text: '已通过'),
              Tab(text: '已拒绝'),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  controller.loadReports(status: 'pending');
                  break;
                case 1:
                  controller.loadReports(status: 'reviewed');
                  break;
                case 2:
                  controller.loadReports(status: 'dismissed');
                  break;
              }
            },
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.reports.isEmpty) {
            return const Center(
              child: Text('暂无内容需要审核'),
            );
          }

          return ListView.builder(
            itemCount: controller.reports.length,
            itemBuilder: (context, index) {
              final report = controller.reports[index];
              return _buildReportCard(context, report);
            },
          );
        }),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, report.ContentReportModel report) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('${report.targetType} #${report.targetId}'),
            subtitle: Text('举报人：${report.reporterId}'),
            trailing: _buildStatusChip(report.status),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(report.description),
          ),
          if (report.evidenceUrls?.isNotEmpty ?? false)
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: report.evidenceUrls!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.network(
                      report.evidenceUrls![index],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          OverflowBar(
            spacing: 8,
            alignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showRejectDialog(context, report),
                child: const Text('拒绝'),
              ),
              ElevatedButton(
                onPressed: () => controller.reviewReport(
                  reportId: int.parse(report.id),
                  action: 'approve',
                ),
                child: const Text('通过'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(report.ReportStatus status) {
    Color color;
    String text;

    switch (status) {
      case report.ReportStatus.PENDING:
        color = Colors.orange;
        text = '待审核';
        break;
      case report.ReportStatus.REVIEWING:
        color = Colors.blue;
        text = '审核中';
        break;
      case report.ReportStatus.RESOLVED:
        color = Colors.green;
        text = '已解决';
        break;
      case report.ReportStatus.REJECTED:
        color = Colors.red;
        text = '已拒绝';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  void _showRejectDialog(BuildContext context, report.ContentReportModel report) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拒绝原因'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: '请输入拒绝原因',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isEmpty) {
                Get.snackbar('错误', '请输入拒绝原因');
                return;
              }
              controller.reviewReport(
                reportId: int.parse(report.id),
                action: 'reject',
                note: reasonController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }
} 