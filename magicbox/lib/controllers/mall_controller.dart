import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/mall_item_model.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';

class MallController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel? currentUser = Get.find<UserModel?>();

  final RxList<MallItemModel> items = <MallItemModel>[].obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<MallItemModel?> currentItem = Rx<MallItemModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadItems();
    if (currentUser != null) {
      loadOrders();
    }
  }

  Future<void> loadItems({
    String? type,
    String? currency,
    bool onlyActive = true,
  }) async {
    try {
      isLoading.value = true;
      items.value = await _databaseService.getMallItems(
        type: type,
        currency: currency,
        onlyActive: onlyActive,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载商品列表失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOrders() async {
    if (currentUser == null) return;

    try {
      isLoading.value = true;
      orders.value = await _databaseService.getUserOrders(currentUser!.id!);
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载订单列表失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> purchaseItem(int itemId, int quantity) async {
    if (currentUser == null) {
      Get.snackbar(
        '错误',
        '请先登录',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 获取商品信息
      final item = await _databaseService.getMallItem(itemId);
      if (item == null) {
        throw Exception('商品不存在');
      }

      // 检查库存
      if (item.stock < quantity) {
        throw Exception('库存不足');
      }

      // 检查用户余额
      if (item.currency == 'coins' && currentUser!.coins < item.price * quantity) {
        throw Exception('金币不足');
      } else if (item.currency == 'points' && currentUser!.points < item.price * quantity) {
        throw Exception('积分不足');
      }

      // 创建订单
      final order = OrderModel(
        userId: currentUser!.id!,
        itemId: itemId,
        orderNumber: _generateOrderNumber(),
        amount: item.price * quantity,
        currency: item.currency,
        status: 'pending',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _databaseService.createOrder(order);

      // 更新库存
      await _databaseService.updateMallItemStock(itemId, quantity);

      // 更新用户余额
      if (item.currency == 'coins') {
        await _databaseService.updateUser(
          currentUser!.copyWith(
            coins: currentUser!.coins - (item.price * quantity),
          ),
        );
      } else if (item.currency == 'points') {
        await _databaseService.updateUser(
          currentUser!.copyWith(
            points: currentUser!.points - (item.price * quantity),
          ),
        );
      }

      Get.snackbar(
        '成功',
        '购买成功',
        snackPosition: SnackPosition.BOTTOM,
      );

      // 刷新列表
      loadItems();
      loadOrders();
    } catch (e) {
      Get.snackbar(
        '错误',
        '购买失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelOrder(String orderNumber) async {
    if (currentUser == null) return;

    try {
      isLoading.value = true;

      final order = await _databaseService.getOrder(orderNumber);
      if (order == null) {
        throw Exception('订单不存在');
      }

      if (order.status != 'pending') {
        throw Exception('只能取消待处理的订单');
      }

      // 更新订单状态
      await _databaseService.updateOrderStatus(orderNumber, 'cancelled');

      // 恢复库存
      final item = await _databaseService.getMallItem(order.itemId);
      if (item != null) {
        await _databaseService.updateMallItemStock(item.id!, -1);
      }

      // 恢复用户余额
      if (order.currency == 'coins') {
        await _databaseService.updateUser(
          currentUser!.copyWith(
            coins: currentUser!.coins + order.amount,
          ),
        );
      } else if (order.currency == 'points') {
        await _databaseService.updateUser(
          currentUser!.copyWith(
            points: currentUser!.points + order.amount,
          ),
        );
      }

      Get.snackbar(
        '成功',
        '订单已取消',
        snackPosition: SnackPosition.BOTTOM,
      );

      // 刷新列表
      loadOrders();
    } catch (e) {
      Get.snackbar(
        '错误',
        '取消订单失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString();
    final random = (1000 + DateTime.now().microsecond % 9000).toString();
    return 'MB$timestamp$random';
  }
} 