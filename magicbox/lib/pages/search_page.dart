import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/search_controller.dart' as custom;
import '../models/search_model.dart';

class SearchPage extends StatelessWidget {
  final custom.SearchController _controller =
      Get.put(custom.SearchController());
  final TextEditingController _searchController = TextEditingController();

  SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: '搜索帖子、频道、用户...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _controller.searchResults.clear();
              },
            ),
          ),
          onSubmitted: (value) => _controller.search(value),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _controller.search(_searchController.text),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.searchResults.isEmpty) {
          return _buildSearchHistory();
        }

        return _buildSearchResults();
      }),
    );
  }

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '搜索历史',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_controller.searchHistory.isNotEmpty)
                TextButton(
                  onPressed: () => _controller.clearSearchHistory(),
                  child: const Text('清除历史'),
                ),
            ],
          ),
        ),
        if (_controller.searchHistory.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '暂无搜索历史',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              itemCount: _controller.searchHistory.length,
              itemBuilder: (context, index) {
                final history = _controller.searchHistory[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(history.keyword),
                  subtitle: Text(
                    _formatDate(history.searchTime),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    _searchController.text = history.keyword;
                    _controller.search(history.keyword);
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: '全部 (${_controller.searchResults.length})'),
              Tab(text: '帖子 (${_controller.getResultCount('post')})'),
              Tab(text: '频道 (${_controller.getResultCount('channel')})'),
              Tab(text: '用户 (${_controller.getResultCount('user')})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildResultList(_controller.searchResults),
                _buildResultList(_controller.getResultsByType('post')),
                _buildResultList(_controller.getResultsByType('channel')),
                _buildResultList(_controller.getResultsByType('user')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultList(List<SearchResultModel> results) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          '暂无搜索结果',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return _buildResultItem(result);
      },
    );
  }

  Widget _buildResultItem(SearchResultModel result) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _controller.handleResultClick(result),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (result.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    result.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(result.type),
                    color: Colors.grey[400],
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (result.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        result.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    _buildExtraInfo(result),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExtraInfo(SearchResultModel result) {
    switch (result.type) {
      case 'post':
        return Text(
          '作者：${result.extraData?['author_name']} · 频道：${result.extraData?['channel_name']}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        );
      case 'channel':
        return Text(
          '创建者：${result.extraData?['owner_name']} · 帖子数：${result.extraData?['post_count']}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        );
      case 'user':
        return Text(
          '帖子：${result.extraData?['post_count']} · 频道：${result.extraData?['channel_count']}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'post':
        return Icons.article;
      case 'channel':
        return Icons.forum;
      case 'user':
        return Icons.person;
      default:
        return Icons.search;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}分钟前';
      }
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
