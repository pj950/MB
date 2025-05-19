import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/box_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/subscription_controller.dart';
import '../models/box_model.dart';
import '../models/repository_model.dart';
import 'box_detail_page.dart';

class RepositoryDetailPage extends StatefulWidget {
  final RepositoryModel repository;

  const RepositoryDetailPage({super.key, required this.repository});

  @override
  State<RepositoryDetailPage> createState() => _RepositoryDetailPageState();
}

class _RepositoryDetailPageState extends State<RepositoryDetailPage>
    with SingleTickerProviderStateMixin {
  final BoxController boxController = Get.find<BoxController>();
  final AuthController authController = Get.find<AuthController>();
  final SubscriptionController subscriptionController = Get.find<SubscriptionController>();

  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pageAnimation = CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeOutCubic,
    );
    _pageController.forward();

    boxController.loadBoxes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = widget.repository;
    return Scaffold(
      appBar: AppBar(
        title: Text(repository.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildRepositoryInfo(),
          Expanded(
            child: _buildBoxList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => boxController.showCreateBoxDialog(repository.id),
        icon: const Icon(Icons.add),
        label: const Text('创建盒子'),
        elevation: 4,
      ),
    );
  }

  Widget _buildRepositoryInfo() {
    // Implementation of _buildRepositoryInfo method
    return Container(); // Placeholder return, actual implementation needed
  }

  Widget _buildBoxList() {
    return GestureDetector(
      onScaleUpdate: (details) {
        setState(() {
          _scale = details.scale.clamp(0.5, 2.0);
          _offset += details.focalPointDelta;
        });
      },
      child: AnimatedBuilder(
        animation: _pageAnimation,
        builder: (context, child) {
          return Obx(() {
            if (boxController.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final boxes = boxController.boxes
                .where((box) => box.repositoryId == widget.repository.id)
                .toList();
            if (boxes.isEmpty) {
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
                      '还没有盒子',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '点击下方按钮创建盒子',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => boxController.showCreateBoxDialog(widget.repository.id),
                      icon: const Icon(Icons.add),
                      label: const Text('创建盒子'),
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
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: boxes.length,
              itemBuilder: (context, index) {
                final box = boxes[index];
                return _BoxCard(
                  box: box,
                  onTap: () => Get.to(() => BoxDetailPage(box: box)),
                );
              },
            );
          });
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: widget.repository.name);
    final descriptionController =
        TextEditingController(text: widget.repository.description ?? '');
    bool isPublic = widget.repository.isPublic;

    Get.dialog(
      AlertDialog(
        title: const Text('编辑仓库'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '仓库名称',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述（选填）',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('公开仓库'),
                value: isPublic,
                onChanged: (value) {
                  setState(() => isPublic = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                Get.snackbar('错误', '请输入仓库名称');
                return;
              }
              // TODO: 实现仓库更新逻辑
              Get.back();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('删除仓库'),
        content: const Text('确定要删除这个仓库吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: 实现仓库删除逻辑
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<BoxModel?> getBox(String id) async {
    try {
      return await boxController.getBox(id);
    } catch (e) {
      Get.snackbar('错误', '获取盒子失败：$e');
      return null;
    }
  }
}

class _BoxCard extends StatefulWidget {
  final BoxModel box;
  final VoidCallback onTap;

  const _BoxCard({
    required this.box,
    required this.onTap,
  });

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
    _animation = Tween<double>(begin: 0, end: 0.2).animate(
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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(_animation.value)
                ..rotateY(_animation.value)
                ..translate(0.0, -_animation.value * 20),
              alignment: Alignment.center,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(_isHovered ? 102 : 51),
                      blurRadius: _isHovered ? 15 : 10,
                      offset: Offset(0, _isHovered ? 8 : 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withAlpha(_isHovered ? 204 : 128),
                    width: _isHovered ? 2 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // 背景
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(int.parse(widget.box.themeColor
                                        .replaceAll('#', '0xFF')))
                                    .withAlpha(51),
                                Colors.white,
                              ],
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
                                Icons.inbox,
                                color: Color(int.parse(widget.box.themeColor
                                    .replaceAll('#', '0xFF'))),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.box.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.box.hasExpiredItems)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.box.description ?? '暂无描述',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
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
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
