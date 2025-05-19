class UserStatistics {
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final int newUsersThisWeek;
  final int newUsersThisMonth;
  final Map<String, int> userLevelDistribution;
  final Map<String, int> userTypeDistribution;

  UserStatistics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.newUsersThisWeek,
    required this.newUsersThisMonth,
    required this.userLevelDistribution,
    required this.userTypeDistribution,
  });

  Map<String, dynamic> toMap() {
    return {
      'total_users': totalUsers,
      'active_users': activeUsers,
      'new_users_today': newUsersToday,
      'new_users_thisweek': newUsersThisWeek,
      'new_users_thismonth': newUsersThisMonth,
      'user_level_distribution': userLevelDistribution,
      'user_type_distribution': userTypeDistribution,
    };
  }

  factory UserStatistics.fromMap(Map<String, dynamic> map) {
    return UserStatistics(
      totalUsers: map['total_users'] as int,
      activeUsers: map['active_users'] as int,
      newUsersToday: map['new_users_today'] as int,
      newUsersThisWeek: map['new_users_thisweek'] as int,
      newUsersThisMonth: map['new_users_thismonth'] as int,
      userLevelDistribution:
          Map<String, int>.from(map['user_level_distribution'] as Map),
      userTypeDistribution:
          Map<String, int>.from(map['user_type_distribution'] as Map),
    );
  }
}

class ContentStatistics {
  final int totalPosts;
  final int totalComments;
  final int totalChannels;
  final int totalBoxes;
  final int totalItems;
  final int newPostsToday;
  final int newCommentsToday;
  final Map<String, int> postTypeDistribution;
  final Map<String, int> channelCategoryDistribution;
  final Map<String, int> boxTypeDistribution;

  ContentStatistics({
    required this.totalPosts,
    required this.totalComments,
    required this.totalChannels,
    required this.totalBoxes,
    required this.totalItems,
    required this.newPostsToday,
    required this.newCommentsToday,
    required this.postTypeDistribution,
    required this.channelCategoryDistribution,
    required this.boxTypeDistribution,
  });

  Map<String, dynamic> toMap() {
    return {
      'total_posts': totalPosts,
      'total_comments': totalComments,
      'total_channels': totalChannels,
      'total_boxes': totalBoxes,
      'total_items': totalItems,
      'new_posts_today': newPostsToday,
      'new_comments_today': newCommentsToday,
      'post_type_distribution': postTypeDistribution,
      'channel_category_distribution': channelCategoryDistribution,
      'box_type_distribution': boxTypeDistribution,
    };
  }

  factory ContentStatistics.fromMap(Map<String, dynamic> map) {
    return ContentStatistics(
      totalPosts: map['total_posts'] as int,
      totalComments: map['total_comments'] as int,
      totalChannels: map['total_channels'] as int,
      totalBoxes: map['total_boxes'] as int,
      totalItems: map['total_items'] as int,
      newPostsToday: map['new_posts_today'] as int,
      newCommentsToday: map['new_comments_today'] as int,
      postTypeDistribution:
          Map<String, int>.from(map['post_type_distribution'] as Map),
      channelCategoryDistribution:
          Map<String, int>.from(map['channel_category_distribution'] as Map),
      boxTypeDistribution:
          Map<String, int>.from(map['box_type_distribution'] as Map),
    );
  }
}

class InteractionStatistics {
  final int totalLikes;
  final int totalFollows;
  final int totalReports;
  final int totalReviews;
  final int newLikesToday;
  final int newFollowsToday;
  final int newReportsToday;
  final int newReviewsToday;
  final Map<String, int> reportTypeDistribution;
  final Map<String, int> reviewActionDistribution;

  InteractionStatistics({
    required this.totalLikes,
    required this.totalFollows,
    required this.totalReports,
    required this.totalReviews,
    required this.newLikesToday,
    required this.newFollowsToday,
    required this.newReportsToday,
    required this.newReviewsToday,
    required this.reportTypeDistribution,
    required this.reviewActionDistribution,
  });

  Map<String, dynamic> toMap() {
    return {
      'total_likes': totalLikes,
      'total_follows': totalFollows,
      'total_reports': totalReports,
      'total_reviews': totalReviews,
      'new_likes_today': newLikesToday,
      'new_follows_today': newFollowsToday,
      'new_reports_today': newReportsToday,
      'new_reviews_today': newReviewsToday,
      'report_type_distribution': reportTypeDistribution,
      'review_action_distribution': reviewActionDistribution,
    };
  }

  factory InteractionStatistics.fromMap(Map<String, dynamic> map) {
    return InteractionStatistics(
      totalLikes: map['total_likes'] as int,
      totalFollows: map['total_follows'] as int,
      totalReports: map['total_reports'] as int,
      totalReviews: map['total_reviews'] as int,
      newLikesToday: map['new_likes_today'] as int,
      newFollowsToday: map['new_follows_today'] as int,
      newReportsToday: map['new_reports_today'] as int,
      newReviewsToday: map['new_reviews_today'] as int,
      reportTypeDistribution:
          Map<String, int>.from(map['report_type_distribution'] as Map),
      reviewActionDistribution:
          Map<String, int>.from(map['review_action_distribution'] as Map),
    );
  }
}
