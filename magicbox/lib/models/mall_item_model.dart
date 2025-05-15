class MallItemModel {
  final int? id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final int stock;
  final String type; // 'blind_box', 'points_exchange', 'coins_exchange', 'physical'
  final String currency; // 'points', 'coins', 'rmb'
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MallItemModel({
    this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.stock,
    required this.type,
    required this.currency,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  MallItemModel copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    double? price,
    int? stock,
    String? type,
    String? currency,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MallItemModel(
      id: id ?? this.id,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'stock': stock,
      'type': type,
      'currency': currency,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MallItemModel.fromMap(Map<String, dynamic> map) {
    return MallItemModel(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      imageUrl: map['image_url'] as String,
      price: map['price'] as double,
      stock: map['stock'] as int,
      type: map['type'] as String,
      currency: map['currency'] as String,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
} 