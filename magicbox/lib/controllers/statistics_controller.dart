import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/statistics_model.dart';
import '../models/user_model.dart';

class StatisticsController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel currentUser = Get.find<UserModel>();

  final Rx<UserStatistics?> userStatistics = Rx<UserStatistics?>(null);
  final Rx<ContentStatistics?> contentStatistics = Rx<ContentStatistics?>(null);
  final Rx<InteractionStatistics?> interactionStatistics = Rx<InteractionStatistics?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _loadUserStatistics(),
        _loadContentStatistics(),
        _loadInteractionStatistics(),
      ]);
    } catch (e) {
      Get.snackbar('错误', '加载统计数据失败：$e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserStatistics() async {
    final db = await _databaseService.database;
    
    // 获取总用户数
    final totalUsersResult = await db.rawQuery('SELECT COUNT(*) as count FROM users');
    final totalUsers = Sqflite.firstIntValue(totalUsersResult) ?? 0;

    // 获取活跃用户数（最近7天有活动的用户）
    final activeUsersResult = await db.rawQuery('''
      SELECT COUNT(DISTINCT user_id) as count
      FROM (
        SELECT user_id FROM posts WHERE created_at >= datetime('now', '-7 days')
        UNION
        SELECT user_id FROM comments WHERE created_at >= datetime('now', '-7 days')
        UNION
        SELECT user_id FROM likes WHERE created_at >= datetime('now', '-7 days')
      )
    ''');
    final activeUsers = Sqflite.firstIntValue(activeUsersResult) ?? 0;

    // 获取今日新增用户
    final newUsersTodayResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM users
      WHERE created_at >= datetime('now', 'start of day')
    ''');
    final newUsersToday = Sqflite.firstIntValue(newUsersTodayResult) ?? 0;

    // 获取本周新增用户
    final newUsersThisWeekResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM users
      WHERE created_at >= datetime('now', '-7 days')
    ''');
    final newUsersThisWeek = Sqflite.firstIntValue(newUsersThisWeekResult) ?? 0;

    // 获取本月新增用户
    final newUsersThisMonthResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM users
      WHERE created_at >= datetime('now', 'start of month')
    ''');
    final newUsersThisMonth = Sqflite.firstIntValue(newUsersThisMonthResult) ?? 0;

    // 获取用户等级分布
    final userLevelResult = await db.rawQuery('''
      SELECT level, COUNT(*) as count
      FROM users
      GROUP BY level
    ''');
    final userLevelDistribution = Map<String, int>.fromEntries(
      userLevelResult.map((row) => MapEntry(row['level'].toString(), row['count'] as int)),
    );

    // 获取用户类型分布
    final userTypeResult = await db.rawQuery('''
      SELECT type, COUNT(*) as count
      FROM users
      GROUP BY type
    ''');
    final userTypeDistribution = Map<String, int>.fromEntries(
      userTypeResult.map((row) => MapEntry(row['type'] as String, row['count'] as int)),
    );

    userStatistics.value = UserStatistics(
      totalUsers: totalUsers,
      activeUsers: activeUsers,
      newUsersToday: newUsersToday,
      newUsersThisWeek: newUsersThisWeek,
      newUsersThisMonth: newUsersThisMonth,
      userLevelDistribution: userLevelDistribution,
      userTypeDistribution: userTypeDistribution,
    );
  }

  Future<void> _loadContentStatistics() async {
    final db = await _databaseService.database;

    // 获取总帖子数
    final totalPostsResult = await db.rawQuery('SELECT COUNT(*) as count FROM posts');
    final totalPosts = Sqflite.firstIntValue(totalPostsResult) ?? 0;

    // 获取总评论数
    final totalCommentsResult = await db.rawQuery('SELECT COUNT(*) as count FROM comments');
    final totalComments = Sqflite.firstIntValue(totalCommentsResult) ?? 0;

    // 获取总频道数
    final totalChannelsResult = await db.rawQuery('SELECT COUNT(*) as count FROM channels');
    final totalChannels = Sqflite.firstIntValue(totalChannelsResult) ?? 0;

    // 获取总盒子数
    final totalBoxesResult = await db.rawQuery('SELECT COUNT(*) as count FROM boxes');
    final totalBoxes = Sqflite.firstIntValue(totalBoxesResult) ?? 0;

    // 获取总物品数
    final totalItemsResult = await db.rawQuery('SELECT COUNT(*) as count FROM items');
    final totalItems = Sqflite.firstIntValue(totalItemsResult) ?? 0;

    // 获取今日新增帖子
    final newPostsTodayResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM posts
      WHERE created_at >= datetime('now', 'start of day')
    ''');
    final newPostsToday = Sqflite.firstIntValue(newPostsTodayResult) ?? 0;

    // 获取今日新增评论
    final newCommentsTodayResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM comments
      WHERE created_at >= datetime('now', 'start of day')
    ''');
    final newCommentsToday = Sqflite.firstIntValue(newCommentsTodayResult) ?? 0;

    // 获取帖子类型分布
    final postTypeResult = await db.rawQuery('''
      SELECT type, COUNT(*) as count
      FROM posts
      GROUP BY type
    ''');
    final postTypeDistribution = Map<String, int>.fromEntries(
      postTypeResult.map((row) => MapEntry(row['type'] as String, row['count'] as int)),
    );

    // 获取频道分类分布
    final channelCategoryResult = await db.rawQuery('''
      SELECT category, COUNT(*) as count
      FROM channels
      GROUP BY category
    ''');
    final channelCategoryDistribution = Map<String, int>.fromEntries(
      channelCategoryResult.map((row) => MapEntry(row['category'] as String, row['count'] as int)),
    );

    // 获取盒子类型分布
    final boxTypeResult = await db.rawQuery('''
      SELECT type, COUNT(*) as count
      FROM boxes
      GROUP BY type
    ''');
    final boxTypeDistribution = Map<String, int>.fromEntries(
      boxTypeResult.map((row) => MapEntry(row['type'] as String, row['count'] as int)),
    );

    contentStatistics.value = ContentStatistics(
      totalPosts: totalPosts,
      totalComments: totalComments,
      totalChannels: totalChannels,
      totalBoxes: totalBoxes,
      totalItems: totalItems,
      newPostsToday: newPostsToday,
      newCommentsToday: newCommentsToday,
      postTypeDistribution: postTypeDistribution,
      channelCategoryDistribution: channelCategoryDistribution,
      boxTypeDistribution: boxTypeDistribution,
    );
  }

  Future<void> _loadInteractionStatistics() async {
    final db = await _databaseService.database;

    // 获取总点赞数
    final totalLikesResult = await db.rawQuery('SELECT COUNT(*) as count FROM likes');
    final totalLikes = Sqflite.firstIntValue(totalLikesResult) ?? 0;

    // 获取总关注数
    final totalFollowsResult = await db.rawQuery('SELECT COUNT(*) as count FROM follows');
    final totalFollows = Sqflite.firstIntValue(totalFollowsResult) ?? 0;

    // 获取总举报数
    final totalReportsResult = await db.rawQuery('SELECT COUNT(*) as count FROM content_reports');
    final totalReports = Sqflite.firstIntValue(totalReportsResult) ?? 0;

    // 获取总审核数
    final totalReviewsResult = await db.rawQuery('SELECT COUNT(*) as count FROM content_reviews');
    final totalReviews = Sqflite.firstIntValue(totalReviewsResult) ?? 0;

    // 获取今日新增点赞
    final newLikesTodayResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM likes
      WHERE created_at >= datetime('now', 'start of day')
    ''');
    final newLikesToday = Sqflite.firstIntValue(newLikesTodayResult) ?? 0;

    // 获取今日新增关注
    final newFollowsTodayResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM follows
      WHERE created_at >= datetime('now', 'start of day')
    ''');
    final newFollowsToday = Sqflite.firstIntValue(newFollowsTodayResult) ?? 0;

    // 获取今日新增举报
    final newReportsTodayResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM content_reports
      WHERE created_at >= datetime('now', 'start of day')
    ''');
    final newReportsToday = Sqflite.firstIntValue(newReportsTodayResult) ?? 0;

    // 获取今日新增审核
    final newReviewsTodayResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM content_reviews
      WHERE created_at >= datetime('now', 'start of day')
    ''');
    final newReviewsToday = Sqflite.firstIntValue(newReviewsTodayResult) ?? 0;

    // 获取举报类型分布
    final reportTypeResult = await db.rawQuery('''
      SELECT target_type, COUNT(*) as count
      FROM content_reports
      GROUP BY target_type
    ''');
    final reportTypeDistribution = Map<String, int>.fromEntries(
      reportTypeResult.map((row) => MapEntry(row['target_type'] as String, row['count'] as int)),
    );

    // 获取审核操作分布
    final reviewActionResult = await db.rawQuery('''
      SELECT action, COUNT(*) as count
      FROM content_reviews
      GROUP BY action
    ''');
    final reviewActionDistribution = Map<String, int>.fromEntries(
      reviewActionResult.map((row) => MapEntry(row['action'] as String, row['count'] as int)),
    );

    interactionStatistics.value = InteractionStatistics(
      totalLikes: totalLikes,
      totalFollows: totalFollows,
      totalReports: totalReports,
      totalReviews: totalReviews,
      newLikesToday: newLikesToday,
      newFollowsToday: newFollowsToday,
      newReportsToday: newReportsToday,
      newReviewsToday: newReviewsToday,
      reportTypeDistribution: reportTypeDistribution,
      reviewActionDistribution: reviewActionDistribution,
    );
  }
} 