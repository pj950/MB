import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/item_controller.dart';
import '../controllers/speech_controller.dart';
import '../models/box_model.dart';
import '../models/item_model.dart';
import '../controllers/box_controller.dart';
import '../widgets/box_header.dart';
import '../widgets/item_grid.dart';
import '../widgets/add_item_button.dart';
import '../widgets/box_settings_dialog.dart';
import '../widgets/expiry_warning_dialog.dart';
import '../widgets/draggable_item.dart';

class BoxDetailPage extends StatefulWidget {
  final BoxModel box;

  const BoxDetailPage({super.key, required this.box});

  @override
  State<BoxDetailPage> createState() => _BoxDetailPageState();
}

class _BoxDetailPageState extends State<BoxDetailPage> with SingleTickerProviderStateMixin {
  final BoxController boxController = Get.find<BoxController>();
  final ItemController itemController = Get.find<ItemController>();
  final SpeechController speechController = Get.put(SpeechController());

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    speechController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.box.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _scale = details.scale.clamp(0.5, 2.0);
            _offset += details.focalPointDelta;
          });
        },
        child: AnimatedBuilder(
          animation: _pageAnimation,
          builder: (context, child) {
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..scale(_scale)
                ..translate(_offset.dx, _offset.dy)
                ..rotateX(_pageAnimation.value * 0.1)
                ..rotateY(_pageAnimation.value * 0.1),
              alignment: Alignment.center,
              child: Column(
                children: [
                  BoxHeader(
                    box: widget.box,
                    onEdit: () => _showSettingsDialog(context),
                  ),
                  if (widget.box.hasExpiredItems)
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red.withAlpha(50),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text('有物品已过期'),
                          const Spacer(),
                          TextButton(
                            onPressed: () => _showExpiryWarningDialog(context),
                            child: const Text('查看详情'),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: FutureBuilder<List<ItemModel>>(
                      future: itemController.getItemsByBox(widget.box.id),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('加载失败：${snapshot.error}'),
                          );
                        }

                        final items = snapshot.data ?? [];
                        if (items.isEmpty) {
                          return const Center(
                            child: Text('暂无物品'),
                          );
                        }

                        return ItemGrid(
                          items: items,
                          onItemTap: (item) => _onItemTap(context, item),
                          onItemLongPress: (item) => _onItemLongPress(context, item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: AddItemButton(
        onPressed: () => itemController.showCreateItemDialog(widget.box.id),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BoxSettingsDialog(
        box: widget.box,
        onSave: (updatedBox) {
          boxController.updateBox(updatedBox);
        },
      ),
    );
  }

  void _showExpiryWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<List<ItemModel>>(
        future: itemController.getItemsByBox(widget.box.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final expiredItems = snapshot.data!
              .where((item) =>
                  item.expiryDate != null &&
                  item.expiryDate!.isBefore(DateTime.now()))
              .toList();

          return ExpiryWarningDialog(
            items: expiredItems,
            onDismiss: () => Navigator.pop(context),
          );
        },
      ),
    );
  }

  void _onItemTap(BuildContext context, ItemModel item) {
    // TODO: 实现物品详情页面
  }

  void _onItemLongPress(BuildContext context, ItemModel item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('编辑'),
            onTap: () {
              Navigator.pop(context);
              // TODO: 实现编辑功能
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('删除', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context, item);
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除 ${item.name} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              itemController.deleteItem(item.id);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<ItemModel?> getItem(String id) async {
    try {
      return await itemController.getItem(id);
    } catch (e) {
      Get.snackbar('错误', '获取物品失败：$e');
      return null;
    }
  }
}
