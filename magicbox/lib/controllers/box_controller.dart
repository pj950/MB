// lib/controllers/box_controller.dart
import 'package:get/get.dart';
import '../models/box_model.dart';
import '../services/db_service.dart';

class BoxController extends GetxController {
  var boxList = <BoxModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBoxes();
  }

  // 加载盒子列表
  Future<void> loadBoxes() async {
    final boxes = await DBService.getAllBoxes();
    print('📦 加载到盒子数量: \${result.length}');
    boxList.assignAll(boxes);
  }

  // 添加新盒子
  void addBox(BoxModel box) async {
    print('📥 插入盒子数据: \${box.toMap()}');
    await DBService.insertBox(box);
    print('✅ 已插入盒子：${box.name}');

    loadBoxes();
  }
}
