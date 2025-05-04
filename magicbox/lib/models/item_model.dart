// lib/models/item_model.dart
class ItemModel {
  int? id;
  int boxId;
  String imagePath;
  String note;
  String? expiryDate;
  double? posX;
  double? posY;

  ItemModel({
    this.id,
    required this.boxId,
    required this.imagePath,
    required this.note,
    this.expiryDate,
    this.posX,
    this.posY,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'boxId': boxId,
        'imagePath': imagePath,
        'note': note,
        'expiryDate': expiryDate,
        'posX': posX,
        'posY': posY,
      };

  factory ItemModel.fromMap(Map<String, dynamic> map) => ItemModel(
        id: map['id'],
        boxId: map['boxId'],
        imagePath: map['imagePath'],
        note: map['note'],
        expiryDate: map['expiryDate'],
        posX: map['posX'],
        posY: map['posY'],
      );
}
