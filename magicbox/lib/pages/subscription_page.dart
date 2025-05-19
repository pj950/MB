import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/subscription_controller.dart';
import '../models/subscription_model.dart';

class SubscriptionPage extends StatelessWidget {
  final SubscriptionController _controller = Get.find<SubscriptionController>();

  SubscriptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅管理'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final subscription = _controller.subscription;
        if (subscription == null) {
          return const Center(child: Text('未找到订阅信息'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentSubscriptionCard(subscription),
              const SizedBox(height: 24),
              const Text(
                '升级选项',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSubscriptionOptions(subscription),
              if (subscription.type == SubscriptionType.FAMILY) ...[
                const SizedBox(height: 24),
                _buildFamilyMembersSection(subscription),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCurrentSubscriptionCard(SubscriptionModel subscription) {
    final benefits = _controller.getSubscriptionBenefits(subscription.type);
    final remainingDays = subscription.getRemainingDays();

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
                  _controller.getSubscriptionTypeName(subscription.type),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (remainingDays > 0)
                  Text(
                    '剩余 $remainingDays 天',
                    style: TextStyle(
                      color: remainingDays < 7 ? Colors.red : Colors.green,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBenefitItem('仓库数量', '${benefits['maxRepositories']} 个'),
            _buildBenefitItem(
                '每个仓库盒子数',
                benefits['maxBoxesPerRepository'] == -1
                    ? '无限制'
                    : '${benefits['maxBoxesPerRepository']} 个'),
            _buildBenefitItem(
                '高级属性', benefits['hasAdvancedProperties'] ? '支持' : '不支持'),
            _buildBenefitItem(
                '水印保护', benefits['hasWatermarkProtection'] ? '支持' : '不支持'),
            if (benefits['maxFamilyMembers'] > 0)
              _buildBenefitItem('家庭成员', '最多 ${benefits['maxFamilyMembers']} 人'),
            const SizedBox(height: 16),
            if (subscription.isExpired())
              ElevatedButton(
                onPressed: _controller.renewSubscription,
                child: const Text('续订订阅'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOptions(SubscriptionModel currentSubscription) {
    return Column(
      children: SubscriptionType.values.map((type) {
        if (type == currentSubscription.type) return const SizedBox.shrink();

        final benefits = _controller.getSubscriptionBenefits(type);
        final price = _controller.getSubscriptionPrice(type);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _controller.getSubscriptionTypeName(type),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '¥$price/月',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildBenefitItem('仓库数量', '${benefits['maxRepositories']} 个'),
                _buildBenefitItem(
                    '每个仓库盒子数',
                    benefits['maxBoxesPerRepository'] == -1
                        ? '无限制'
                        : '${benefits['maxBoxesPerRepository']} 个'),
                _buildBenefitItem(
                    '高级属性', benefits['hasAdvancedProperties'] ? '支持' : '不支持'),
                _buildBenefitItem(
                    '水印保护', benefits['hasWatermarkProtection'] ? '支持' : '不支持'),
                if (benefits['maxFamilyMembers'] > 0)
                  _buildBenefitItem(
                      '家庭成员', '最多 ${benefits['maxFamilyMembers']} 人'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _controller.upgradeSubscription(type),
                    child: const Text('升级到此版本'),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFamilyMembersSection(SubscriptionModel subscription) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '家庭成员',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subscription.canAddFamilyMember())
              TextButton.icon(
                onPressed: () => _showAddFamilyMemberDialog(),
                icon: const Icon(Icons.add),
                label: const Text('添加成员'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (subscription.familyMemberIds?.isEmpty ?? true)
          const Center(
            child: Text('暂无家庭成员'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: subscription.familyMemberIds?.length ?? 0,
            itemBuilder: (context, index) {
              final memberId = subscription.familyMemberIds?[index];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: Text('成员 ${index + 1}'),
                subtitle: Text(memberId ?? '未知成员'),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _controller.removeFamilyMember(memberId ?? ''),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showAddFamilyMemberDialog() {
    final TextEditingController controller = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('添加家庭成员'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '成员ID',
            hintText: '请输入成员的用户ID',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _controller.addFamilyMember(controller.text);
                Get.back();
              }
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}
