import 'package:magic_box_app/models/mall_item_model.dart';
import 'package:uuid/uuid.dart';

enum OrderStatus {
  PENDING,
  PAID,
  SHIPPED,
  COMPLETED,
  CANCELLED,
  REFUNDED,
  PARTIALLY_REFUNDED,
}

enum PaymentMethod {
  ALIPAY,
  WECHAT_PAY,
  CREDIT_CARD,
  POINTS,
  COINS,
}

class OrderModel {
  final String id;
  final String userId;
  final String itemId;
  final String orderNumber;
  final double amount;
  final CurrencyType currency;
  final OrderStatus status;
  final String? shippingAddress;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PaymentMethod paymentMethod;
  final String? paymentId;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final DateTime? refundedAt;
  final String? cancelReason;
  final String? refundReason;
  final double? refundAmount;
  final String? buyerNote;
  final String? sellerNote;
  final String? buyerName;
  final String? buyerPhone;
  final String? buyerEmail;
  final String? sellerId;
  final String? sellerName;
  final String? sellerPhone;
  final String? sellerEmail;
  final String? shippingCompany;
  final DateTime? estimatedDeliveryDate;
  final String? deliveryNote;
  final bool isGift;
  final String? giftMessage;
  final bool isAnonymous;
  final int? rating;
  final String? review;
  final DateTime? reviewAt;
  final Map<String, dynamic>? metadata;

