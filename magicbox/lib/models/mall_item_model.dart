import 'package:uuid/uuid.dart';

enum MallItemType {
  BLIND_BOX,
  POINTS_EXCHANGE,
  COINS_EXCHANGE,
  PHYSICAL,
}

enum CurrencyType {
  POINTS,
  COINS,
  RMB,
}

class MallItemModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final int stock;
  final MallItemType type;
  final CurrencyType currency;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? category;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final String? color;
  final String? size;
  final double? weight;
  final String? condition;
  final int? viewCount;
  final int? purchaseCount;
  final double? rating;
  final int? ratingCount;
  final String? tags;
  final Map<String, dynamic>? properties;
  final String? sellerId;
  final String? sellerName;
  final String? sellerAvatar;
  final bool isRecommended;
  final bool isHot;
  final bool isNew;
  final DateTime? expiryDate;
  final String? discountInfo;
  final double? originalPrice;
  final int? limitPerUser;
  final String? shippingInfo;
  final String? returnPolicy;
  final String? warrantyInfo;

  MallItemModel({
    String? id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.stock,
    required this.type,
    required this.currency,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.category,
    this.brand,
    this.model,
    this.serialNumber,
    this.color,
    this.size,
    this.weight,
    this.condition,
    this.viewCount = 0,
    this.purchaseCount = 0,
    this.rating,
    this.ratingCount = 0,
    this.tags,
    this.properties,
    this.sellerId,
    this.sellerName,
    this.sellerAvatar,
    this.isRecommended = false,
    this.isHot = false,
    this.isNew = false,
    this.expiryDate,
    this.discountInfo,
    this.originalPrice,
    this.limitPerUser,
    this.shippingInfo,
    this.returnPolicy,
    this.warrantyInfo,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'stock': stock,
      'type': type.toString(),
      'currency': currency.toString(),
      'isactive': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'category': category,
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'color': color,
      'size': size,
      'weight': weight,
      'condition': condition,
      'view_count': viewCount,
      'purchase_count': purchaseCount,
      'rating': rating,
      'rating_count': ratingCount,
      'tags': tags,
      'properties': properties,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'seller_avatar': sellerAvatar,
      'isrecommended': isRecommended ? 1 : 0,
      'ishot': isHot ? 1 : 0,
      'isnew': isNew ? 1 : 0,
      'expiry_date': expiryDate?.toIso8601String(),
      'discount_info': discountInfo,
      'original_price': originalPrice,
      'limit_per_user': limitPerUser,
      'shipping_info': shippingInfo,
      'return_policy': returnPolicy,
      'warranty_info': warrantyInfo,
    };
  }

  factory MallItemModel.fromMap(Map<String, dynamic> map) {
    return MallItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      imageUrl: map['image_url'] as String,
      price: map['price'] as double,
      stock: map['stock'] as int,
      type: MallItemType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => MallItemType.PHYSICAL,
      ),
      currency: CurrencyType.values.firstWhere(
        (e) => e.toString() == map['currency'],
        orElse: () => CurrencyType.RMB,
      ),
      isActive: map['isactive'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      category: map['category'] as String?,
      brand: map['brand'] as String?,
      model: map['model'] as String?,
      serialNumber: map['serial_number'] as String?,
      color: map['color'] as String?,
      size: map['size'] as String?,
      weight: map['weight'] as double?,
      condition: map['condition'] as String?,
      viewCount: map['view_count'] as int?,
      purchaseCount: map['purchase_count'] as int?,
      rating: map['rating'] as double?,
      ratingCount: map['rating_count'] as int?,
      tags: map['tags'] as String?,
      properties: map['properties'] as Map<String, dynamic>?,
      sellerId: map['seller_id'] as String?,
      sellerName: map['seller_name'] as String?,
      sellerAvatar: map['seller_avatar'] as String?,
      isRecommended: map['isrecommended'] == 1,
      isHot: map['ishot'] == 1,
      isNew: map['isnew'] == 1,
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'] as String)
          : null,
      discountInfo: map['discount_info'] as String?,
      originalPrice: map['original_price'] as double?,
      limitPerUser: map['limit_per_user'] as int?,
      shippingInfo: map['shipping_info'] as String?,
      returnPolicy: map['return_policy'] as String?,
      warrantyInfo: map['warranty_info'] as String?,
    );
  }

  MallItemModel copyWith({
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    int? stock,
    MallItemType? type,
    CurrencyType? currency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    String? brand,
    String? model,
    String? serialNumber,
    String? color,
    String? size,
    double? weight,
    String? condition,
    int? viewCount,
    int? purchaseCount,
    double? rating,
    int? ratingCount,
    String? tags,
    Map<String, dynamic>? properties,
    String? sellerId,
    String? sellerName,
    String? sellerAvatar,
    bool? isRecommended,
    bool? isHot,
    bool? isNew,
    DateTime? expiryDate,
    String? discountInfo,
    double? originalPrice,
    int? limitPerUser,
    String? shippingInfo,
    String? returnPolicy,
    String? warrantyInfo,
  }) {
    return MallItemModel(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      color: color ?? this.color,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      condition: condition ?? this.condition,
      viewCount: viewCount ?? this.viewCount,
      purchaseCount: purchaseCount ?? this.purchaseCount,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      tags: tags ?? this.tags,
      properties: properties ?? this.properties,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatar: sellerAvatar ?? this.sellerAvatar,
      isRecommended: isRecommended ?? this.isRecommended,
      isHot: isHot ?? this.isHot,
      isNew: isNew ?? this.isNew,
      expiryDate: expiryDate ?? this.expiryDate,
      discountInfo: discountInfo ?? this.discountInfo,
      originalPrice: originalPrice ?? this.originalPrice,
      limitPerUser: limitPerUser ?? this.limitPerUser,
      shippingInfo: shippingInfo ?? this.shippingInfo,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      warrantyInfo: warrantyInfo ?? this.warrantyInfo,
    );
  }

  // 检查商品是否可购买
  bool isAvailable() {
    return isActive &&
        stock > 0 &&
        (expiryDate == null || DateTime.now().isBefore(expiryDate!));
  }

  // 获取折扣信息
  String? getDiscountInfo() {
    if (originalPrice == null || originalPrice! <= price) return null;
    final discount = ((originalPrice! - price) / originalPrice! * 100).round();
    return '$discount% 折扣';
  }

  // 获取商品标签列表
  List<String> getTags() {
    return tags?.split(',') ?? [];
  }

  // 获取商品属性
  Map<String, dynamic> getProperties() {
    return properties ?? {};
  }
}
