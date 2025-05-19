import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mall_controller.dart';
import '../models/mall_item_model.dart';
import '../models/order_model.dart';

class MallPage extends StatelessWidget {
  final MallController _controller = Get.put(MallController());

  MallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('商城'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '商品'),
              Tab(text: '订单'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildItemsTab(),
            _buildOrdersTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsTab() {
    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: Obx(() {
            if (_controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_controller.items.isEmpty) {
              return const Center(child: Text('暂无商品'));
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _controller.items.length,
              itemBuilder: (context, index) {
                final item = _controller.items[index];
                return _buildItemCard(item);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              value: _controller.currentType.value,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('全部类型')),
                DropdownMenuItem(value: 'blind_box', child: Text('盲盒')),
                DropdownMenuItem(value: 'points_exchange', child: Text('积分兑换')),
                DropdownMenuItem(value: 'coins_exchange', child: Text('金币兑换')),
                DropdownMenuItem(value: 'physical', child: Text('实物商品')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _controller.setType(value);
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: _controller.currentCurrency.value,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'all', child: Text('全部货币')),
                DropdownMenuItem(value: 'points', child: Text('积分')),
                DropdownMenuItem(value: 'coins', child: Text('金币')),
                DropdownMenuItem(value: 'rmb', child: Text('人民币')),
              ],
              onChanged: (value) {
                if (value != null) {
                  _controller.setCurrency(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(MallItemModel item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showItemDetail(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                item.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.price} ${_getCurrencySymbol(item.currency)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '库存: ${item.stock}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
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
  }

  Widget _buildOrdersTab() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.orders.isEmpty) {
        return const Center(child: Text('暂无订单'));
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.orders.length,
        itemBuilder: (context, index) {
          final order = _controller.orders[index];
          return _buildOrderCard(order);
        },
      );
    });
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '订单号：${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                _buildOrderStatus(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '金额：${order.amount} ${_getCurrencySymbol(order.currency)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (order.shippingAddress != null) ...[
              const SizedBox(height: 8),
              Text(
                '收货地址：${order.shippingAddress}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            if (order.trackingNumber != null) ...[
              const SizedBox(height: 8),
              Text(
                '物流单号：${order.trackingNumber}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              '下单时间：${_formatDate(order.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatus(OrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case OrderStatus.PENDING:
        color = Colors.orange;
        text = '待支付';
        break;
      case OrderStatus.PAID:
        color = Colors.blue;
        text = '已支付';
        break;
      case OrderStatus.SHIPPED:
        color = Colors.purple;
        text = '已发货';
        break;
      case OrderStatus.COMPLETED:
        color = Colors.green;
        text = '已完成';
        break;
      case OrderStatus.CANCELLED:
        color = Colors.red;
        text = '已取消';
        break;
      default:
        color = Colors.grey;
        text = '未知';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showItemDetail(MallItemModel item) {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                item.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(item.description),
            const SizedBox(height: 8),
            Text(
              '价格：${item.price} ${_getCurrencySymbol(item.currency)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('库存：${item.stock}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showPurchaseDialog(item);
            },
            child: const Text('购买'),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(MallItemModel item) {
    String? shippingAddress;
    if (item.type == 'physical') {
      showDialog(
        context: Get.context!,
        builder: (context) => AlertDialog(
          title: const Text('填写收货地址'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: '收货地址',
              hintText: '请输入详细的收货地址',
            ),
            onChanged: (value) => shippingAddress = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (shippingAddress?.isNotEmpty == true) {
                  Get.back();
                  _controller.purchaseItem(item,
                      shippingAddress: shippingAddress);
                } else {
                  Get.snackbar(
                    '错误',
                    '请输入收货地址',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text('确认购买'),
            ),
          ],
        ),
      );
    } else {
      _controller.purchaseItem(item);
    }
  }

  String _getCurrencySymbol(CurrencyType currency) {
    switch (currency) {
      case CurrencyType.POINTS:
        return '积分';
      case CurrencyType.COINS:
        return '金币';
      case CurrencyType.RMB:
        return '元';
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
