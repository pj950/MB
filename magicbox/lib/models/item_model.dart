// lib/models/item_model.dart

enum ItemStatus {
  ACTIVE,
  ARCHIVED,
  DELETED,
}

class ItemModel {
  final String id;
  final String boxId;
  final String name;
  final String description;
  final String imagePath;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expiryDate;
  final double posX;
  final double posY;
  final double scale;
  final String? watermarkText;
  final ItemStatus status;
  final bool isPublic;
  final Map<String, dynamic>? shareSettings;
  final Map<String, dynamic>? advancedProperties;
  final List<String> tags;
  final bool isFavorite;
  final int viewCount;
  final int copyCount;
  final List<String> imageUrls;
  final String? brand;
  final String? model;
  final String? serialNumber;
  final String? color;
  final String? size;
  final double? weight;
  final double? purchasePrice;
  final double? currentPrice;
  final DateTime? purchaseDate;
  final int? conditionRating;

  ItemModel({
    required this.id,
    required this.boxId,
    required this.name,
    required this.description,
    required this.imagePath,
    this.note = '',
    required this.createdAt,
    required this.updatedAt,
    this.expiryDate,
    this.posX = 0.0,
    this.posY = 0.0,
    this.scale = 1.0,
    this.watermarkText,
    this.status = ItemStatus.ACTIVE,
    this.isPublic = false,
    this.shareSettings,
    this.advancedProperties,
    List<String>? tags,
    this.isFavorite = false,
    this.viewCount = 0,
    this.copyCount = 0,
    List<String>? imageUrls,
    this.brand,
    this.model,
    this.serialNumber,
    this.color,
    this.size,
    this.weight,
    this.purchasePrice,
    this.currentPrice,
    this.purchaseDate,
    this.conditionRating,
  })  : tags = tags ?? [],
        imageUrls = imageUrls ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'box_id': boxId,
      'name': name,
      'description': description,
      'image_path': imagePath,
      'note': note,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'pos_x': posX,
      'pos_y': posY,
      'scale': scale,
      'watermark_text': watermarkText,
      'status': status.toString(),
      'isPublic': isPublic ? 1 : 0,
      'share_settings': shareSettings,
      'advanced_properties': advancedProperties,
      'tags': tags.join(','),
      'isfavorite': isFavorite ? 1 : 0,
      'view_count': viewCount,
      'copy_count': copyCount,
      'image_urls': imageUrls.join(','),
      'brand': brand,
      'model': model,
      'serial_number': serialNumber,
      'color': color,
      'size': size,
      'weight': weight,
      'purchase_price': purchasePrice,
      'current_price': currentPrice,
      'purchase_date': purchaseDate?.toIso8601String(),
      'condition_rating': conditionRating,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as String,
      boxId: map['box_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      imagePath: map['image_path'] as String,
      note: map['note'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      expiryDate: map['expiry_date'] != null
          ? DateTime.parse(map['expiry_date'] as String)
          : null,
      posX: (map['pos_x'] as num?)?.toDouble() ?? 0.0,
      posY: (map['pos_y'] as num?)?.toDouble() ?? 0.0,
      scale: (map['scale'] as num?)?.toDouble() ?? 1.0,
      watermarkText: map['watermark_text'] as String?,
      status: ItemStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => ItemStatus.ACTIVE,
      ),
      isPublic: map['isPublic'] == 1,
      shareSettings: map['share_settings'] as Map<String, dynamic>?,
      advancedProperties: map['advanced_properties'] as Map<String, dynamic>?,
      tags: (map['tags'] as String?)?.split(',') ?? [],
      isFavorite: map['isfavorite'] == 1,
      viewCount: map['view_count'] ?? 0,
      copyCount: map['copy_count'] ?? 0,
      imageUrls: (map['image_urls'] as String?)?.split(',') ?? [],
      brand: map['brand'] as String?,
      model: map['model'] as String?,
      serialNumber: map['serial_number'] as String?,
      color: map['color'] as String?,
      size: map['size'] as String?,
      weight: (map['weight'] as num?)?.toDouble(),
      purchasePrice: (map['purchase_price'] as num?)?.toDouble(),
      currentPrice: (map['current_price'] as num?)?.toDouble(),
      purchaseDate: map['purchase_date'] != null
          ? DateTime.parse(map['purchase_date'] as String)
          : null,
      conditionRating: map['condition_rating'] as int?,
    );
  }

  ItemModel copyWith({
    String? id,
    String? boxId,
    String? name,
    String? description,
    String? imagePath,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? expiryDate,
    double? posX,
    double? posY,
    double? scale,
    String? watermarkText,
    ItemStatus? status,
    bool? isPublic,
    Map<String, dynamic>? shareSettings,
    Map<String, dynamic>? advancedProperties,
    List<String>? tags,
    bool? isFavorite,
    int? viewCount,
    int? copyCount,
    List<String>? imageUrls,
    String? brand,
    String? model,
    String? serialNumber,
    String? color,
    String? size,
    double? weight,
    double? purchasePrice,
    double? currentPrice,
    DateTime? purchaseDate,
    int? conditionRating,
  }) {
    return ItemModel(
      id: id ?? this.id,
      boxId: boxId ?? this.boxId,
      name: name ?? this.name,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      expiryDate: expiryDate ?? this.expiryDate,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      scale: scale ?? this.scale,
      watermarkText: watermarkText ?? this.watermarkText,
      status: status ?? this.status,
      isPublic: isPublic ?? this.isPublic,
      shareSettings: shareSettings ?? this.shareSettings,
      advancedProperties: advancedProperties ?? this.advancedProperties,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      viewCount: viewCount ?? this.viewCount,
      copyCount: copyCount ?? this.copyCount,
      imageUrls: imageUrls ?? this.imageUrls,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      serialNumber: serialNumber ?? this.serialNumber,
      color: color ?? this.color,
      size: size ?? this.size,
      weight: weight ?? this.weight,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      currentPrice: currentPrice ?? this.currentPrice,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      conditionRating: conditionRating ?? this.conditionRating,
    );
  }

  // 检查是否允许查看
  bool isViewable(String userId) {
    if (isPublic) return true;
    return shareSettings?['allowed_viewers']?.contains(userId) ?? false;
  }

  // 检查是否允许编辑
  bool isEditable(String userId) {
    return shareSettings?['allowed_editors']?.contains(userId) ?? false;
  }

  // 检查是否允许下载原图
  bool allowsOriginalImageDownload(String userId) {
    if (!isViewable(userId)) return false;
    return shareSettings?['allow_download'] ?? false;
  }

  // 检查是否允许复制
  bool allowsCopy(String userId) {
    if (!isViewable(userId)) return false;
    return shareSettings?['allow_copy'] ?? false;
  }

  // 获取高级属性值
  dynamic getAdvancedProperty(String key) {
    return advancedProperties?[key];
  }

  // 设置高级属性值
  ItemModel setAdvancedProperty(String key, dynamic value) {
    final newProperties = Map<String, dynamic>.from(advancedProperties ?? {});
    newProperties[key] = value;
    return copyWith(advancedProperties: newProperties);
  }

  // 增加查看次数
  ItemModel incrementViewCount() {
    return copyWith(viewCount: viewCount + 1);
  }

  // 增加复制次数
  ItemModel incrementCopyCount() {
    return copyWith(copyCount: copyCount + 1);
  }
}
