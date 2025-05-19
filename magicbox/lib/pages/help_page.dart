import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/help_controller.dart';
import '../models/help_model.dart';

class HelpPage extends StatelessWidget {
  final HelpController controller = Get.put(HelpController());

  HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('帮助中心'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '帮助文章'),
              Tab(text: '常见问题'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildCategoryFilter(),
            Expanded(
              child: TabBarView(
                children: [
                  _buildHelpArticles(),
                  _buildFAQs(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(() {
      final categories = controller.getCategories();
      if (categories.isEmpty) return const SizedBox();

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FilterChip(
                label: const Text('全部'),
                selected: controller.currentCategory.value.isEmpty,
                onSelected: (selected) {
                  if (selected) {
                    controller.loadHelpContent();
                  }
                },
              ),
              const SizedBox(width: 8),
              ...categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: controller.currentCategory.value == category,
                    onSelected: (selected) {
                      if (selected) {
                        controller.loadHelpContent(category: category);
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHelpArticles() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.helpArticles.isEmpty) {
        return const Center(
          child: Text('暂无帮助文章'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.helpArticles.length,
        itemBuilder: (context, index) {
          final article = controller.helpArticles[index];
          return _buildHelpArticleCard(article);
        },
      );
    });
  }

  Widget _buildHelpArticleCard(HelpArticle article) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showHelpArticleDetail(article),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Chip(
                    label: Text(article.category),
                    backgroundColor:
                        Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                article.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '更新时间：${_formatDate(article.updatedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQs() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.faqs.isEmpty) {
        return const Center(
          child: Text('暂无常见问题'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.faqs.length,
        itemBuilder: (context, index) {
          final faq = controller.faqs[index];
          return _buildFAQCard(faq);
        },
      );
    });
  }

  Widget _buildFAQCard(FAQ faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '更新时间：${_formatDate(faq.updatedAt)}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(faq.answer),
          ),
        ],
      ),
    );
  }

  void _showHelpArticleDetail(HelpArticle article) {
    Get.dialog(
      Dialog(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(article.category),
                backgroundColor:
                    Theme.of(Get.context!).primaryColor.withOpacity(0.1),
              ),
              const SizedBox(height: 16),
              Text(article.content),
              const SizedBox(height: 16),
              Text(
                '更新时间：${_formatDate(article.updatedAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
