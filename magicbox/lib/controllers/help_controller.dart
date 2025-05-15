import 'package:get/get.dart';
import '../models/help_model.dart';

class HelpController extends GetxController {
  final isLoading = false.obs;
  final helpArticles = <HelpArticle>[].obs;
  final faqs = <FAQ>[].obs;
  final currentCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadHelpContent();
  }

  Future<void> loadHelpContent({String? category}) async {
    try {
      isLoading.value = true;
      currentCategory.value = category ?? '';

      // TODO: 从API或本地数据库加载帮助内容
      // 这里暂时使用模拟数据
      await Future.delayed(const Duration(milliseconds: 500));
      
      helpArticles.value = [
        HelpArticle(
          title: '如何创建仓库',
          content: '点击首页的"+"按钮，选择"创建仓库"，填写仓库名称和描述即可创建。',
          category: '基础操作',
          order: 1,
        ),
        HelpArticle(
          title: '如何添加物品',
          content: '在仓库详情页面点击"+"按钮，选择"添加物品"，填写物品信息并上传图片即可。',
          category: '基础操作',
          order: 2,
        ),
        HelpArticle(
          title: '如何分享仓库',
          content: '在仓库详情页面点击分享按钮，选择分享方式即可。',
          category: '分享功能',
          order: 1,
        ),
      ];

      faqs.value = [
        FAQ(
          question: '如何修改仓库名称？',
          answer: '在仓库详情页面点击编辑按钮，即可修改仓库名称。',
          category: '基础操作',
          order: 1,
        ),
        FAQ(
          question: '如何删除仓库？',
          answer: '在仓库详情页面点击删除按钮，确认后即可删除仓库。',
          category: '基础操作',
          order: 2,
        ),
        FAQ(
          question: '如何邀请他人协作？',
          answer: '在仓库详情页面点击分享按钮，选择"邀请协作"，输入对方邮箱即可。',
          category: '协作功能',
          order: 1,
        ),
      ];

      if (category != null) {
        helpArticles.value = helpArticles.where((article) => article.category == category).toList();
        faqs.value = faqs.where((faq) => faq.category == category).toList();
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载帮助内容失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<String> getCategories() {
    final categories = <String>{};
    for (var article in helpArticles) {
      categories.add(article.category);
    }
    for (var faq in faqs) {
      categories.add(faq.category);
    }
    return categories.toList()..sort();
  }
} 