// lib/services/db_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/box_model.dart';
import '../models/item_model.dart';

class DBService {
  static Database? _db;

  // 打开数据库
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  // 初始化数据库
  static Future<Database> initDB() async {
    final String path = join(await getDatabasesPath(), 'magic_box.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE boxes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          coverImage TEXT,
          themeColor TEXT,
          itemCount INTEGER,
          hasExpiredItems INTEGER
        )
      ''');
      await db.execute('''
        CREATE TABLE items (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          boxId INTEGER,
          imagePath TEXT,
          note TEXT,
          expiryDate TEXT,
          posX REAL,
          posY REAL
        )
      ''');
    });
  }

  // 插入盒子
  static Future<void> insertBox(BoxModel box) async {
    final db = await database;
    await db.insert('boxes', box.toMap());
  }

  // 获取所有盒子
  static Future<List<BoxModel>> getAllBoxes() async {
    final db = await database;
    final res = await db.query('boxes');
    return res.map((e) => BoxModel.fromMap(e)).toList();
  }

  // 插入物品
  static Future<void> insertItem(ItemModel item) async {
    final db = await database;
    await db.insert('items', item.toMap());
  }

  // 根据盒子ID获取物品
  static Future<List<ItemModel>> getItemsByBoxId(int boxId) async {
    final db = await database;
    final res = await db.query('items', where: 'boxId = ?', whereArgs: [boxId]);
    return res.map((e) => ItemModel.fromMap(e)).toList();
  }

  static Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteBox(int id) async {
    final db = await database;
    await db.delete('boxes', where: 'id = ?', whereArgs: [id]);
    await db.delete('items', where: 'boxId = ?', whereArgs: [id]);
  }

  static Future<void> updateBox(BoxModel box) async {
    final db = await database;
    await db.update('boxes', box.toMap(), where: 'id = ?', whereArgs: [box.id]);
  }

  static Future<void> updateItem(ItemModel item) async {
    final db = await database;
    await db
        .update('items', item.toMap(), where: 'id = ?', whereArgs: [item.id]);
  }

  static Future<void> updateItemPosition(int id, double x, double y) async {
    final db = await database;
    await db.update('items', {'posX': x, 'posY': y},
        where: 'id = ?', whereArgs: [id]);
  }
}
