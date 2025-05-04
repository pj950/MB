import 'package:get/get.dart';
import '../models/item_model.dart';
import '../services/db_service.dart';

class ItemController extends GetxController {
  final itemList = <ItemModel>[].obs;
  final List<ItemModel> _allItems = [];
  int _currentBoxId = 0;

  int get boxId => _currentBoxId;

  // 加载指定盒子的物品
  void loadItems(int boxId) async {
    _currentBoxId = boxId;
    final items = await DBService.getItemsByBoxId(boxId);
    _allItems
      ..clear()
      ..addAll(items);
    itemList.value = List.from(_allItems);
  }

  // 添加新物品
  Future<void> addItem(ItemModel item) async {
    await DBService.insertItem(item);
    loadItems(_currentBoxId);
  }

  // 删除物品
  Future<void> deleteItem(int id) async {
    await DBService.deleteItem(id);
    _allItems.removeWhere((e) => e.id == id);
    itemList.value = List.from(_allItems);
  }

  // 更新物品
  Future<void> updateItem(ItemModel item) async {
    await DBService.updateItem(item);
    final index = _allItems.indexWhere((e) => e.id == item.id);
    if (index != -1) _allItems[index] = item;
    itemList.value = List.from(_allItems);
  }

  // 搜索物品
  void searchItems(String keyword) {
    itemList.value = _allItems
        .where(
            (item) => item.note.toLowerCase().contains(keyword.toLowerCase()))
        .toList();
  }
}
