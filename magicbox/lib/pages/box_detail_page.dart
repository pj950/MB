import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/item_controller.dart';
import '../controllers/speech_controller.dart';
import '../models/box_model.dart';
import '../models/item_model.dart';
import '../services/db_service.dart';
import '../utils/image_picker_helper.dart';
import '../widgets/draggable_item.dart';
import '../widgets/image_preview_3d.dart';
import '../controllers/box_controller.dart';
import 'item_detail_page.dart';

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
  double _spaceScale = 1.0;
  Offset _spaceOffset = Offset.zero;
  
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
    
    itemController.loadItems(widget.box.id!);
    _checkExpiredItems();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkExpiredItems() async {
    final items = await DBService.getItemsByBoxId(widget.box.id!);
    final hasExpired = items.any((item) => _isItemExpired(item));
    
    if (hasExpired != widget.box.hasExpiredItems) {
      final updatedBox = widget.box.copyWith(hasExpiredItems: hasExpired);
      await DBService.updateBox(updatedBox);
    }
  }

  bool _isItemExpired(ItemModel item) {
    if (item.expiryDate == null || item.expiryDate!.isEmpty) {
      return false;
    }
    try {
      final expiryDate = DateTime.parse(item.expiryDate!);
      return expiryDate.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  String? _getExpiryText(ItemModel item) {
    if (item.expiryDate == null || item.expiryDate!.isEmpty) {
      return null;
    }
    try {
      final expiryDate = DateTime.parse(item.expiryDate!);
      final now = DateTime.now();
      if (expiryDate.isBefore(now)) {
        return '已过期';
      }
      final difference = expiryDate.difference(now);
      if (difference.inDays > 0) {
        return '${difference.inDays}天后过期';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}小时后过期';
      } else {
        return '即将过期';
      }
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.box.name),
            if (widget.box.hasExpiredItems)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red.shade400,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.mic),
            onPressed: () {
              speechController.startListening();
              speechController.text.listen((value) {
                itemController.searchItems(value);
              });
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => itemController.showCreateItemDialog(widget.box.id!),
      ),
      body: GestureDetector(
        onScaleUpdate: (details) {
          setState(() {
            _spaceScale = details.scale.clamp(0.5, 2.0);
            _spaceOffset += details.focalPointDelta;
          });
        },
        child: AnimatedBuilder(
          animation: _pageAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(int.parse(widget.box.themeColor.replaceAll('#', '0xFF'))).withOpacity(0.2),
                    Colors.white,
                  ],
                ),
              ),
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..scale(_spaceScale)
                  ..translate(_spaceOffset.dx, _spaceOffset.dy)
                  ..rotateX(_pageAnimation.value * 0.1)
                  ..rotateY(_pageAnimation.value * 0.1),
                alignment: Alignment.center,
                child: Obx(() {
                  if (itemController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = itemController.getItemsByBox(widget.box.id!);
                  if (items.isEmpty) {
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
                            '还没有物品',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '点击下方按钮添加物品',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => itemController.showCreateItemDialog(widget.box.id!),
                            icon: const Icon(Icons.add),
                            label: const Text('添加物品'),
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

                  return Stack(
                    children: items.map((item) {
                      return _DraggableItem(
                        key: ValueKey(item.id),
                        item: item,
                        initialPosition: Offset(item.posX ?? 50.0, item.posY ?? 100.0),
                        initialScale: item.scale ?? 1.0,
                        onPositionChanged: (offset) {
                          item.posX = offset.dx;
                          item.posY = offset.dy;
                          itemController.updateItem(item);
                        },
                        onScaleChanged: (scale) {
                          item.scale = scale;
                          itemController.updateItem(item);
                        },
                        isExpired: _isItemExpired(item),
                        expiryText: _getExpiryText(item),
                      );
                    }).toList(),
                  );
                }),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: widget.box.name);
    final descriptionController = TextEditingController(text: widget.box.description);
    BoxType selectedType = widget.box.type;
    bool isPublic = widget.box.isPublic;

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
              DropdownButtonFormField<BoxType>(
                value: selectedType,
                items: BoxType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedType = value);
                  }
                },
                decoration: const InputDecoration(
                  labelText: '仓库类型',
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
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                Get.snackbar('错误', '请输入仓库名称');
                return;
              }
              final updatedBox = widget.box.copyWith(
                name: nameController.text,
                type: selectedType,
                description: descriptionController.text.isEmpty
                    ? null
                    : descriptionController.text,
                isPublic: isPublic,
              );
              boxController.updateBox(updatedBox);
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
              boxController.deleteBox(widget.box.id!);
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
}

class _DraggableItem extends StatefulWidget {
  final ItemModel item;
  final Offset initialPosition;
  final double initialScale;
  final Function(Offset) onPositionChanged;
  final Function(double) onScaleChanged;
  final bool isExpired;
  final String? expiryText;

  const _DraggableItem({
    required Key key,
    required this.item,
    required this.initialPosition,
    required this.initialScale,
    required this.onPositionChanged,
    required this.onScaleChanged,
    required this.isExpired,
    this.expiryText,
  }) : super(key: key);

  @override
  State<_DraggableItem> createState() => _DraggableItemState();
}

class _DraggableItemState extends State<_DraggableItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isHovered = false;
  late Offset _position;
  late double _scale;
  final imgFile = File(widget.item.imagePath);

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
    _position = widget.initialPosition;
    _scale = widget.initialScale;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
            widget.onPositionChanged(_position);
          });
        },
        onScaleUpdate: (details) {
          setState(() {
            _scale = (_scale * details.scale).clamp(0.5, 2.0);
            widget.onScaleChanged(_scale);
          });
        },
        child: MouseRegion(
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
                  ..scale(_scale)
                  ..rotateX(_animation.value)
                  ..rotateY(_animation.value)
                  ..translate(0.0, -_animation.value * 20),
                alignment: Alignment.center,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: imgFile.existsSync()
                          ? FileImage(imgFile)
                          : const AssetImage('assets/images/placeholder.png')
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(_isHovered ? 0.4 : 0.2),
                        blurRadius: _isHovered ? 15 : 10,
                        offset: Offset(0, _isHovered ? 8 : 4),
                      ),
                    ],
                    border: Border.all(
                      color: widget.isExpired 
                          ? Colors.red.shade400.withOpacity(_isHovered ? 0.8 : 0.5)
                          : Colors.white.withOpacity(_isHovered ? 0.8 : 0.5),
                      width: _isHovered ? 2 : 1,
                    ),
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
                                    Colors.white.withOpacity(0.2),
                                    Colors.white.withOpacity(0.05),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 过期提醒
                      if (widget.isExpired)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.expiryText ?? '已过期',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // 物品信息
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            widget.item.note,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
