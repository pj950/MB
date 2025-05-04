// lib/models/box_model.dart
class BoxModel {
  int? id;
  String name;
  String coverImage;
  String themeColor;
  int itemCount;
  bool hasExpiredItems;

  BoxModel({
    this.id,
    required this.name,
    required this.coverImage,
    required this.themeColor,
    this.itemCount = 0,
    this.hasExpiredItems = false,
  });

  // 将数据库记录转成Box对象
  factory BoxModel.fromMap(Map<String, dynamic> map) {
    return BoxModel(
      id: map['id'],
      name: map['name'],
      coverImage: map['coverImage'],
      themeColor: map['themeColor'],
      itemCount: map['itemCount'] ?? 0,
      hasExpiredItems: map['hasExpiredItems'] == 1,
    );
  }

  // 将Box对象转成可插入数据库的Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'coverImage': coverImage,
      'themeColor': themeColor,
      'itemCount': itemCount,
      'hasExpiredItems': hasExpiredItems ? 1 : 0,
    };
  }
}
