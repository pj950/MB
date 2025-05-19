import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/item_model.dart';
import '../controllers/item_controller.dart';

class ItemDetailPage extends StatelessWidget {
  final ItemModel item;
  final ItemController _controller = Get.find<ItemController>();

  ItemDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: Icon(
              item.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: item.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              final updatedItem = item.copyWith(isFavorite: !item.isFavorite);
              _controller.updateItem(updatedItem);
            },
          ),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: item.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () =>
                            _showImageDialog(context, item.imageUrls[index]),
                        child: Image.file(
                          File(item.imageUrls[index]),
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '描述',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(item.description),
                  const SizedBox(height: 16),
                  if (item.brand != null) ...[
                    const Text(
                      '品牌',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(item.brand!),
                    const SizedBox(height: 16),
                  ],
                  if (item.model != null) ...[
                    const Text(
                      '型号',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(item.model!),
                    const SizedBox(height: 16),
                  ],
                  if (item.serialNumber != null) ...[
                    const Text(
                      '序列号',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(item.serialNumber!),
                    const SizedBox(height: 16),
                  ],
                  if (item.color != null) ...[
                    const Text(
                      '颜色',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(item.color!),
                    const SizedBox(height: 16),
                  ],
                  if (item.size != null) ...[
                    const Text(
                      '尺寸',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(item.size!),
                    const SizedBox(height: 16),
                  ],
                  if (item.weight != null) ...[
                    const Text(
                      '重量',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${item.weight} kg'),
                    const SizedBox(height: 16),
                  ],
                  if (item.purchasePrice != null) ...[
                    const Text(
                      '购买价格',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('¥${item.purchasePrice}'),
                    const SizedBox(height: 16),
                  ],
                  if (item.currentPrice != null) ...[
                    const Text(
                      '当前价格',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('¥${item.currentPrice}'),
                    const SizedBox(height: 16),
                  ],
                  if (item.purchaseDate != null) ...[
                    const Text(
                      '购买日期',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(item.purchaseDate.toString().split(' ')[0]),
                    const SizedBox(height: 16),
                  ],
                  if (item.conditionRating != null) ...[
                    const Text(
                      '物品状况',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          color: index < item.conditionRating!
                              ? Colors.amber
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            Image.file(
              File(imagePath),
              fit: BoxFit.contain,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final brandController = TextEditingController(text: item.brand);
    final modelController = TextEditingController(text: item.model);
    final serialNumberController =
        TextEditingController(text: item.serialNumber);
    final colorController = TextEditingController(text: item.color);
    final sizeController = TextEditingController(text: item.size);
    final weightController =
        TextEditingController(text: item.weight?.toString() ?? '');
    final purchasePriceController =
        TextEditingController(text: item.purchasePrice?.toString() ?? '');
    final currentPriceController =
        TextEditingController(text: item.currentPrice?.toString() ?? '');
    DateTime? purchaseDate = item.purchaseDate;
    int? conditionRating = item.conditionRating;
    bool isFavorite = item.isFavorite;
    final List<String> imageUrls = List.from(item.imageUrls);

    Get.dialog(
      AlertDialog(
        title: const Text('编辑物品'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '物品名称',
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
                TextField(
                  controller: brandController,
                  decoration: const InputDecoration(
                    labelText: '品牌（选填）',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: modelController,
                  decoration: const InputDecoration(
                    labelText: '型号（选填）',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: serialNumberController,
                  decoration: const InputDecoration(
                    labelText: '序列号（选填）',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: colorController,
                  decoration: const InputDecoration(
                    labelText: '颜色（选填）',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: sizeController,
                  decoration: const InputDecoration(
                    labelText: '尺寸（选填）',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: '重量（选填）',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: purchasePriceController,
                  decoration: const InputDecoration(
                    labelText: '购买价格（选填）',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: currentPriceController,
                  decoration: const InputDecoration(
                    labelText: '当前价格（选填）',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('购买日期'),
                  subtitle: Text(
                    purchaseDate?.toString().split(' ')[0] ?? '未设置',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: purchaseDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => purchaseDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: conditionRating,
                  items: List.generate(5, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text('${index + 1}星'),
                    );
                  }),
                  onChanged: (value) {
                    setState(() => conditionRating = value);
                  },
                  decoration: const InputDecoration(
                    labelText: '物品状况',
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('收藏'),
                  value: isFavorite,
                  onChanged: (value) {
                    setState(() => isFavorite = value);
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final paths = await _controller.uploadImages();
                    if (paths.isNotEmpty) {
                      setState(() {
                        imageUrls.addAll(paths);
                      });
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('添加图片'),
                ),
                if (imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Image.file(
                                File(imageUrls[index]),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    imageUrls.removeAt(index);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
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
                Get.snackbar('错误', '请输入物品名称');
                return;
              }
              final updatedItem = item.copyWith(
                name: nameController.text,
                description: descriptionController.text.isEmpty
                    ? null
                    : descriptionController.text,
                brand:
                    brandController.text.isEmpty ? null : brandController.text,
                model:
                    modelController.text.isEmpty ? null : modelController.text,
                serialNumber: serialNumberController.text.isEmpty
                    ? null
                    : serialNumberController.text,
                color:
                    colorController.text.isEmpty ? null : colorController.text,
                size: sizeController.text.isEmpty ? null : sizeController.text,
                weight: weightController.text.isEmpty
                    ? null
                    : double.tryParse(weightController.text),
                purchasePrice: purchasePriceController.text.isEmpty
                    ? null
                    : double.tryParse(purchasePriceController.text),
                currentPrice: currentPriceController.text.isEmpty
                    ? null
                    : double.tryParse(currentPriceController.text),
                purchaseDate: purchaseDate,
                conditionRating: conditionRating,
                isFavorite: isFavorite,
                imageUrls: imageUrls,
              );
              _controller.updateItem(updatedItem);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除物品'),
        content: const Text('确定要删除这个物品吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _controller.deleteItem(item.id);
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
