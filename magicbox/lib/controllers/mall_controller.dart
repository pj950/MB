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
  final RxString currentType = 'all'.obs;
  final RxString currentCurrency = 'all'.obs;

  @override
  void onInit() {
    super.onInit();
    loadItems();
    if (currentUser != null) {
      loadOrders();
    }
  }

  void setType(String type) {
    currentType.value = type;
    loadItems(type: type, currency: currentCurrency.value);
  }

  void setCurrency(String currency) {
    currentCurrency.value = currency;
    loadItems(type: currentType.value, currency: currency);
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
      orders.value =
          await _databaseService.getUserOrders(currentUser!.id!.toString());
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

  Future<void> purchaseItem(MallItemModel item,
      {String? shippingAddress}) async {
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

      // 检查库存
      if (item.stock < 1) {
        throw Exception('库存不足');
      }

      // 检查用户余额
      if (item.currency == 'coins' && currentUser!.coins < item.price) {
        throw Exception('金币不足');
      } else if (item.currency == 'points' &&
          currentUser!.points < item.price) {
        throw Exception('积分不足');
      }

      // 创建订单
      final order = OrderModel(
        userId: currentUser!.id!,
        itemId: item.id,
        orderNumber: _generateOrderNumber(),
        amount: item.price,
        currency: item.currency,
        status: OrderStatus.PENDING,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        shippingAddress: shippingAddress,
      );

      await _databaseService.createOrder(order);

      // 更新库存
      await _databaseService.updateMallItemStock(int.parse(item.id), 1);

      // 更新用户余额
      if (item.currency == 'coins') {
        await _databaseService.updateUser(
          currentUser!.copyWith(
            coins: currentUser!.coins - item.price.toInt(),
          ),
        );
      } else if (item.currency == 'points') {
        await _databaseService.updateUser(
          currentUser!.copyWith(
            points: currentUser!.points - item.price.toInt(),
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
      final item = await _databaseService.getMallItem(int.parse(order.itemId));
      if (item != null) {
        await _databaseService.updateMallItemStock(int.parse(item.id), -1);
      }

      // 恢复用户余额
      if (order.currency == 'coins') {
        await _databaseService.updateUser(
          currentUser!.copyWith(
            coins: currentUser!.coins + order.amount.toInt(),
          ),
        );
      } else if (order.currency == 'points') {
        await _databaseService.updateUser(
          currentUser!.copyWith(
            points: currentUser!.points + order.amount.toInt(),
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
