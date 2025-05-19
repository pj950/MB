import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/box_model.dart';
import '../models/item_model.dart';
import '../models/follow_model.dart';
import '../models/channel_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/checkin_model.dart';
import '../models/level_model.dart';
import '../models/mall_item_model.dart';
import '../models/order_model.dart';
import '../models/moderator_model.dart' as mod;
import '../models/moderator_application_model.dart' as app;
import '../models/moderator_log_model.dart' as log;
import '../models/channel_application_model.dart' as channel_app;
import '../models/channel_application_review_model.dart' as channel_review;
import '../models/content_report_model.dart' as report;
import '../models/content_review_model.dart' as review;
import '../models/search_history_model.dart';
import '../models/search_result_model.dart';
import '../models/notification_model.dart';
import '../models/subscription_model.dart';
import '../models/vote_model.dart' as vote;
import '../models/vote_option_model.dart' as option;
import '../models/vote_record_model.dart' as record;
import '../models/repository_model.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Database> get database async {
    if (_database != null) {
      try {
        // 测试数据库连接是否有效
        await _database!.rawQuery('SELECT 1');
        return _database!;
      } catch (e) {
        print('数据库连接无效，尝试重新初始化...');
        await initializeDatabase();
        return _database!;
      }
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      print('开始初始化数据库...');
      final dbPath = await getDatabasesPath();
      print('数据库基础路径: $dbPath');
      
      final String path = join(dbPath, 'magicbox.db');
      print('完整数据库路径: $path');

      // 检查数据库文件是否存在
      final dbFile = File(path);
      if (await dbFile.exists()) {
        print('数据库文件已存在');
        print('文件大小: ${await dbFile.length()} 字节');
        print('文件权限: ${await dbFile.stat()}');
        
        try {
          // 尝试以读写模式打开文件
          final file = await dbFile.open(mode: FileMode.write);
          await file.close();
          print('数据库文件权限正常，可以读写');
        } catch (e) {
          print('数据库文件权限异常: $e');
          print('尝试删除并重新创建数据库文件...');
          await dbFile.delete();
          print('数据库文件已删除');
        }
      } else {
        print('数据库文件不存在，将创建新文件');
      }

      // 确保数据库目录存在
      try {
        final dbDir = dirname(path);
        print('数据库目录路径: $dbDir');
        if (!await Directory(dbDir).exists()) {
          print('创建数据库目录...');
          await Directory(dbDir).create(recursive: true);
          print('数据库目录创建成功');
        } else {
          print('数据库目录已存在');
          print('目录权限: ${await Directory(dbDir).stat()}');
        }
      } catch (e) {
        print('创建数据库目录失败: $e');
        print('错误堆栈: ${StackTrace.current}');
        rethrow;
      }

      try {
        print('打开数据库连接...');
        final db = await openDatabase(
          path,
          version: 3,
          onCreate: (db, version) async {
            print('开始创建数据库表，版本: $version');
            try {
              await _createTables(db, version);
            } catch (e) {
              print('创建数据库表失败: $e');
              print('错误堆栈: ${StackTrace.current}');
              rethrow;
            }
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            print('开始升级数据库: $oldVersion -> $newVersion');
            try {
              await _onUpgrade(db, oldVersion, newVersion);
            } catch (e) {
              print('升级数据库失败: $e');
              print('错误堆栈: ${StackTrace.current}');
              rethrow;
            }
          },
        );
        print('数据库连接成功');

        // 检查数据库表
        print('检查数据库表...');
        try {
          final tables = await db
              .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
          print('现有数据库表: ${tables.map((t) => t['name']).join(', ')}');

          // 检查用户表结构
          print('检查用户表结构...');
          final userColumns = await db.query('pragma_table_info("users")');
          print('用户表列: ${userColumns.map((c) => c['name']).join(', ')}');

          // 检查测试用户
          print('检查测试用户...');
          final testUser = await db
              .query('users', where: 'username = ?', whereArgs: ['test']);
          if (testUser.isEmpty) {
            print('警告: 测试用户不存在');
          } else {
            print('测试用户存在: ${testUser.first}');
          }
        } catch (e) {
          print('检查数据库表失败: $e');
          print('错误堆栈: ${StackTrace.current}');
          rethrow;
        }

        print('数据库初始化完成');
        return db;
      } catch (e) {
        print('打开数据库连接失败: $e');
        print('错误堆栈: ${StackTrace.current}');
        // 如果数据库文件损坏，尝试删除并重新创建
        if (await dbFile.exists()) {
          print('尝试删除损坏的数据库文件...');
          await dbFile.delete();
          print('数据库文件已删除，将重新创建');
          return _initDatabase(); // 递归调用，重新初始化
        }
        rethrow;
      }
    } catch (e) {
      print('数据库初始化失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('数据库升级: $oldVersion -> $newVersion');
    if (oldVersion < 2) {
      // 添加新字段
      await db.execute(
          'ALTER TABLE users ADD COLUMN password TEXT NOT NULL DEFAULT ""');
      await db.execute(
          'ALTER TABLE users ADD COLUMN createdAt TEXT NOT NULL DEFAULT ""');
      await db.execute(
          'ALTER TABLE users ADD COLUMN updatedAt TEXT NOT NULL DEFAULT ""');
    }

    if (oldVersion < 3) {
      // 检查 boxes 表是否存在
      final tables = await db.query('sqlite_master',
          where: 'type = ? AND name = ?', whereArgs: ['table', 'boxes']);

      if (tables.isEmpty) {
        print('boxes 表不存在，创建新表...');
        await db.execute('''
          CREATE TABLE boxes (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            image_path TEXT,
            type TEXT NOT NULL,
            isPublic INTEGER NOT NULL DEFAULT 0,
            isPinned INTEGER NOT NULL DEFAULT 0,
            repository_id TEXT,
            creator_id TEXT,
            item_count INTEGER NOT NULL DEFAULT 0,
            has_expired_items INTEGER NOT NULL DEFAULT 0,
            order_index INTEGER NOT NULL DEFAULT 0,
            theme_color TEXT,
            access_level TEXT,
            password TEXT,
            allowed_user_ids TEXT,
            share_settings TEXT,
            advanced_properties TEXT,
            tags TEXT,
            view_count INTEGER NOT NULL DEFAULT 0,
            copy_count INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        print('boxes 表创建完成');
      } else {
        print('boxes 表已存在，重新创建...');
        await db.execute('DROP TABLE IF EXISTS boxes');
        await db.execute('''
          CREATE TABLE boxes (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            description TEXT,
            image_path TEXT,
            type TEXT NOT NULL,
            isPublic INTEGER NOT NULL DEFAULT 0,
            isPinned INTEGER NOT NULL DEFAULT 0,
            repository_id TEXT,
            creator_id TEXT,
            item_count INTEGER NOT NULL DEFAULT 0,
            has_expired_items INTEGER NOT NULL DEFAULT 0,
            order_index INTEGER NOT NULL DEFAULT 0,
            theme_color TEXT,
            access_level TEXT,
            password TEXT,
            allowed_user_ids TEXT,
            share_settings TEXT,
            advanced_properties TEXT,
            tags TEXT,
            view_count INTEGER NOT NULL DEFAULT 0,
            copy_count INTEGER NOT NULL DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');
        print('boxes 表重新创建完成');
      }
    }

    // 检查测试用户是否存在
    final List<Map<String, dynamic>> testUser = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: ['test'],
    );

    if (testUser.isEmpty) {
      print('创建测试用户...');
      final hashedPassword = hashPassword('123456');
      await db.insert('users', {
        'id': '1',
        'username': 'test',
        'email': 'test@example.com',
        'password': hashedPassword,
        'type': 'UserType.PERSONAL',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isactive': 1,
      });
      print('测试用户创建完成');

      // 为测试用户创建默认的免费订阅
      print('为测试用户创建默认免费订阅...');
      final subscription = SubscriptionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '1',
        type: SubscriptionType.FREE,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 36500)), // 100年有效期
        isActive: true,
        maxRepositories: 3,
        maxBoxesPerRepository: 10,
        hasAdvancedProperties: false,
        hasWatermarkProtection: false,
        maxFamilyMembers: 1,
        created_at: DateTime.now(),
        updated_at: DateTime.now(),
      );

      await db.insert('subscriptions', subscription.toMap());
      print('测试用户默认免费订阅创建完成');
    }
  }

  Future<void> _createTables(Database db, int version) async {
    print('开始创建数据库表...');
    print('数据库版本: $version');

    // 用户表
    print('创建用户表...');
    try {
      await db.execute('''
        CREATE TABLE users (
          id TEXT PRIMARY KEY,
          username TEXT NOT NULL UNIQUE,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          phoneNumber TEXT,
          type TEXT NOT NULL,
          level INTEGER NOT NULL DEFAULT 1,
          experience INTEGER NOT NULL DEFAULT 0,
          points INTEGER NOT NULL DEFAULT 0,
          coins INTEGER NOT NULL DEFAULT 0,
          avatar TEXT,
          bio TEXT,
          isactive INTEGER NOT NULL DEFAULT 1,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
      print('用户表创建完成');
    } catch (e) {
      print('创建用户表失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    // 仓库表
    print('创建仓库表...');
    try {
      await db.execute('''
        CREATE TABLE repositories (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          isPublic INTEGER NOT NULL DEFAULT 0,
          isActive INTEGER NOT NULL DEFAULT 1,
          boxIds TEXT,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      print('仓库表创建完成');
    } catch (e) {
      print('创建仓库表失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    // 盒子表
    print('创建盒子表...');
    try {
      await db.execute('''
        CREATE TABLE boxes (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          image_path TEXT,
          type TEXT NOT NULL,
          isPublic INTEGER NOT NULL DEFAULT 0,
          isPinned INTEGER NOT NULL DEFAULT 0,
          repository_id TEXT,
          creator_id TEXT,
          item_count INTEGER NOT NULL DEFAULT 0,
          has_expired_items INTEGER NOT NULL DEFAULT 0,
          order_index INTEGER NOT NULL DEFAULT 0,
          theme_color TEXT,
          access_level TEXT,
          password TEXT,
          allowed_user_ids TEXT,
          share_settings TEXT,
          advanced_properties TEXT,
          tags TEXT,
          view_count INTEGER NOT NULL DEFAULT 0,
          copy_count INTEGER NOT NULL DEFAULT 0,
          createdAt TEXT NOT NULL,
          updatedAt TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      print('盒子表创建完成');
    } catch (e) {
      print('创建盒子表失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    // 物品表
    print('创建物品表...');
    try {
      await db.execute('''
        CREATE TABLE items (
          id TEXT PRIMARY KEY,
          box_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          image_path TEXT,
          note TEXT,
          type TEXT NOT NULL,
          status TEXT NOT NULL,
          priority TEXT,
          due_date TEXT,
          content TEXT,
          tags TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          expiry_date TEXT,
          pos_x REAL NOT NULL DEFAULT 0.0,
          pos_y REAL NOT NULL DEFAULT 0.0,
          scale REAL NOT NULL DEFAULT 1.0,
          watermark_text TEXT,
          isPublic INTEGER NOT NULL DEFAULT 0,
          share_settings TEXT,
          advanced_properties TEXT,
          isfavorite INTEGER NOT NULL DEFAULT 0,
          view_count INTEGER NOT NULL DEFAULT 0,
          copy_count INTEGER NOT NULL DEFAULT 0,
          image_urls TEXT,
          brand TEXT,
          model TEXT,
          serial_number TEXT,
          color TEXT,
          size TEXT,
          weight REAL,
          purchase_price REAL,
          current_price REAL,
          purchase_date TEXT,
          condition_rating INTEGER,
          FOREIGN KEY (box_id) REFERENCES boxes (id) ON DELETE CASCADE
        )
      ''');
      print('物品表创建完成');
    } catch (e) {
      print('创建物品表失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    // 帖子表
    print('创建帖子表...');
    try {
      await db.execute('''
        CREATE TABLE posts (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          type TEXT NOT NULL,
          status TEXT NOT NULL,
          view_count INTEGER NOT NULL DEFAULT 0,
          like_count INTEGER NOT NULL DEFAULT 0,
          comment_count INTEGER NOT NULL DEFAULT 0,
          share_count INTEGER NOT NULL DEFAULT 0,
          tags TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      print('帖子表创建完成');
    } catch (e) {
      print('创建帖子表失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    // 频道表
    print('创建频道表...');
    try {
      await db.execute('''
        CREATE TABLE channels (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          owner_id TEXT NOT NULL,
          type TEXT NOT NULL,
          status TEXT NOT NULL,
          member_count INTEGER NOT NULL DEFAULT 0,
          post_count INTEGER NOT NULL DEFAULT 0,
          is_private INTEGER NOT NULL DEFAULT 0,
          password TEXT,
          allowed_user_ids TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (owner_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      print('频道表创建完成');
    } catch (e) {
      print('创建频道表失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    // 等级表
    print('创建等级表...');
    try {
      await db.execute('''
        CREATE TABLE levels (
          level INTEGER PRIMARY KEY,
          required_exp INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          privileges TEXT NOT NULL,
          points_multiplier REAL NOT NULL DEFAULT 1.0,
          coins_multiplier REAL NOT NULL DEFAULT 1.0
        )
      ''');
      print('等级表创建完成');
    } catch (e) {
      print('创建等级表失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    // 订阅表
    print('创建订阅表...');
    try {
      await db.execute('''
        CREATE TABLE subscriptions (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          type TEXT NOT NULL,
          start_date TEXT NOT NULL,
          end_date TEXT NOT NULL,
          is_active INTEGER NOT NULL DEFAULT 1,
          payment_id TEXT,
          payment_status TEXT,
          payment_amount REAL,
          payment_currency TEXT,
          payment_date TEXT,
          auto_renew INTEGER NOT NULL DEFAULT 0,
          trial_period INTEGER NOT NULL DEFAULT 0,
          max_repositories INTEGER NOT NULL DEFAULT 3,
          max_boxes_per_repository INTEGER NOT NULL DEFAULT 10,
          has_advanced_properties INTEGER NOT NULL DEFAULT 0,
          has_watermark_protection INTEGER NOT NULL DEFAULT 0,
          max_family_members INTEGER NOT NULL DEFAULT 1,
          family_member_ids TEXT,
          expiry_text TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
      print('订阅表创建完成');
    } catch (e) {
      print('创建订阅表失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    // 支付记录表
    print('创建支付记录表...');
    try {
      await db.execute('''
        CREATE TABLE payment_records (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          subscription_id TEXT NOT NULL,
          amount REAL NOT NULL,
          currency TEXT NOT NULL,
          status TEXT NOT NULL,
          payment_method TEXT NOT NULL,
          transaction_id TEXT,
          payment_date TEXT NOT NULL,
          description TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
          FOREIGN KEY (subscription_id) REFERENCES subscriptions (id) ON DELETE CASCADE
        )
      ''');
      print('支付记录表创建完成');
    } catch (e) {
      print('创建支付记录表失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    // 检查用户表是否创建成功
    try {
      final userTable = await db.query('sqlite_master',
          where: 'type = ? AND name = ?', whereArgs: ['table', 'users']);
      if (userTable.isEmpty) {
        throw Exception('用户表创建失败');
      }
      print('用户表创建验证成功');
    } catch (e) {
      print('验证用户表创建失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    // 创建测试用户
    print('创建测试用户...');
    try {
      final hashedPassword = hashPassword('123456');
      final testUser = {
        'id': '1',
        'username': 'test',
        'email': 'test@example.com',
        'password': hashedPassword,
        'type': 'UserType.PERSONAL',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'isActive': 1,
      };
      print('测试用户数据: $testUser');

      await db.insert('users', testUser);
      print('测试用户创建完成');

      // 验证测试用户是否创建成功
      final testUserCheck =
          await db.query('users', where: 'username = ?', whereArgs: ['test']);
      if (testUserCheck.isEmpty) {
        throw Exception('测试用户创建失败');
      }
      print('测试用户创建验证成功');
    } catch (e) {
      print('创建测试用户失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    // 初始化等级系统
    print('初始化等级系统...');
    try {
      await _initLevels(db);
      print('等级系统初始化完成');
    } catch (e) {
      print('初始化等级系统失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }

    print('所有数据库表创建完成');
  }

  Future<void> _initLevels(Database db) async {
    final levels = [
      LevelModel(
        level: 1,
        requiredExp: 0,
        title: '新手',
        description: '欢迎加入社区！',
        privileges: ['基础发帖', '基础评论'],
        pointsMultiplier: 1.0,
        coinsMultiplier: 1.0,
      ),
      LevelModel(
        level: 2,
        requiredExp: 100,
        title: '活跃用户',
        description: '开始活跃起来了！',
        privileges: ['创建投票', '上传图片'],
        pointsMultiplier: 1.2,
        coinsMultiplier: 1.2,
      ),
      LevelModel(
        level: 3,
        requiredExp: 500,
        title: '资深用户',
        description: '社区的中坚力量！',
        privileges: ['创建频道', '发起活动'],
        pointsMultiplier: 1.5,
        coinsMultiplier: 1.5,
      ),
      LevelModel(
        level: 4,
        requiredExp: 2000,
        title: '社区精英',
        description: '社区的重要贡献者！',
        privileges: ['置顶帖子', '管理评论'],
        pointsMultiplier: 2.0,
        coinsMultiplier: 2.0,
      ),
      LevelModel(
        level: 5,
        requiredExp: 5000,
        title: '社区领袖',
        description: '社区的核心力量！',
        privileges: ['管理频道', '审核内容'],
        pointsMultiplier: 3.0,
        coinsMultiplier: 3.0,
      ),
    ];

    for (final level in levels) {
      await db.insert('levels', level.toMap());
    }
  }

  Future<void> _initMallItems(Database db) async {
    final items = [
      {
        'name': '普通盲盒',
        'description': '随机获得一个普通物品',
        'image_url': 'assets/images/blind_box_normal.png',
        'price': 100.0,
        'stock': 1000,
        'type': 'blind_box',
        'currency': 'coins',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': '高级盲盒',
        'description': '随机获得一个高级物品',
        'image_url': 'assets/images/blind_box_premium.png',
        'price': 500.0,
        'stock': 500,
        'type': 'blind_box',
        'currency': 'coins',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': '积分兑换券',
        'description': '兑换100积分',
        'image_url': 'assets/images/points_voucher.png',
        'price': 1000.0,
        'stock': 100,
        'type': 'points_exchange',
        'currency': 'coins',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': '金币兑换券',
        'description': '兑换100金币',
        'image_url': 'assets/images/coins_voucher.png',
        'price': 1000.0,
        'stock': 100,
        'type': 'coins_exchange',
        'currency': 'points',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      {
        'name': '限量版手办',
        'description': '精美手办，限量发售',
        'image_url': 'assets/images/figure.png',
        'price': 299.0,
        'stock': 50,
        'type': 'physical',
        'currency': 'rmb',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
    ];

    for (final item in items) {
      await db.insert('mall_items', item);
    }
  }

  // 用户相关操作
  Future<int> insertUser(UserModel user) async {
    try {
      print('开始插入用户到数据库: ${user.username}');
      final db = await database;

      // 检查必填字段
      if (user.username.isEmpty) {
        throw Exception('用户名不能为空');
      }
      if (user.email?.isEmpty ?? true) {
        throw Exception('邮箱不能为空');
      }
      if (user.password.isEmpty) {
        throw Exception('密码不能为空');
      }

      // 检查数据库连接

      // 准备数据
      final values = {
        'username': user.username,
        'email': user.email,
        'password': user.password,
        'type': user.type.toString(),
        'avatar_url': user.avatarUrl,
        'createdAt': user.createdAt.toIso8601String(),
        'updatedAt': user.updatedAt.toIso8601String(),
        'phone_number': user.phoneNumber,
        'nick_name': user.nickName,
        'real_name': user.realName,
        'points': user.points,
        'coins': user.coins,
        'level': user.level,
        'experience': user.experience,
        'isActive': user.isActive ? 1 : 0,
      };
      print('准备插入的用户数据: $values');

      // 检查表是否存在
      final tables = await db.query('sqlite_master',
          where: 'type = ? AND name = ?', whereArgs: ['table', 'users']);
      if (tables.isEmpty) {
        throw Exception('users表不存在，请检查数据库初始化');
      }

      final id = await db.insert('users', values);
      print('用户插入成功，ID: $id');
      return id;
    } catch (e) {
      print('插入用户失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<UserModel?> getUser(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }

    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserById(String id) async {
    return getUser(id);
  }

  Future<UserModel?> getUserByUsername(String username) async {
    try {
      print('开始查询用户: $username');
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
      );
      print('查询结果: ${maps.length} 条记录');

      if (maps.isEmpty) {
        print('未找到用户: $username');
        return null;
      }

      print('找到用户: ${maps.first}');
      return UserModel.fromMap(maps.first);
    } catch (e) {
      print('查询用户失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
  }

  // 盒子相关操作
  Future<int> insertBox(BoxModel box) async {
    try {
      print('开始插入盒子到数据库: ${box.name}');
      final db = await database;

      // 检查必填字段
      if (box.name.isEmpty) {
        throw Exception('盒子名称不能为空');
      }

      // 检查数据库连接

      // 准备数据
      final values = {
        'user_id': box.userId,
        'name': box.name,
        'description': box.description,
        'type': box.type.toString(),
        'isPublic': box.isPublic ? 1 : 0,
        'repository_id': box.repositoryId,
        'creator_id': box.creatorId,
        'item_count': box.itemCount,
        'has_expired_items': box.hasExpiredItems ? 1 : 0,
        'order_index': box.orderIndex,
        'createdAt': box.createdAt.toIso8601String(),
        'updatedAt': box.updatedAt.toIso8601String(),
        'theme_color': box.themeColor,
        'access_level': box.accessLevel.toString(),
        'password': box.password,
        'allowed_user_ids': box.allowedUserIds.join(','),
        'share_settings':
            box.shareSettings != null ? box.shareSettings.toString() : null,
        'isPinned': box.isPinned ? 1 : 0,
        'tags': box.tags.join(','),
      };

      print('准备插入的数据: $values');

      // 检查表是否存在
      final tables = await db.query('sqlite_master',
          where: 'type = ? AND name = ?', whereArgs: ['table', 'boxes']);
      if (tables.isEmpty) {
        throw Exception('boxes表不存在，请检查数据库初始化');
      }

      final id = await db.insert('boxes', values);
      print('盒子插入成功，ID: $id');
      return id;
    } catch (e) {
      print('插入盒子失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<BoxModel>> getBoxesByOwner(String ownerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'boxes',
      where: 'user_id = ?',
      whereArgs: [ownerId],
    );
    return List.generate(maps.length, (i) => BoxModel.fromMap(maps[i]));
  }

  Future<BoxModel?> getBox(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'boxes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return BoxModel.fromMap(maps.first);
  }

  Future<int> getBoxCount(int ownerId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM boxes WHERE ownerId = ?',
      [ownerId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 物品相关操作
  Future<int> insertItem(ItemModel item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<ItemModel>> getItemsByBox(String boxId) async {
    final db = await database;
    final result =
        await db.query('items', where: 'boxId = ?', whereArgs: [boxId]);
    return result.map((e) => ItemModel.fromMap(e)).toList();
  }

  Future<ItemModel?> getItem(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ItemModel.fromMap(maps.first);
  }

  // 更新操作
  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> updateBox(BoxModel box) async {
    final db = await database;
    return await db.update(
      'boxes',
      box.toMap(),
      where: 'id = ?',
      whereArgs: [box.id],
    );
  }

  Future<int> updateItem(ItemModel item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // 删除操作
  Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteBox(String id) async {
    final db = await database;
    return await db.delete(
      'boxes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 关注相关方法
  Future<void> createFollow(FollowModel follow) async {
    final db = await database;
    await db.insert(
      'follows',
      follow.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteFollow(int followerId, int followingId) async {
    final db = await database;
    await db.delete(
      'follows',
      where: 'follower_id = ? AND following_id = ?',
      whereArgs: [followerId, followingId],
    );
  }

  Future<List<FollowModel>> getFollowers(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'follows',
      where: 'following_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => FollowModel.fromMap(maps[i]));
  }

  Future<List<FollowModel>> getFollowing(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'follows',
      where: 'follower_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => FollowModel.fromMap(maps[i]));
  }

  Future<int> getFollowerCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM follows WHERE following_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getFollowingCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM follows WHERE follower_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> isFollowing(String followerId, String followingId) async {
    final db = await database;
    final result = await db.query(
      'follows',
      where: 'follower_id = ? AND following_id = ?',
      whereArgs: [followerId, followingId],
    );
    return result.isNotEmpty;
  }

  // 频道相关方法
  Future<int> insertChannel(ChannelModel channel) async {
    final db = await database;
    return await db.insert('channels', channel.toMap());
  }

  Future<List<ChannelModel>> getChannels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'channels',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'postCount DESC',
    );
    return List.generate(maps.length, (i) => ChannelModel.fromMap(maps[i]));
  }

  Future<ChannelModel?> getChannel(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'channels',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ChannelModel.fromMap(maps.first);
  }

  Future<int> updateChannel(ChannelModel channel) async {
    final db = await database;
    return await db.update(
      'channels',
      channel.toMap(),
      where: 'id = ?',
      whereArgs: [channel.id],
    );
  }

  Future<int> deleteChannel(int id) async {
    final db = await database;
    return await db.delete(
      'channels',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 帖子相关方法
  Future<int> insertPost(PostModel post) async {
    final db = await database;
    final postId = await db.insert('posts', post.toMap());

    // 更新频道帖子数
    await db.rawUpdate(
      'UPDATE channels SET postCount = postCount + 1 WHERE id = ?',
      [post.channelId],
    );

    // 添加标签
    if (post.tags != null) {
      for (final tagName in post.tags!) {
        final tagId = await _getOrCreateTag(tagName);
        await db.insert('post_tags', {
          'postId': postId,
          'tagId': tagId,
        });
      }
    }

    return postId;
  }

  Future<List<PostModel>> getPostsByChannel(int channelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'channelId = ? AND isActive = ?',
      whereArgs: [channelId, 1],
      orderBy: 'isPinned DESC, isTop DESC, createdAt DESC',
    );
    return List.generate(maps.length, (i) => PostModel.fromMap(maps[i]));
  }

  Future<PostModel?> getPost(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PostModel.fromMap(maps.first);
  }

  Future<int> updatePost(PostModel post) async {
    final db = await database;
    return await db.update(
      'posts',
      post.toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
    );
  }

  Future<int> deletePost(int id) async {
    final db = await database;
    final post = await getPost(id);
    if (post != null) {
      // 更新频道帖子数
      await db.rawUpdate(
        'UPDATE channels SET postCount = postCount - 1 WHERE id = ?',
        [post.channelId],
      );
    }
    return await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 评论相关方法
  Future<int> insertComment(CommentModel comment) async {
    final db = await database;
    final commentId = await db.insert('comments', comment.toMap());

    // 更新帖子评论数
    await db.rawUpdate(
      'UPDATE posts SET commentCount = commentCount + 1 WHERE id = ?',
      [comment.postId],
    );

    return commentId;
  }

  Future<List<CommentModel>> getCommentsByPost(int postId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'postId = ? AND isActive = ?',
      whereArgs: [postId, 1],
      orderBy: 'createdAt ASC',
    );
    return List.generate(maps.length, (i) => CommentModel.fromMap(maps[i]));
  }

  Future<int> deleteComment(int id) async {
    final db = await database;
    final comment = await getComment(id);
    if (comment != null) {
      // 更新帖子评论数
      await db.rawUpdate(
        'UPDATE posts SET commentCount = commentCount - 1 WHERE id = ?',
        [comment.postId],
      );
    }
    return await db.delete(
      'comments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<CommentModel?> getComment(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'comments',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CommentModel.fromMap(maps.first);
  }

  // 点赞相关方法
  Future<void> likePost(int userId, int postId) async {
    final db = await database;
    await db.insert('likes', {
      'userId': userId,
      'postId': postId,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await db.rawUpdate(
      'UPDATE posts SET likeCount = likeCount + 1 WHERE id = ?',
      [postId],
    );
  }

  Future<void> unlikePost(int userId, int postId) async {
    final db = await database;
    await db.delete(
      'likes',
      where: 'userId = ? AND postId = ?',
      whereArgs: [userId, postId],
    );
    await db.rawUpdate(
      'UPDATE posts SET likeCount = likeCount - 1 WHERE id = ?',
      [postId],
    );
  }

  Future<void> likeComment(int userId, int commentId) async {
    final db = await database;
    await db.insert('likes', {
      'userId': userId,
      'commentId': commentId,
      'createdAt': DateTime.now().toIso8601String(),
    });
    await db.rawUpdate(
      'UPDATE comments SET likeCount = likeCount + 1 WHERE id = ?',
      [commentId],
    );
  }

  Future<void> unlikeComment(int userId, int commentId) async {
    final db = await database;
    await db.delete(
      'likes',
      where: 'userId = ? AND commentId = ?',
      whereArgs: [userId, commentId],
    );
    await db.rawUpdate(
      'UPDATE comments SET likeCount = likeCount - 1 WHERE id = ?',
      [commentId],
    );
  }

  // 标签相关方法
  Future<int> _getOrCreateTag(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isEmpty) {
      return await db.insert('tags', {
        'name': name,
        'postCount': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    return maps.first['id'];
  }

  Future<List<String>> getPopularTags() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'tags',
      orderBy: 'postCount DESC',
      limit: 10,
    );
    return List.generate(maps.length, (i) => maps[i]['name'] as String);
  }

  // 频道成员相关方法
  Future<void> joinChannel(String channelId, String userId) async {
    final db = await database;
    await db.insert('channel_members', {
      'channelId': channelId,
      'userId': userId,
      'role': 'member',
      'joinedAt': DateTime.now().toIso8601String(),
    });
    await db.rawUpdate(
      'UPDATE channels SET memberCount = memberCount + 1 WHERE id = ?',
      [channelId],
    );
  }

  Future<void> leaveChannel(String channelId, String userId) async {
    final db = await database;
    await db.delete(
      'channel_members',
      where: 'channelId = ? AND userId = ?',
      whereArgs: [channelId, userId],
    );
    await db.rawUpdate(
      'UPDATE channels SET memberCount = memberCount - 1 WHERE id = ?',
      [channelId],
    );
  }

  Future<bool> isChannelMember(String channelId, String userId) async {
    final db = await database;
    final result = await db.query(
      'channel_members',
      where: 'channelId = ? AND userId = ?',
      whereArgs: [channelId, userId],
    );
    return result.isNotEmpty;
  }

  Future<String> getChannelMemberRole(String channelId, String userId) async {
    final db = await database;
    final result = await db.query(
      'channel_members',
      where: 'channelId = ? AND userId = ?',
      whereArgs: [channelId, userId],
    );
    if (result.isEmpty) return '';
    return result.first['role'] as String;
  }

  // 签到相关方法
  Future<List<CheckinModel>> getCheckinHistory(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'checkins',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'checkin_date DESC',
    );

    return List.generate(maps.length, (i) {
      return CheckinModel.fromMap(maps[i]);
    });
  }

  Future<void> createCheckin(CheckinModel checkin) async {
    final db = await database;
    await db.insert(
      'checkins',
      checkin.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUserPoints(String userId, int points) async {
    final db = await database;
    await db.update(
      'users',
      {'points': points},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateUserCoins(String userId, int coins) async {
    final db = await database;
    await db.update(
      'users',
      {'coins': coins},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // 等级相关方法
  Future<LevelModel?> getLevel(int level) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'levels',
      where: 'level = ?',
      whereArgs: [level],
    );
    if (maps.isEmpty) return null;
    return LevelModel.fromMap(maps.first);
  }

  Future<LevelModel> getCurrentLevel(int experience) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'levels',
      where: 'required_exp <= ?',
      whereArgs: [experience],
      orderBy: 'level DESC',
      limit: 1,
    );
    return LevelModel.fromMap(maps.first);
  }

  Future<LevelModel?> getNextLevel(int experience) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'levels',
      where: 'required_exp > ?',
      whereArgs: [experience],
      orderBy: 'level ASC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return LevelModel.fromMap(maps.first);
  }

  Future<void> addExperience(String userId, int experience) async {
    final db = await database;
    final user = await getUser(userId);
    if (user == null) return;

    final newExperience = user.experience + experience;
    final currentLevel = await getCurrentLevel(newExperience);
    final nextLevel = await getNextLevel(newExperience);

    await db.update(
      'users',
      {
        'experience': newExperience,
        'level': currentLevel.level,
      },
      where: 'id = ?',
      whereArgs: [userId],
    );

    // 如果升级了，发送通知
    if (nextLevel != null && currentLevel.level > user.level) {
      // TODO: 发送升级通知
    }
  }

  // 商城相关方法
  Future<List<MallItemModel>> getMallItems({
    String? type,
    String? currency,
    bool onlyActive = true,
  }) async {
    final db = await database;
    final whereClause = <String>[];
    final whereArgs = <dynamic>[];

    if (type != null) {
      whereClause.add('type = ?');
      whereArgs.add(type);
    }

    if (currency != null) {
      whereClause.add('currency = ?');
      whereArgs.add(currency);
    }

    if (onlyActive) {
      whereClause.add('isactive = 1');
    }

    final where = whereClause.isEmpty ? null : whereClause.join(' AND ');

    final List<Map<String, dynamic>> maps = await db.query(
      'mall_items',
      where: where,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) => MallItemModel.fromMap(maps[i]));
  }

  Future<MallItemModel?> getMallItem(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mall_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return MallItemModel.fromMap(maps.first);
  }

  Future<int> createOrder(OrderModel order) async {
    final db = await database;
    return await db.insert('orders', order.toMap());
  }

  Future<List<OrderModel>> getUserOrders(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => OrderModel.fromMap(maps[i]));
  }

  Future<OrderModel?> getOrder(String orderNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'order_number = ?',
      whereArgs: [orderNumber],
    );

    if (maps.isEmpty) return null;
    return OrderModel.fromMap(maps.first);
  }

  Future<void> updateOrderStatus(String orderNumber, String status) async {
    final db = await database;
    await db.update(
      'orders',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'order_number = ?',
      whereArgs: [orderNumber],
    );
  }

  Future<void> updateMallItemStock(int itemId, int quantity) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE mall_items
      SET stock = stock - ?,
          updated_at = ?
      WHERE id = ? AND stock >= ?
    ''', [
      quantity,
      DateTime.now().toIso8601String(),
      itemId,
      quantity,
    ]);
  }

  // 版主相关方法
  Future<List<mod.ModeratorModel>> getChannelModerators(int channelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moderators',
      where: 'channel_id = ? AND isactive = 1',
      whereArgs: [channelId],
    );
    return List.generate(
        maps.length, (i) => mod.ModeratorModel.fromMap(maps[i]));
  }

  Future<mod.ModeratorModel?> getModerator(
      String userId, String channelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moderators',
      where: 'user_id = ? AND channel_id = ? AND isactive = 1',
      whereArgs: [userId, channelId],
    );
    if (maps.isEmpty) return null;
    return mod.ModeratorModel.fromMap(maps.first);
  }

  Future<int> createModerator(mod.ModeratorModel moderator) async {
    final db = await database;
    return await db.insert('moderators', moderator.toMap());
  }

  Future<int> updateModerator(mod.ModeratorModel moderator) async {
    final db = await database;
    return await db.update(
      'moderators',
      moderator.toMap(),
      where: 'id = ?',
      whereArgs: [moderator.id],
    );
  }

  Future<int> deactivateModerator(int moderatorId) async {
    final db = await database;
    return await db.update(
      'moderators',
      {'isactive': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [moderatorId],
    );
  }

  // 版主申请相关方法
  Future<List<app.ModeratorApplicationModel>> getModeratorApplications() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moderator_applications',
      orderBy: 'created_at DESC',
    );
    return List.generate(
        maps.length, (i) => app.ModeratorApplicationModel.fromMap(maps[i]));
  }

  Future<int> createModeratorApplication(
      app.ModeratorApplicationModel application) async {
    final db = await database;
    return await db.insert('moderator_applications', application.toMap());
  }

  Future<void> updateModeratorApplicationStatus(int id, String status) async {
    final db = await database;
    await db.update(
      'moderator_applications',
      {
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 版主日志相关方法
  Future<List<log.ModeratorLogModel>> getModeratorLogs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moderator_logs',
      orderBy: 'created_at DESC',
    );
    return List.generate(
        maps.length, (i) => log.ModeratorLogModel.fromMap(maps[i]));
  }

  // 获取频道申请列表
  Future<List<channel_app.ChannelApplicationModel>> getChannelApplications({
    int? userId,
    String? status,
  }) async {
    final db = await database;
    String whereClause = '';
    final List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause = 'WHERE user_id = ?';
      whereArgs.add(userId);
    }

    if (status != null) {
      whereClause = whereClause.isEmpty
          ? 'WHERE status = ?'
          : '$whereClause AND status = ?';
      whereArgs.add(status);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'channel_applications',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return channel_app.ChannelApplicationModel.fromMap(maps[i]);
    });
  }

  // 获取单个频道申请
  Future<channel_app.ChannelApplicationModel?> getChannelApplication(
      int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'channel_applications',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return channel_app.ChannelApplicationModel.fromMap(maps.first);
  }

  // 创建频道申请
  Future<int> createChannelApplication(
      channel_app.ChannelApplicationModel application) async {
    final db = await database;
    return await db.insert('channel_applications', application.toMap());
  }

  // 更新频道申请状态
  Future<void> updateChannelApplicationStatus(
    int id,
    String status, {
    String? rejectReason,
  }) async {
    final db = await database;
    await db.update(
      'channel_applications',
      {
        'status': status,
        'reject_reason': rejectReason,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // 创建频道申请审核记录
  Future<int> createChannelApplicationReview(
    channel_review.ChannelApplicationReviewModel review,
  ) async {
    final db = await database;
    return await db.insert('channel_application_reviews', review.toMap());
  }

  // 获取频道申请审核记录
  Future<List<channel_review.ChannelApplicationReviewModel>>
      getChannelApplicationReviews(
    int applicationId,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'channel_application_reviews',
      where: 'application_id = ?',
      whereArgs: [applicationId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return channel_review.ChannelApplicationReviewModel.fromMap(maps[i]);
    });
  }

  // 内容审核相关方法
  Future<List<report.ContentReportModel>> getContentReports({
    String? status,
    String? targetType,
    int? targetId,
  }) async {
    final db = await database;
    String whereClause = '';
    final List<dynamic> whereArgs = [];

    if (status != null) {
      whereClause = 'WHERE status = ?';
      whereArgs.add(status);
    }

    if (targetType != null) {
      whereClause = whereClause.isEmpty
          ? 'WHERE target_type = ?'
          : '$whereClause AND target_type = ?';
      whereArgs.add(targetType);
    }

    if (targetId != null) {
      whereClause = whereClause.isEmpty
          ? 'WHERE target_id = ?'
          : '$whereClause AND target_id = ?';
      whereArgs.add(targetId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'content_reports',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return List.generate(
        maps.length, (i) => report.ContentReportModel.fromMap(maps[i]));
  }

  Future<report.ContentReportModel?> getContentReport(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'content_reports',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return report.ContentReportModel.fromMap(maps.first);
  }

  Future<int> createContentReport(report.ContentReportModel report) async {
    final db = await database;
    return await db.insert('content_reports', report.toMap());
  }

  Future<void> updateContentReportStatus(
    int id,
    String status, {
    String? reviewResult,
    String? reviewNote,
  }) async {
    final db = await database;
    await db.update(
      'content_reports',
      {
        'status': status,
        'review_result': reviewResult,
        'review_note': reviewNote,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> createContentReview(review.ContentReviewModel review) async {
    final db = await database;
    return await db.insert('content_reviews', review.toMap());
  }

  Future<List<review.ContentReviewModel>> getContentReviews(
      int reportId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'content_reviews',
      where: 'report_id = ?',
      whereArgs: [reportId],
      orderBy: 'created_at DESC',
    );

    return List.generate(
        maps.length, (i) => review.ContentReviewModel.fromMap(maps[i]));
  }

  // 获取所有等级
  Future<List<LevelModel>> getLevels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'levels',
      orderBy: 'level ASC',
    );

    return List.generate(maps.length, (i) {
      return LevelModel.fromMap(maps[i]);
    });
  }

  // 获取用户等级信息
  Future<UserLevelModel?> getUserLevel(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_levels',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;
    return UserLevelModel.fromMap(maps.first);
  }

  // 创建用户等级记录
  Future<void> createUserLevel(UserLevelModel userLevel) async {
    final db = await database;
    await db.insert(
      'user_levels',
      userLevel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 更新用户等级信息
  Future<void> updateUserLevel(UserLevelModel userLevel) async {
    final db = await database;
    await db.update(
      'user_levels',
      userLevel.toMap(),
      where: 'user_id = ?',
      whereArgs: [userLevel.userId],
    );
  }

  // 添加经验值
  Future<void> addUserExp(String userId, int exp) async {
    final userLevel = await getUserLevel(userId);
    if (userLevel == null) return;

    final newExp = userLevel.exp + exp;
    final newTotalExp = userLevel.totalExp + exp;
    final levels = await getLevels();

    // 计算新等级
    int newLevel = userLevel.level;
    for (var level in levels) {
      if (newTotalExp >= level.requiredExp) {
        newLevel = level.level;
      } else {
        break;
      }
    }

    final updatedUserLevel = userLevel.copyWith(
      level: newLevel,
      exp: newExp,
      totalExp: newTotalExp,
      lastExpUpdate: DateTime.now(),
    );

    await updateUserLevel(updatedUserLevel);
  }

  // 获取用户搜索历史
  Future<List<SearchHistoryModel>> getSearchHistory(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'search_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'search_time DESC',
      limit: 10,
    );

    return List.generate(maps.length, (i) {
      return SearchHistoryModel.fromMap(maps[i]);
    });
  }

  // 添加搜索历史
  Future<void> addSearchHistory(SearchHistoryModel history) async {
    final db = await database;
    await db.insert(
      'search_history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 清除搜索历史
  Future<void> clearSearchHistory(String userId) async {
    final db = await database;
    await db.delete(
      'search_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // 搜索帖子
  Future<List<SearchResultModel>> searchPosts(String keyword) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        p.id,
        p.title,
        p.content as description,
        p.image_url,
        p.created_at,
        u.username as author_name,
        c.name as channel_name
      FROM posts p
      LEFT JOIN users u ON p.user_id = u.id
      LEFT JOIN channels c ON p.channel_id = c.id
      WHERE p.title LIKE ? OR p.content LIKE ?
      ORDER BY p.created_at DESC
      LIMIT 20
    ''', ['%$keyword%', '%$keyword%']);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return SearchResultModel(
        id: map['id'].toString(),
        type: SearchResultType.POST,
        title: map['title'] as String,
        description: map['description'] as String,
        imageUrl: map['image_url'] as String?,
        metadata: {
          'author_name': map['author_name'] as String,
          'channel_name': map['channel_name'] as String,
        },
        createdAt: DateTime.parse(map['created_at'] as String),
      );
    });
  }

  // 搜索频道
  Future<List<SearchResultModel>> searchChannels(String keyword) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        c.id,
        c.name as title,
        c.description,
        c.avatar_url as image_url,
        c.created_at,
        u.username as owner_name,
        COUNT(p.id) as post_count
      FROM channels c
      LEFT JOIN users u ON c.owner_id = u.id
      LEFT JOIN posts p ON c.id = p.channel_id
      WHERE c.name LIKE ? OR c.description LIKE ?
      GROUP BY c.id
      ORDER BY c.created_at DESC
      LIMIT 10
    ''', ['%$keyword%', '%$keyword%']);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return SearchResultModel(
        id: map['id'].toString(),
        type: SearchResultType.CHANNEL,
        title: map['title'] as String,
        description: map['description'] as String,
        imageUrl: map['image_url'] as String?,
        metadata: {
          'owner_name': map['owner_name'] as String,
          'post_count': map['post_count'] as int,
        },
        createdAt: DateTime.parse(map['created_at'] as String),
      );
    });
  }

  // 搜索用户
  Future<List<SearchResultModel>> searchUsers(String keyword) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        u.id,
        u.username as title,
        u.bio as description,
        u.avatar_url as image_url,
        u.created_at,
        COUNT(p.id) as post_count,
        COUNT(c.id) as channel_count
      FROM users u
      LEFT JOIN posts p ON u.id = p.user_id
      LEFT JOIN channels c ON u.id = c.owner_id
      WHERE u.username LIKE ? OR u.bio LIKE ?
      GROUP BY u.id
      ORDER BY u.created_at DESC
      LIMIT 10
    ''', ['%$keyword%', '%$keyword%']);

    return List.generate(maps.length, (i) {
      final map = maps[i];
      return SearchResultModel(
        id: map['id'].toString(),
        type: SearchResultType.USER,
        title: map['title'] as String,
        description: map['description'] as String,
        imageUrl: map['image_url'] as String?,
        metadata: {
          'post_count': map['post_count'] as int,
          'channel_count': map['channel_count'] as int,
        },
        createdAt: DateTime.parse(map['created_at'] as String),
      );
    });
  }

  // 通知相关方法
  Future<List<NotificationModel>> getNotifications(String userId,
      {bool onlyUnread = false}) async {
    final db = await database;
    String whereClause = 'user_id = ?';
    final List<dynamic> whereArgs = [userId];

    if (onlyUnread) {
      whereClause += ' AND isread = 0';
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return List.generate(
        maps.length, (i) => NotificationModel.fromMap(maps[i]));
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND isread = 0',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> createNotification(NotificationModel notification) async {
    final db = await database;
    await db.insert(
      'notifications',
      notification.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isread': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final db = await database;
    await db.update(
      'notifications',
      {'isread': 1},
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> deleteAllNotifications(String userId) async {
    final db = await database;
    await db.delete(
      'notifications',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // 订阅相关操作
  Future<void> createSubscriptionTable() async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subscriptions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        payment_id TEXT,
        payment_status TEXT,
        payment_amount REAL,
        payment_currency TEXT,
        payment_date TEXT,
        auto_renew INTEGER NOT NULL DEFAULT 0,
        trial_period INTEGER NOT NULL DEFAULT 0,
        max_repositories INTEGER NOT NULL DEFAULT 3,
        max_boxes_per_repository INTEGER NOT NULL DEFAULT 10,
        has_advanced_properties INTEGER NOT NULL DEFAULT 0,
        has_watermark_protection INTEGER NOT NULL DEFAULT 0,
        max_family_members INTEGER NOT NULL DEFAULT 1,
        family_member_ids TEXT,
        expiry_text TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<SubscriptionModel?> getSubscription(String userId) async {
    try {
      print('开始获取用户 $userId 的订阅信息...');
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'subscriptions',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (maps.isEmpty) {
        print('未找到订阅信息，创建默认免费订阅');
        // 创建默认的免费订阅
        final subscription = SubscriptionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          type: SubscriptionType.FREE,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 36500)), // 100年有效期
          isActive: true,
          maxRepositories: 3,
          maxBoxesPerRepository: 10,
          hasAdvancedProperties: false,
          hasWatermarkProtection: false,
          maxFamilyMembers: 1,
          created_at: DateTime.now(),
          updated_at: DateTime.now(),
        );

        // 保存到数据库
        await createSubscription(subscription);
        print('默认免费订阅创建成功');
        return subscription;
      }

      print('找到订阅信息: ${maps.first}');
      return SubscriptionModel.fromMap(maps.first);
    } catch (e) {
      print('获取订阅信息失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<void> createSubscription(SubscriptionModel subscription) async {
    final db = await database;
    await db.insert(
      'subscriptions',
      subscription.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateSubscription(SubscriptionModel subscription) async {
    final db = await database;
    await db.update(
      'subscriptions',
      subscription.toMap(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
  }

  Future<void> deleteSubscription(String subscriptionId) async {
    final db = await database;
    await db.delete(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [subscriptionId],
    );
  }

  Future<List<SubscriptionModel>> getSubscriptionsByType(
      SubscriptionType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subscriptions',
      where: 'type = ?',
      whereArgs: [type.toString()],
    );

    return List.generate(
        maps.length, (i) => SubscriptionModel.fromMap(maps[i]));
  }

  Future<List<SubscriptionModel>> getExpiredSubscriptions() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'subscriptions',
      where: 'end_date < ? AND isactive = 1',
      whereArgs: [now],
    );

    return List.generate(
        maps.length, (i) => SubscriptionModel.fromMap(maps[i]));
  }

  Future<void> deactivateExpiredSubscriptions() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'subscriptions',
      {'isactive': 0},
      where: 'end_date < ? AND isactive = 1',
      whereArgs: [now],
    );
  }

  Future<List<PostModel>> getPosts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'posts',
      where: 'isActive = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => PostModel.fromMap(maps[i]));
  }

  Future<void> updateComment(CommentModel comment) async {
    final db = await database;
    await db.update(
      'comments',
      comment.toMap(),
      where: 'id = ?',
      whereArgs: [comment.id],
    );
  }

  Future<List<ItemModel>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) {
      return ItemModel.fromMap(maps[i]);
    });
  }

  Future<List<UserModel>> getModerators() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'type IN (?, ?)',
      whereArgs: ['MODERATOR', 'ADMIN'],
    );
    return List.generate(maps.length, (i) => UserModel.fromMap(maps[i]));
  }

  // 获取频道的投票列表
  Future<List<vote.VoteModel>> getChannelVotes(String channelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'votes',
      where: 'channel_id = ?',
      whereArgs: [channelId],
    );
    return List.generate(maps.length, (i) => vote.VoteModel.fromMap(maps[i]));
  }

  // 获取投票详情
  Future<vote.VoteModel?> getVote(String voteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'votes',
      where: 'id = ?',
      whereArgs: [voteId],
    );
    if (maps.isEmpty) return null;
    return vote.VoteModel.fromMap(maps.first);
  }

  // 获取投票选项
  Future<List<option.VoteOptionModel>> getVoteOptions(String voteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vote_options',
      where: 'vote_id = ?',
      whereArgs: [voteId],
    );
    return List.generate(
        maps.length, (i) => option.VoteOptionModel.fromMap(maps[i]));
  }

  // 获取用户的投票记录
  Future<List<record.VoteRecordModel>> getUserVoteRecords(
      String userId, String voteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vote_records',
      where: 'user_id = ? AND vote_id = ?',
      whereArgs: [userId, voteId],
    );
    return List.generate(
        maps.length, (i) => record.VoteRecordModel.fromMap(maps[i]));
  }

  // 创建投票
  Future<String> createVote(vote.VoteModel vote) async {
    final db = await database;
    final id = await db.insert('votes', vote.toMap());
    return id.toString();
  }

  // 创建投票选项
  Future<String> createVoteOption(option.VoteOptionModel option) async {
    final db = await database;
    final id = await db.insert('vote_options', option.toMap());
    return id.toString();
  }

  // 创建投票记录
  Future<String> createVoteRecord(record.VoteRecordModel record) async {
    final db = await database;
    final id = await db.insert('vote_records', record.toMap());
    return id.toString();
  }

  // 更新投票选项计数
  Future<void> updateVoteOptionCount(String optionId, int count) async {
    final db = await database;
    await db.update(
      'vote_options',
      {'count': count},
      where: 'id = ?',
      whereArgs: [optionId],
    );
  }

  // 更新投票总票数
  Future<void> updateVoteTotalVotes(String voteId, int totalVotes) async {
    final db = await database;
    await db.update(
      'votes',
      {'total_votes': totalVotes},
      where: 'id = ?',
      whereArgs: [voteId],
    );
  }

  // 更新投票状态
  Future<void> updateVoteStatus(String voteId, String status) async {
    final db = await database;
    await db.update(
      'votes',
      {'status': status},
      where: 'id = ?',
      whereArgs: [voteId],
    );
  }

  Future<List<Map<String, dynamic>>> _query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );
  }

  // 修改使用 query 的地方
  Future<List<Map<String, dynamic>>> getData(String table) async {
    return await _query(table);
  }

  Future<List<SearchResultModel>> search(
      String keyword, SearchResultType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'search_results',
      where: 'keyword = ? AND type = ?',
      whereArgs: [keyword, type.toString().split('.').last],
    );
    return List.generate(
        maps.length, (i) => SearchResultModel.fromMap(maps[i]));
  }

  Future<void> deleteDatabase() async {
    try {
      print('开始删除数据库...');
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'magic_box.db');
      await databaseFactory.deleteDatabase(path);
      print('数据库删除成功');
    } catch (e) {
      print('删除数据库失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<RepositoryModel>> getRepositoriesByOwner(String ownerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'repositories',
      where: 'user_id = ?',
      whereArgs: [ownerId],
    );
    return List.generate(maps.length, (i) => RepositoryModel.fromMap(maps[i]));
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final db = await database;
      return await db.insert(table, data);
    } catch (e) {
      if (e.toString().contains('SQLITE_READONLY_DBMOVED')) {
        print('检测到数据库只读错误，尝试重新初始化...');
        await initializeDatabase();
        final db = await database;
        return await db.insert(table, data);
      }
      rethrow;
    }
  }

  Future<void> reinitializeDatabase() async {
    try {
      print('开始重新初始化数据库...');

      // 关闭现有数据库连接
      if (_database != null) {
        print('关闭现有数据库连接...');
        await _database!.close();
        _database = null;
        print('数据库连接已关闭');
      }

      // 删除现有数据库文件
      final String path = join(await getDatabasesPath(), 'magicbox.db');
      print('数据库文件路径: $path');
      final dbFile = File(path);
      if (await dbFile.exists()) {
        print('删除现有数据库文件...');
        await dbFile.delete();
        print('数据库文件删除成功');
      } else {
        print('数据库文件不存在，无需删除');
      }

      // 重新初始化数据库
      print('开始重新初始化数据库...');
      _database = await _initDatabase();
      print('数据库重新初始化完成');
    } catch (e) {
      print('重新初始化数据库失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql,
      [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> rawUpdate(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  Future<int> rawInsert(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawInsert(sql, arguments);
  }

  Future<int> rawDelete(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawDelete(sql, arguments);
  }

  Future<bool> isDatabaseOpen() async {
    try {
      if (_database == null) return false;
      // 尝试执行一个简单的查询来检查数据库连接
      await _database!.rawQuery('SELECT 1');
      return true;
    } catch (e) {
      print('检查数据库连接状态失败: $e');
      return false;
    }
  }

  Future<void> initializeDatabase() async {
    print('开始重新初始化数据库...');
    try {
      if (_database != null) {
        await _database!.close();
        _database = null;
      }
      
      // 获取数据库文件路径
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'magicbox.db');
      
      // 检查数据库文件是否存在
      final dbFile = File(path);
      if (await dbFile.exists()) {
        print('删除旧的数据库文件...');
        await dbFile.delete();
      }
      
      print('创建新的数据库连接...');
      _database = await _initDatabase();
      print('数据库重新初始化完成');
    } catch (e) {
      print('重新初始化数据库失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      rethrow;
    }
  }

  Future<int> insertBox2(BoxModel box) async {
    try {
      print('开始插入盒子数据...');
      final db = await database;
      
      // 检查数据库连接状态
      if (!await isDatabaseOpen()) {
        print('数据库未打开，尝试重新初始化');
        await initializeDatabase();
        return await insertBox(box); // 递归调用
      }

      print('插入盒子数据: ${box.toMap()}');
      final id = await db.insert('boxes', box.toMap());
      print('盒子数据插入成功，ID: $id');
      return id;
    } catch (e) {
      print('插入盒子数据失败: $e');
      print('错误堆栈: ${StackTrace.current}');
      
      // 如果是数据库只读错误，尝试重新初始化数据库
      if (e.toString().contains('SQLITE_READONLY_DBMOVED')) {
        print('检测到数据库只读错误，尝试重新初始化数据库');
        await initializeDatabase();
        return await insertBox(box); // 递归调用
      }
      
      rethrow;
    }
  }
}
