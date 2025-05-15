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
import '../models/moderator_model.dart';
import '../models/moderator_application_model.dart';
import '../models/moderator_log_model.dart';
import '../models/channel_application_model.dart';
import '../models/channel_application_review_model.dart';
import '../models/content_report_model.dart';
import '../models/content_review_model.dart';
import '../models/search_history_model.dart';
import '../models/search_result_model.dart';
import '../models/notification_model.dart';
import '../models/subscription_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'magicbox.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // 用户表
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL UNIQUE,
        phoneNumber TEXT,
        avatarUrl TEXT,
        nickName TEXT,
        realName TEXT,
        type TEXT NOT NULL,
        points INTEGER NOT NULL DEFAULT 0,
        coins INTEGER NOT NULL DEFAULT 0,
        level INTEGER NOT NULL DEFAULT 1,
        experience INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // 盒子表
    await db.execute('''
      CREATE TABLE boxes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        coverImage TEXT NOT NULL,
        themeColor TEXT NOT NULL,
        type TEXT NOT NULL,
        isPublic INTEGER NOT NULL DEFAULT 0,
        ownerId INTEGER NOT NULL,
        parentBoxId INTEGER,
        itemCount INTEGER NOT NULL DEFAULT 0,
        hasExpiredItems INTEGER NOT NULL DEFAULT 0,
        sortOrder INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (ownerId) REFERENCES users (id),
        FOREIGN KEY (parentBoxId) REFERENCES boxes (id)
      )
    ''');

    // 物品表
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        boxId INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        imageUrls TEXT,
        purchaseDate TEXT,
        purchasePrice REAL,
        currentPrice REAL,
        brand TEXT,
        model TEXT,
        serialNumber TEXT,
        qrCode TEXT,
        nfcTag TEXT,
        color TEXT,
        size TEXT,
        weight REAL,
        conditionRating INTEGER,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        sortOrder INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (boxId) REFERENCES boxes (id)
      )
    ''');

    // 关注表
    await db.execute('''
      CREATE TABLE follows (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        follower_id INTEGER NOT NULL,
        following_id INTEGER NOT NULL,
        FOREIGN KEY (follower_id) REFERENCES users (id),
        FOREIGN KEY (following_id) REFERENCES users (id)
      )
    ''');

    // 搜索历史表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS search_history (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        keyword TEXT NOT NULL,
        search_time TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 频道表
    await db.execute('''
      CREATE TABLE channels (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        coverImage TEXT NOT NULL,
        themeColor TEXT NOT NULL,
        ownerId INTEGER NOT NULL,
        moderatorId INTEGER NOT NULL,
        postCount INTEGER NOT NULL DEFAULT 0,
        memberCount INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (ownerId) REFERENCES users (id),
        FOREIGN KEY (moderatorId) REFERENCES users (id)
      )
    ''');

    // 帖子表
    await db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        channelId INTEGER NOT NULL,
        authorId INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        imageUrls TEXT,
        audioUrl TEXT,
        videoUrl TEXT,
        boxId INTEGER,
        tags TEXT,
        likeCount INTEGER NOT NULL DEFAULT 0,
        commentCount INTEGER NOT NULL DEFAULT 0,
        viewCount INTEGER NOT NULL DEFAULT 0,
        isPinned INTEGER NOT NULL DEFAULT 0,
        isTop INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (channelId) REFERENCES channels (id),
        FOREIGN KEY (authorId) REFERENCES users (id),
        FOREIGN KEY (boxId) REFERENCES boxes (id)
      )
    ''');

    // 评论表
    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        postId INTEGER NOT NULL,
        authorId INTEGER NOT NULL,
        content TEXT NOT NULL,
        parentId INTEGER,
        likeCount INTEGER NOT NULL DEFAULT 0,
        isActive INTEGER NOT NULL DEFAULT 1,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (postId) REFERENCES posts (id),
        FOREIGN KEY (authorId) REFERENCES users (id),
        FOREIGN KEY (parentId) REFERENCES comments (id)
      )
    ''');

    // 点赞表
    await db.execute('''
      CREATE TABLE likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        postId INTEGER,
        commentId INTEGER,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES users (id),
        FOREIGN KEY (postId) REFERENCES posts (id),
        FOREIGN KEY (commentId) REFERENCES comments (id)
      )
    ''');

    // 频道成员表
    await db.execute('''
      CREATE TABLE channel_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        channelId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        role TEXT NOT NULL,
        joinedAt TEXT NOT NULL,
        FOREIGN KEY (channelId) REFERENCES channels (id),
        FOREIGN KEY (userId) REFERENCES users (id)
      )
    ''');

    // 标签表
    await db.execute('''
      CREATE TABLE tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        postCount INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // 帖子标签关联表
    await db.execute('''
      CREATE TABLE post_tags (
        postId INTEGER NOT NULL,
        tagId INTEGER NOT NULL,
        PRIMARY KEY (postId, tagId),
        FOREIGN KEY (postId) REFERENCES posts (id),
        FOREIGN KEY (tagId) REFERENCES tags (id)
      )
    ''');

    // 签到表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS checkins (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        checkin_date TEXT NOT NULL,
        consecutive_days INTEGER NOT NULL,
        points_earned INTEGER NOT NULL,
        coins_earned INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 等级表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS levels (
        level INTEGER PRIMARY KEY,
        required_exp INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        privileges TEXT NOT NULL
      )
    ''');

    // 用户等级表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_levels (
        user_id TEXT PRIMARY KEY,
        level INTEGER NOT NULL,
        exp INTEGER NOT NULL,
        total_exp INTEGER NOT NULL,
        last_exp_update TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (level) REFERENCES levels (level)
      )
    ''');

    // 商城商品表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mall_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        image_url TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        type TEXT NOT NULL,
        currency TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 订单表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        order_number TEXT NOT NULL,
        amount REAL NOT NULL,
        currency TEXT NOT NULL,
        status TEXT NOT NULL,
        shipping_address TEXT,
        tracking_number TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (item_id) REFERENCES mall_items (id)
      )
    ''');

    // 版主表
    await db.execute('''
      CREATE TABLE moderators (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        channel_id INTEGER NOT NULL,
        role TEXT NOT NULL,
        permissions TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (channel_id) REFERENCES channels (id)
      )
    ''');

    // 版主申请表
    await db.execute('''
      CREATE TABLE moderator_applications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        channel_id INTEGER NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL,
        reject_reason TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (channel_id) REFERENCES channels (id)
      )
    ''');

    // 版主操作日志表
    await db.execute('''
      CREATE TABLE moderator_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        moderator_id INTEGER NOT NULL,
        channel_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        target_type TEXT NOT NULL,
        target_id INTEGER NOT NULL,
        reason TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (moderator_id) REFERENCES moderators (id),
        FOREIGN KEY (channel_id) REFERENCES channels (id)
      )
    ''');

    // 创建频道申请表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS channel_applications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        reject_reason TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 创建频道申请审核记录表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS channel_application_reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        application_id INTEGER NOT NULL,
        reviewer_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        reason TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (application_id) REFERENCES channel_applications (id),
        FOREIGN KEY (reviewer_id) REFERENCES users (id)
      )
    ''');

    // 内容举报表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS content_reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reporter_id INTEGER NOT NULL,
        target_type TEXT NOT NULL,
        target_id INTEGER NOT NULL,
        reason TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        review_result TEXT,
        review_note TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (reporter_id) REFERENCES users (id)
      )
    ''');

    // 内容审核记录表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS content_reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        report_id INTEGER NOT NULL,
        reviewer_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (report_id) REFERENCES content_reports (id),
        FOREIGN KEY (reviewer_id) REFERENCES users (id)
      )
    ''');

    // 通知表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        target_type TEXT,
        target_id TEXT,
        is_read INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // 订阅相关操作
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subscriptions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        metadata TEXT,
        family_member_ids TEXT,
        max_repositories INTEGER NOT NULL,
        max_boxes_per_repository INTEGER NOT NULL,
        has_advanced_properties INTEGER NOT NULL,
        has_watermark_protection INTEGER NOT NULL,
        max_family_members INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 初始化等级数据
    await _initLevels(db);

    // 初始化商城商品
    await _initMallItems(db);
  }

  Future<void> _initLevels(Database db) async {
    final levels = [
      LevelModel(
        level: 1,
        requiredExp: 0,
        title: '新手',
        description: '欢迎加入社区！',
        privileges: ['基础发帖', '基础评论'],
      ),
      LevelModel(
        level: 2,
        requiredExp: 100,
        title: '活跃用户',
        description: '开始活跃起来了！',
        privileges: ['创建投票', '上传图片'],
      ),
      LevelModel(
        level: 3,
        requiredExp: 500,
        title: '资深用户',
        description: '社区的中坚力量！',
        privileges: ['创建频道', '发起活动'],
      ),
      LevelModel(
        level: 4,
        requiredExp: 2000,
        title: '社区精英',
        description: '社区的重要贡献者！',
        privileges: ['置顶帖子', '管理评论'],
      ),
      LevelModel(
        level: 5,
        requiredExp: 5000,
        title: '社区领袖',
        description: '社区的核心力量！',
        privileges: ['管理频道', '审核内容'],
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
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  // 盒子相关操作
  Future<int> insertBox(BoxModel box) async {
    final db = await database;
    return await db.insert('boxes', box.toMap());
  }

  Future<List<BoxModel>> getBoxesByOwner(int ownerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'boxes',
      where: 'ownerId = ?',
      whereArgs: [ownerId],
      orderBy: 'sortOrder ASC',
    );
    return List.generate(maps.length, (i) => BoxModel.fromMap(maps[i]));
  }

  Future<BoxModel?> getBox(int id) async {
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

  Future<List<ItemModel>> getItemsByBox(int boxId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'items',
      where: 'boxId = ?',
      whereArgs: [boxId],
      orderBy: 'sortOrder ASC',
    );
    return List.generate(maps.length, (i) => ItemModel.fromMap(maps[i]));
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

  Future<int> deleteBox(int id) async {
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

  Future<List<FollowModel>> getFollowers(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'follows',
      where: 'following_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => FollowModel.fromMap(maps[i]));
  }

  Future<List<FollowModel>> getFollowing(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'follows',
      where: 'follower_id = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => FollowModel.fromMap(maps[i]));
  }

  Future<int> getFollowerCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM follows WHERE following_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getFollowingCount(int userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM follows WHERE follower_id = ?',
      [userId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<bool> isFollowing(int followerId, int followingId) async {
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
  Future<void> joinChannel(int channelId, int userId) async {
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

  Future<void> leaveChannel(int channelId, int userId) async {
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

  Future<bool> isChannelMember(int channelId, int userId) async {
    final db = await database;
    final result = await db.query(
      'channel_members',
      where: 'channelId = ? AND userId = ?',
      whereArgs: [channelId, userId],
    );
    return result.isNotEmpty;
  }

  Future<String> getChannelMemberRole(int channelId, int userId) async {
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
    final List<Map<String, dynamic>> maps = await database.query(
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

  Future<void> addExperience(int userId, int experience) async {
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
      whereClause.add('is_active = 1');
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

  Future<List<OrderModel>> getUserOrders(int userId) async {
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
  Future<List<ModeratorModel>> getChannelModerators(int channelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moderators',
      where: 'channel_id = ? AND is_active = 1',
      whereArgs: [channelId],
    );
    return List.generate(maps.length, (i) => ModeratorModel.fromMap(maps[i]));
  }

  Future<ModeratorModel?> getModerator(int userId, int channelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moderators',
      where: 'user_id = ? AND channel_id = ? AND is_active = 1',
      whereArgs: [userId, channelId],
    );
    if (maps.isEmpty) return null;
    return ModeratorModel.fromMap(maps.first);
  }

  Future<int> createModerator(ModeratorModel moderator) async {
    final db = await database;
    return await db.insert('moderators', moderator.toMap());
  }

  Future<int> updateModerator(ModeratorModel moderator) async {
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
      {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [moderatorId],
    );
  }

  // 版主申请相关方法
  Future<List<ModeratorApplicationModel>> getChannelApplications(int channelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moderator_applications',
      where: 'channel_id = ?',
      whereArgs: [channelId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => ModeratorApplicationModel.fromMap(maps[i]));
  }

  Future<ModeratorApplicationModel?> getUserApplication(int userId, int channelId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moderator_applications',
      where: 'user_id = ? AND channel_id = ?',
      whereArgs: [userId, channelId],
    );
    if (maps.isEmpty) return null;
    return ModeratorApplicationModel.fromMap(maps.first);
  }

  Future<int> createApplication(ModeratorApplicationModel application) async {
    final db = await database;
    return await db.insert('moderator_applications', application.toMap());
  }

  Future<int> updateApplication(ModeratorApplicationModel application) async {
    final db = await database;
    return await db.update(
      'moderator_applications',
      application.toMap(),
      where: 'id = ?',
      whereArgs: [application.id],
    );
  }

  // 版主操作日志相关方法
  Future<List<ModeratorLogModel>> getModeratorLogs(int channelId, {int? moderatorId}) async {
    final db = await database;
    String whereClause = 'channel_id = ?';
    List<dynamic> whereArgs = [channelId];
    
    if (moderatorId != null) {
      whereClause += ' AND moderator_id = ?';
      whereArgs.add(moderatorId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'moderator_logs',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => ModeratorLogModel.fromMap(maps[i]));
  }

  Future<int> createModeratorLog(ModeratorLogModel log) async {
    final db = await database;
    return await db.insert('moderator_logs', log.toMap());
  }

  // 获取频道申请列表
  Future<List<ChannelApplicationModel>> getChannelApplications({
    int? userId,
    String? status,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (userId != null) {
      whereClause = 'WHERE user_id = ?';
      whereArgs.add(userId);
    }

    if (status != null) {
      whereClause = whereClause.isEmpty ? 'WHERE status = ?' : '$whereClause AND status = ?';
      whereArgs.add(status);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'channel_applications',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return ChannelApplicationModel.fromMap(maps[i]);
    });
  }

  // 获取单个频道申请
  Future<ChannelApplicationModel?> getChannelApplication(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'channel_applications',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ChannelApplicationModel.fromMap(maps.first);
  }

  // 创建频道申请
  Future<int> createChannelApplication(ChannelApplicationModel application) async {
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
    ChannelApplicationReviewModel review,
  ) async {
    final db = await database;
    return await db.insert('channel_application_reviews', review.toMap());
  }

  // 获取频道申请审核记录
  Future<List<ChannelApplicationReviewModel>> getChannelApplicationReviews(
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
      return ChannelApplicationReviewModel.fromMap(maps[i]);
    });
  }

  // 内容审核相关方法
  Future<List<ContentReportModel>> getContentReports({
    String? status,
    String? targetType,
    int? targetId,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (status != null) {
      whereClause = 'WHERE status = ?';
      whereArgs.add(status);
    }

    if (targetType != null) {
      whereClause = whereClause.isEmpty ? 'WHERE target_type = ?' : '$whereClause AND target_type = ?';
      whereArgs.add(targetType);
    }

    if (targetId != null) {
      whereClause = whereClause.isEmpty ? 'WHERE target_id = ?' : '$whereClause AND target_id = ?';
      whereArgs.add(targetId);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'content_reports',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => ContentReportModel.fromMap(maps[i]));
  }

  Future<ContentReportModel?> getContentReport(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'content_reports',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return ContentReportModel.fromMap(maps.first);
  }

  Future<int> createContentReport(ContentReportModel report) async {
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

  Future<int> createContentReview(ContentReviewModel review) async {
    final db = await database;
    return await db.insert('content_reviews', review.toMap());
  }

  Future<List<ContentReviewModel>> getContentReviews(int reportId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'content_reviews',
      where: 'report_id = ?',
      whereArgs: [reportId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => ContentReviewModel.fromMap(maps[i]));
  }

  // 获取所有等级
  Future<List<LevelModel>> getLevels() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'levels',
      orderBy: 'level ASC',
    );

    return List.generate(maps.length, (i) {
      return LevelModel.fromMap(maps[i]);
    });
  }

  // 获取用户等级信息
  Future<UserLevelModel?> getUserLevel(String userId) async {
    final List<Map<String, dynamic>> maps = await database.query(
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

  // 初始化等级数据
  Future<void> initializeLevels() async {
    final levels = [
      LevelModel(
        level: 1,
        requiredExp: 0,
        title: '新手',
        description: '欢迎加入社区！',
        privileges: ['基础发帖', '基础评论'],
      ),
      LevelModel(
        level: 2,
        requiredExp: 100,
        title: '活跃用户',
        description: '开始活跃起来了！',
        privileges: ['创建投票', '上传图片'],
      ),
      LevelModel(
        level: 3,
        requiredExp: 500,
        title: '资深用户',
        description: '社区的中坚力量！',
        privileges: ['创建频道', '发起活动'],
      ),
      LevelModel(
        level: 4,
        requiredExp: 2000,
        title: '社区精英',
        description: '社区的重要贡献者！',
        privileges: ['置顶帖子', '管理评论'],
      ),
      LevelModel(
        level: 5,
        requiredExp: 5000,
        title: '社区领袖',
        description: '社区的核心力量！',
        privileges: ['管理频道', '审核内容'],
      ),
    ];

    for (var level in levels) {
      await database.insert(
        'levels',
        level.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // 创建搜索历史表
  Future<void> _createSearchTables() async {
    await _database!.execute('''
      CREATE TABLE IF NOT EXISTS search_history (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        keyword TEXT NOT NULL,
        search_time TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // 获取用户搜索历史
  Future<List<SearchHistoryModel>> getSearchHistory(String userId) async {
    final List<Map<String, dynamic>> maps = await _database!.query(
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
    await _database!.insert(
      'search_history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 清除搜索历史
  Future<void> clearSearchHistory(String userId) async {
    await _database!.delete(
      'search_history',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // 搜索帖子
  Future<List<SearchResultModel>> searchPosts(String keyword) async {
    final List<Map<String, dynamic>> maps = await _database!.rawQuery('''
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
        id: map['id'] as String,
        type: 'post',
        title: map['title'] as String,
        description: map['description'] as String,
        imageUrl: map['image_url'] as String?,
        extraData: {
          'author_name': map['author_name'] as String,
          'channel_name': map['channel_name'] as String,
        },
        createdAt: DateTime.parse(map['created_at'] as String),
      );
    });
  }

  // 搜索频道
  Future<List<SearchResultModel>> searchChannels(String keyword) async {
    final List<Map<String, dynamic>> maps = await _database!.rawQuery('''
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
        id: map['id'] as String,
        type: 'channel',
        title: map['title'] as String,
        description: map['description'] as String,
        imageUrl: map['image_url'] as String?,
        extraData: {
          'owner_name': map['owner_name'] as String,
          'post_count': map['post_count'] as int,
        },
        createdAt: DateTime.parse(map['created_at'] as String),
      );
    });
  }

  // 搜索用户
  Future<List<SearchResultModel>> searchUsers(String keyword) async {
    final List<Map<String, dynamic>> maps = await _database!.rawQuery('''
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
        id: map['id'] as String,
        type: 'user',
        title: map['title'] as String,
        description: map['description'] as String,
        imageUrl: map['image_url'] as String?,
        extraData: {
          'post_count': map['post_count'] as int,
          'channel_count': map['channel_count'] as int,
        },
        createdAt: DateTime.parse(map['created_at'] as String),
      );
    });
  }

  // 通知相关方法
  Future<List<NotificationModel>> getNotifications(String userId, {bool onlyUnread = false}) async {
    final db = await database;
    String whereClause = 'user_id = ?';
    List<dynamic> whereArgs = [userId];

    if (onlyUnread) {
      whereClause += ' AND is_read = 0';
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'notifications',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) => NotificationModel.fromMap(maps[i]));
  }

  Future<int> getUnreadNotificationCount(String userId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0',
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
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [notificationId],
    );
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final db = await database;
    await db.update(
      'notifications',
      {'is_read': 1},
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
        is_active INTEGER NOT NULL,
        metadata TEXT,
        family_member_ids TEXT,
        max_repositories INTEGER NOT NULL,
        max_boxes_per_repository INTEGER NOT NULL,
        has_advanced_properties INTEGER NOT NULL,
        has_watermark_protection INTEGER NOT NULL,
        max_family_members INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<SubscriptionModel?> getSubscription(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subscriptions',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) {
      // 如果没有找到订阅，创建一个免费订阅
      final subscription = SubscriptionModel(
        userId: userId,
        type: SubscriptionType.FREE,
      );
      await createSubscription(subscription);
      return subscription;
    }

    return SubscriptionModel.fromMap(maps.first);
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

  Future<List<SubscriptionModel>> getSubscriptionsByType(SubscriptionType type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'subscriptions',
      where: 'type = ?',
      whereArgs: [type.toString()],
    );

    return List.generate(maps.length, (i) => SubscriptionModel.fromMap(maps[i]));
  }

  Future<List<SubscriptionModel>> getExpiredSubscriptions() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> maps = await db.query(
      'subscriptions',
      where: 'end_date < ? AND is_active = 1',
      whereArgs: [now],
    );

    return List.generate(maps.length, (i) => SubscriptionModel.fromMap(maps[i]));
  }

  Future<void> deactivateExpiredSubscriptions() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'subscriptions',
      {'is_active': 0},
      where: 'end_date < ? AND is_active = 1',
      whereArgs: [now],
    );
  }
} 