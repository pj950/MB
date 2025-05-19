import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/box_controller.dart';
import '../controllers/auth_controller.dart';
import '../pages/box_detail_page.dart';
import '../models/box_model.dart';
import 'profile_page.dart';
import 'statistics_page.dart';
import 'help_page.dart';
import 'settings_page.dart';
import 'subscription_page.dart';
import '../controllers/repository_controller.dart';
import '../controllers/subscription_controller.dart';
import 'create_box_page.dart';
import 'community_page.dart';
import 'repository_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final BoxController boxController = Get.find<BoxController>();
    final RepositoryController repositoryController = Get.find<RepositoryController>();
    final AuthController authController = Get.find<AuthController>();
    final SubscriptionController subscriptionController = Get.find<SubscriptionController>();
    final selectedRepository = repositoryController.repositories.isNotEmpty 
        ? repositoryController.repositories.first 
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('魔盒'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.card_membership),
            tooltip: '订阅管理',
            onPressed: () => Get.to(() => SubscriptionPage()),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: '数据统计',
            onPressed: () => Get.to(() => StatisticsPage()),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: '帮助中心',
            onPressed: () => Get.to(() => HelpPage()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '设置',
            onPressed: () => Get.to(() => SettingsPage()),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: '个人中心',
            onPressed: () {
              final user = authController.currentUser;
              if (user == null) {
                Get.snackbar('提示', '请先登录');
                return;
              }
              Get.to(() => ProfilePage(user: user));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSubscriptionCard(),
            _buildRepositoryList(),
            _buildBoxList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => repositoryController.showCreateRepositoryDialog(),
        icon: const Icon(Icons.add),
        label: const Text('创建仓库'),
        elevation: 4,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // 已经在主页，不需要操作
              break;
            case 1:
              Get.toNamed('/community');
              break;
            case 2:
              Get.toNamed('/statistics');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: '社区',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '统计',
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '订阅信息',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => SubscriptionPage()),
                  child: const Text('查看详情'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              final subscription = Get.find<SubscriptionController>().currentSubscription;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('类型：${subscription?.type.toString().split('.').last ?? '免费版'}'),
                  Text('到期时间：${subscription?.endDate.toString().split(' ')[0] ?? '永久'}'),
                  Text('仓库数量：${subscription?.maxRepositories ?? 3}'),
                  Text('盒子数量：${subscription?.maxBoxesPerRepository ?? 10}'),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRepositoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '我的仓库',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Obx(() {
          final repositories = Get.find<RepositoryController>().repositories;
          if (repositories.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无仓库'),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: repositories.length,
            itemBuilder: (context, index) {
              final repository = repositories[index];
              return ListTile(
                title: Text(repository.name),
                subtitle: Text(repository.description ?? ''),
                trailing: Text('${repository.boxCount} 个盒子'),
                onTap: () => Get.to(() => RepositoryDetailPage(repository: repository)),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildBoxList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            '最近盒子',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Obx(() {
          final boxes = Get.find<BoxController>().boxes;
          if (boxes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无盒子'),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: boxes.length,
            itemBuilder: (context, index) {
              final box = boxes[index];
              return ListTile(
                title: Text(box.name),
                subtitle: Text(box.description ?? ''),
                trailing: Text('${box.itemCount} 个物品'),
                onTap: () => Get.to(() => BoxDetailPage(box: box)),
              );
            },
          );
        }),
      ],
    );
  }
}

class _BoxCard extends StatefulWidget {
  final BoxModel box;

  const _BoxCard({required this.box});

  @override
  State<_BoxCard> createState() => _BoxCardState();
}

class _BoxCardState extends State<_BoxCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 0.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(_animation.value)
              ..rotateY(_animation.value),
            alignment: Alignment.center,
            child: Card(
              elevation: _isHovered ? 8 : 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: () => Get.to(() => BoxDetailPage(box: widget.box)),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(int.parse(
                            widget.box.themeColor.replaceAll('#', '0xFF'))),
                        Color(int.parse(
                                widget.box.themeColor.replaceAll('#', '0xFF')))
                            .withValues(alpha: 0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // 3D效果背景
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateX(_animation.value * 0.5)
                              ..rotateY(_animation.value * 0.5),
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withValues(alpha: 0.1),
                                    Colors.white.withValues(alpha: 0.05),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 内容
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getBoxTypeIcon(widget.box.type),
                                  color: Colors.white,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.box.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.box.description ?? '',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.box.itemCount} 个物品',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  widget.box.updatedAt.toString().split('.')[0],
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getBoxTypeIcon(BoxType type) {
    switch (type) {
      case BoxType.COLLECTION:
        return Icons.collections;
      case BoxType.CUSTOM:
        return Icons.category;
      default:
        return Icons.folder;
    }
  }
}
