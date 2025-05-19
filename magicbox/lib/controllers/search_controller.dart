import 'package:get/get.dart';
import '../models/user_model.dart';
import '../models/item_model.dart';
import '../models/box_model.dart';
import '../services/database_service.dart';
import '../models/search_history_model.dart';
import '../models/search_model.dart' show SearchResultModel;

class SearchController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel _currentUser = Get.find<UserModel>();

  final RxList<UserModel> _userResults = <UserModel>[].obs;
  final RxList<ItemModel> _itemResults = <ItemModel>[].obs;
  final RxList<BoxModel> _boxResults = <BoxModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _currentQuery = ''.obs;

  final RxList<SearchHistoryModel> searchHistory = <SearchHistoryModel>[].obs;
  final RxList<SearchResultModel> searchResults = <SearchResultModel>[].obs;
  final RxString currentKeyword = ''.obs;
  final RxString currentType = 'all'.obs;

  List<UserModel> get userResults => _userResults;
  List<ItemModel> get itemResults => _itemResults;
  List<BoxModel> get boxResults => _boxResults;
  bool get isLoading => _isLoading.value;
  String get currentQuery => _currentQuery.value;

  @override
  void onInit() {
    super.onInit();
    loadSearchHistory();
  }

  // 加载搜索历史
  Future<void> loadSearchHistory() async {
    try {
      _isLoading.value = true;
      final history =
          await _databaseService.getSearchHistory(_currentUser.id.toString());
      searchHistory.value = history;
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载搜索历史失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // 清除搜索历史
  Future<void> clearSearchHistory() async {
    try {
      _isLoading.value = true;
      await _databaseService.clearSearchHistory(_currentUser.id.toString());
      searchHistory.clear();
      Get.snackbar(
        '成功',
        '搜索历史已清除',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        '错误',
        '清除搜索历史失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> search(String keyword, {String type = 'all'}) async {
    if (keyword.isEmpty) return;

    try {
      _isLoading.value = true;
      currentKeyword.value = keyword;
      currentType.value = type;
      searchResults.clear();

      // 添加搜索历史
      final history = SearchHistoryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUser.id.toString(),
        keyword: keyword,
        searchTime: DateTime.now(),
      );
      await _databaseService.addSearchHistory(history);
      searchHistory.insert(0, history);

      // 执行搜索
      final List<SearchResultModel> results = [];
      if (type == 'all' || type == 'post') {
        results.addAll(await _databaseService.searchPosts(keyword) as Iterable<SearchResultModel>);
      }
      if (type == 'all' || type == 'channel') {
        results.addAll(await _databaseService.searchChannels(keyword) as Iterable<SearchResultModel>);
      }
      if (type == 'all' || type == 'user') {
        results.addAll(await _databaseService.searchUsers(keyword) as Iterable<SearchResultModel>);
      }

      // 按创建时间排序
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      searchResults.value = results;
    } catch (e) {
      Get.snackbar(
        '错误',
        '搜索失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // 获取搜索结果数量
  int getResultCount(String type) {
    return searchResults.where((result) => result.type == type).length;
  }

  // 获取特定类型的搜索结果
  List<SearchResultModel> getResultsByType(String type) {
    return searchResults.where((result) => result.type == type).toList();
  }

  // 处理搜索结果点击
  void handleResultClick(SearchResultModel result) {
    switch (result.type) {
      case 'post':
        Get.toNamed('/post/${result.id}');
        break;
      case 'channel':
        Get.toNamed('/channel/${result.id}');
        break;
      case 'user':
        Get.toNamed('/user/${result.id}');
        break;
    }
  }
}
