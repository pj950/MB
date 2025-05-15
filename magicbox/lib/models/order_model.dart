class OrderModel {
  final int? id;
  final int userId;
  final int itemId;
  final String orderNumber;
  final double amount;
  final String currency;
  final String status; // 'pending', 'paid', 'shipped', 'completed', 'cancelled'
  final String? shippingAddress;
  final String? trackingNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    this.id,
    required this.userId,
    required this.itemId,
    required this.orderNumber,
    required this.amount,
    required this.currency,
    required this.status,
    this.shippingAddress,
    this.trackingNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  OrderModel copyWith({
    int? id,
    int? userId,
    int? itemId,
    String? orderNumber,
    double? amount,
    String? currency,
    String? status,
    String? shippingAddress,
    String? trackingNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'item_id': itemId,
      'order_number': orderNumber,
      'amount': amount,
      'currency': currency,
      'status': status,
      'shipping_address': shippingAddress,
      'tracking_number': trackingNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      itemId: map['item_id'] as int,
      orderNumber: map['order_number'] as String,
      amount: map['amount'] as double,
      currency: map['currency'] as String,
      status: map['status'] as String,
      shippingAddress: map['shipping_address'] as String?,
      trackingNumber: map['tracking_number'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
} 