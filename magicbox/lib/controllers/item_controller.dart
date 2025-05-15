import 'package:get/get.dart';
import '../models/item_model.dart';
import '../services/database_service.dart';
import '../services/file_service.dart';

class ItemController extends GetxController {
  final DatabaseService _db = DatabaseService();
  final FileService _fileService = FileService();
  final RxList<ItemModel> _items = <ItemModel>[].obs;
  final RxBool _isLoading = false.obs;

  List<ItemModel> get items => _items;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    loadItems();
  }

  Future<void> loadItems() async {
    _isLoading.value = true;
    try {
      final items = await _db.getAllItems();
      _items.value = items;
    } catch (e) {
      Get.snackbar('错误', '加载物品失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  List<ItemModel> getItemsByBox(int boxId) {
    return _items.where((item) => item.boxId == boxId).toList();
  }

  Future<void> createItem({
    required int boxId,
    required String name,
    String? description,
    List<String> imageUrls = const [],
    DateTime? purchaseDate,
    double? purchasePrice,
    double? currentPrice,
    String? brand,
    String? model,
    String? serialNumber,
    String? qrCode,
    String? nfcTag,
    String? color,
    String? size,
    double? weight,
    int? conditionRating,
    bool isFavorite = false,
  }) async {
    _isLoading.value = true;
    try {
      final item = ItemModel(
        boxId: boxId,
        name: name,
        description: description,
        imageUrls: imageUrls,
        purchaseDate: purchaseDate,
        purchasePrice: purchasePrice,
        currentPrice: currentPrice,
        brand: brand,
        model: model,
        serialNumber: serialNumber,
        qrCode: qrCode,
        nfcTag: nfcTag,
        color: color,
        size: size,
        weight: weight,
        conditionRating: conditionRating,
        isFavorite: isFavorite,
      );
      
      final itemId = await _db.insertItem(item);
      item.id = itemId;
      _items.add(item);
      
      Get.back();
      Get.snackbar('成功', '物品创建成功');
    } catch (e) {
      Get.snackbar('错误', '创建物品失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateItem(ItemModel item) async {
    _isLoading.value = true;
    try {
      await _db.updateItem(item);
      final index = _items.indexWhere((i) => i.id == item.id);
      if (index != -1) {
        _items[index] = item;
      }
      Get.back();
      Get.snackbar('成功', '物品更新成功');
    } catch (e) {
      Get.snackbar('错误', '更新物品失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteItem(int itemId) async {
    _isLoading.value = true;
    try {
      final item = _items.firstWhere((i) => i.id == itemId);
      await _fileService.deleteImages(item.imageUrls);
      await _db.deleteItem(itemId);
      _items.removeWhere((item) => item.id == itemId);
      Get.back();
      Get.snackbar('成功', '物品删除成功');
    } catch (e) {
      Get.snackbar('错误', '删除物品失败：$e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<List<String>> uploadImages() async {
    try {
      return await _fileService.pickAndSaveMultipleImages();
    } catch (e) {
      Get.snackbar('错误', '上传图片失败：$e');
      return [];
    }
  }

  Future<void> deleteImage(String imagePath) async {
    try {
      await _fileService.deleteImage(imagePath);
    } catch (e) {
      Get.snackbar('错误', '删除图片失败：$e');
    }
  }

  void showCreateItemDialog(int boxId) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final serialNumberController = TextEditingController();
    final colorController = TextEditingController();
    final sizeController = TextEditingController();
    final weightController = TextEditingController();
    final purchasePriceController = TextEditingController();
    final currentPriceController = TextEditingController();
    DateTime? purchaseDate;
    int? conditionRating;
    bool isFavorite = false;
    List<String> imageUrls = [];

    Get.dialog(
      AlertDialog(
        title: const Text('添加物品'),
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
                      initialDate: DateTime.now(),
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
                    final paths = await uploadImages();
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
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isEmpty) {
                Get.snackbar('错误', '请输入物品名称');
                return;
              }
              createItem(
                boxId: boxId,
                name: nameController.text,
                description: descriptionController.text.isEmpty
                    ? null
                    : descriptionController.text,
                brand: brandController.text.isEmpty
                    ? null
                    : brandController.text,
                model: modelController.text.isEmpty
                    ? null
                    : modelController.text,
                serialNumber: serialNumberController.text.isEmpty
                    ? null
                    : serialNumberController.text,
                color: colorController.text.isEmpty
                    ? null
                    : colorController.text,
                size: sizeController.text.isEmpty
                    ? null
                    : sizeController.text,
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
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}
