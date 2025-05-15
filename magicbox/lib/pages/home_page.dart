import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:get/get.dart';

import '../controllers/box_controller.dart';
import '../pages/box_detail_page.dart';
import '../pages/create_box_page.dart';
import '../utils/theme_helper.dart';
import '../widgets/star_background.dart';
import '../controllers/auth_controller.dart';
import '../controllers/subscription_controller.dart';
import 'profile_page.dart';
import 'statistics_page.dart';
import 'help_page.dart';
import 'settings_page.dart';
import 'subscription_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final BoxController boxController = Get.find<BoxController>();
    final AuthController authController = Get.find<AuthController>();
    final SubscriptionController subscriptionController = Get.find<SubscriptionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的仓库'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.card_membership),
            tooltip: '订阅管理',
            onPressed: () => Get.to(() => const SubscriptionPage()),
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
            onPressed: () => Get.to(() => const ProfilePage()),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Obx(() {
          if (boxController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (boxController.boxes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '还没有仓库',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击下方按钮创建您的第一个仓库',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => boxController.showCreateBoxDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('创建仓库'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: boxController.boxes.length,
            itemBuilder: (context, index) {
              final box = boxController.boxes[index];
              return Hero(
                tag: 'box_${box.id}',
                child: _BoxCard(box: box),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => boxController.showCreateBoxDialog(),
        icon: const Icon(Icons.add),
        label: const Text('创建仓库'),
        elevation: 4,
      ),
    );
  }
}

class _BoxCard extends StatefulWidget {
  final BoxModel box;

  const _BoxCard({required this.box});

  @override
  State<_BoxCard> createState() => _BoxCardState();
}

class _BoxCardState extends State<_BoxCard> with SingleTickerProviderStateMixin {
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
                        Color(int.parse(widget.box.themeColor.replaceAll('#', '0xFF'))),
                        Color(int.parse(widget.box.themeColor.replaceAll('#', '0xFF'))).withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
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
                                    Colors.white.withOpacity(0.1),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 内容
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getBoxIcon(widget.box.type),
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.box.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.box.itemCount} 个物品',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
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

  IconData _getBoxIcon(BoxType type) {
    switch (type) {
      case BoxType.WARDROBE:
        return Icons.checkroom;
      case BoxType.BOOKSHELF:
        return Icons.book;
      case BoxType.COLLECTION:
        return Icons.collections;
      case BoxType.CUSTOM:
        return Icons.category;
    }
  }
}