  OrderModel({
    String? id,
    required this.userId,
    required this.itemId,
    String? orderNumber,
    required this.amount,
    required this.currency,
    this.status = OrderStatus.PENDING,
    this.shippingAddress,
    this.trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.paymentMethod = PaymentMethod.ALIPAY,
    this.paymentId,
    this.paidAt,
    this.shippedAt,
    this.completedAt,
    this.cancelledAt,
    this.refundedAt,
    this.cancelReason,
    this.refundReason,
    this.refundAmount,
    this.buyerNote,
    this.sellerNote,
    this.buyerName,
    this.buyerPhone,
    this.buyerEmail,
    this.sellerId,
    this.sellerName,
    this.sellerPhone,
    this.sellerEmail,
    this.shippingCompany,
    this.estimatedDeliveryDate,
    this.deliveryNote,
    this.isGift = false,
    this.giftMessage,
    this.isAnonymous = false,
    this.rating,
    this.review,
    this.reviewAt,
    this.metadata,
  })  : id = id ?? const Uuid().v4(),
        orderNumber = orderNumber ?? _generateOrderNumber(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static String _generateOrderNumber() {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch.toString();
    final random = (now.microsecond % 1000).toString().padLeft(3, '0');
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}$timestamp$random';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'item_id': itemId,
      'order_number': orderNumber,
      'amount': amount,
      'currency': currency,
      'status': status.toString(),
      'shipping_address': shippingAddress,
      'tracking_number': trackingNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'payment_method': paymentMethod.toString(),
      'payment_id': paymentId,
      'paid_at': paidAt?.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'refunded_at': refundedAt?.toIso8601String(),
      'cancel_reason': cancelReason,
      'refund_reason': refundReason,
      'refund_amount': refundAmount,
      'buyer_note': buyerNote,
      'seller_note': sellerNote,
      'buyer_name': buyerName,
      'buyer_phone': buyerPhone,
      'buyer_email': buyerEmail,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'seller_phone': sellerPhone,
      'seller_email': sellerEmail,
      'shipping_company': shippingCompany,
      'estimated_delivery_date': estimatedDeliveryDate?.toIso8601String(),
      'delivery_note': deliveryNote,
      'isgift': isGift ? 1 : 0,
      'gift_message': giftMessage,
      'isanonymous': isAnonymous ? 1 : 0,
      'rating': rating,
      'review': review,
      'review_at': reviewAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      itemId: map['item_id'] as String,
      orderNumber: map['order_number'] as String,
      amount: map['amount'] as double,
      currency: map['currency'] as CurrencyType,
      status: OrderStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => OrderStatus.PENDING,
      ),
      shippingAddress: map['shipping_address'] as String?,
      trackingNumber: map['tracking_number'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == map['payment_method'],
        orElse: () => PaymentMethod.ALIPAY,
      ),
      paymentId: map['payment_id'] as String?,
      paidAt: map['paid_at'] != null
          ? DateTime.parse(map['paid_at'] as String)
          : null,
      shippedAt: map['shipped_at'] != null
          ? DateTime.parse(map['shipped_at'] as String)
          : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
      cancelledAt: map['cancelled_at'] != null
          ? DateTime.parse(map['cancelled_at'] as String)
          : null,
      refundedAt: map['refunded_at'] != null
          ? DateTime.parse(map['refunded_at'] as String)
          : null,
      cancelReason: map['cancel_reason'] as String?,
      refundReason: map['refund_reason'] as String?,
      refundAmount: map['refund_amount'] as double?,
      buyerNote: map['buyer_note'] as String?,
      sellerNote: map['seller_note'] as String?,
      buyerName: map['buyer_name'] as String?,
      buyerPhone: map['buyer_phone'] as String?,
      buyerEmail: map['buyer_email'] as String?,
      sellerId: map['seller_id'] as String?,
      sellerName: map['seller_name'] as String?,
      sellerPhone: map['seller_phone'] as String?,
      sellerEmail: map['seller_email'] as String?,
      shippingCompany: map['shipping_company'] as String?,
      estimatedDeliveryDate: map['estimated_delivery_date'] != null
          ? DateTime.parse(map['estimated_delivery_date'] as String)
          : null,
      deliveryNote: map['delivery_note'] as String?,
      isGift: map['isgift'] == 1,
      giftMessage: map['gift_message'] as String?,
      isAnonymous: map['isanonymous'] == 1,
      rating: map['rating'] as int?,
      review: map['review'] as String?,
      reviewAt: map['review_at'] != null
          ? DateTime.parse(map['review_at'] as String)
          : null,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }

  OrderModel copyWith({
    String? userId,
    String? itemId,
    String? orderNumber,
    double? amount,
    CurrencyType? currency,
    OrderStatus? status,
    String? shippingAddress,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    PaymentMethod? paymentMethod,
    String? paymentId,
    DateTime? paidAt,
    DateTime? shippedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    DateTime? refundedAt,
    String? cancelReason,
    String? refundReason,
    double? refundAmount,
    String? buyerNote,
    String? sellerNote,
    String? buyerName,
    String? buyerPhone,
    String? buyerEmail,
    String? sellerId,
    String? sellerName,
    String? sellerPhone,
    String? sellerEmail,
    String? shippingCompany,
    DateTime? estimatedDeliveryDate,
    String? deliveryNote,
    bool? isGift,
    String? giftMessage,
    bool? isAnonymous,
    int? rating,
    String? review,
    DateTime? reviewAt,
    Map<String, dynamic>? metadata,
  }) {
    return OrderModel(
      id: id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      orderNumber: orderNumber ?? this.orderNumber,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      paidAt: paidAt ?? this.paidAt,
      shippedAt: shippedAt ?? this.shippedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      refundedAt: refundedAt ?? this.refundedAt,
      cancelReason: cancelReason ?? this.cancelReason,
      refundReason: refundReason ?? this.refundReason,
      refundAmount: refundAmount ?? this.refundAmount,
      buyerNote: buyerNote ?? this.buyerNote,
      sellerNote: sellerNote ?? this.sellerNote,
      buyerName: buyerName ?? this.buyerName,
      buyerPhone: buyerPhone ?? this.buyerPhone,
      buyerEmail: buyerEmail ?? this.buyerEmail,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      sellerEmail: sellerEmail ?? this.sellerEmail,
      shippingCompany: shippingCompany ?? this.shippingCompany,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      deliveryNote: deliveryNote ?? this.deliveryNote,
      isGift: isGift ?? this.isGift,
      giftMessage: giftMessage ?? this.giftMessage,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      reviewAt: reviewAt ?? this.reviewAt,
      metadata: metadata ?? this.metadata,
    );
  }

  // 检查订单是否可以取消
  bool canCancel() {
    return status == OrderStatus.PENDING || status == OrderStatus.PAID;
  }

  // 检查订单是否可以退款
  bool canRefund() {
    return status == OrderStatus.PAID || status == OrderStatus.SHIPPED;
  }

  // 检查订单是否可以评价
  bool canReview() {
    return status == OrderStatus.COMPLETED && rating == null;
  }

  // 获取订单状态文本
  String getStatusText() {
    switch (status) {
      case OrderStatus.PENDING:
        return '待付款';
      case OrderStatus.PAID:
        return '已付款';
      case OrderStatus.SHIPPED:
        return '已发货';
      case OrderStatus.COMPLETED:
        return '已完成';
      case OrderStatus.CANCELLED:
        return '已取消';
      case OrderStatus.REFUNDED:
        return '已退款';
      case OrderStatus.PARTIALLY_REFUNDED:
        return '部分退款';
    }
  }

  // 获取支付方式文本
  String getPaymentMethodText() {
    switch (paymentMethod) {
      case PaymentMethod.ALIPAY:
        return '支付宝';
      case PaymentMethod.WECHAT_PAY:
        return '微信支付';
      case PaymentMethod.CREDIT_CARD:
        return '信用卡';
      case PaymentMethod.POINTS:
        return '积分';
      case PaymentMethod.COINS:
        return '金币';
    }
  }
}
