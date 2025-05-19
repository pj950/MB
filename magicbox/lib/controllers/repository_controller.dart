import 'package:get/get.dart';
import '../models/repository_model.dart';
import '../services/database_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/subscription_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/box_model.dart';

class RepositoryController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final AuthController _authController = Get.find<AuthController>();
  final SubscriptionController _subscriptionController =
      Get.find<SubscriptionController>();
  final RxList<RepositoryModel> _repositories = <RepositoryModel>[].obs;
  final RxBool _isLoading = false.obs;

  List<RepositoryModel> get repositories => _repositories;
  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    print('RepositoryController onInit');

    // 监听用户登录状态
    ever(_authController.currentUserRx, (user) async {
      if (user != null) {
        await loadRepositories();
        if (_repositories.isEmpty) {
          await _createDefaultRepository();
        }
      }
    });

    // 初始检查
    if (_authController.currentUser != null) {
      loadRepositories();
      if (_repositories.isEmpty) {
        _createDefaultRepository();
      }
    }
  }

  Future<void> loadRepositories() async {
    _isLoading.value = true;
    try {
      final currentUserId = _authController.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('用户未登录');
      }
      final repositories = await _databaseService
          .getRepositoriesByOwner(currentUserId.toString());
      _repositories.value = repositories;
    } catch (e) {
      debugPrint('加载仓库列表失败: $e');
      Get.snackbar(
        '错误',
        '加载仓库列表失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<RepositoryModel> createRepository({
    required String name,
    String? description,
    required String userId,
    bool isPublic = false,
  }) async {
    final repository = RepositoryModel(
      name: name,
      description: description,
      userId: userId,
      isPublic: isPublic,
      isActive: true,
      boxIds: [],
    );

    await _databaseService.insert('repositories', repository.toMap());
    return repository;
  }

  Future<RepositoryModel?> getRepository(String id) async {
    try {
      final result = await _databaseService.rawQuery(
        'SELECT * FROM repositories WHERE id = ?',
        [id],
      );

      if (result.isEmpty) {
        return null;
      }

      return RepositoryModel.fromMap(result.first);
    } catch (e) {
      debugPrint('获取仓库失败: $e');
      return null;
    }
  }

  Future<RepositoryModel> updateRepository({
    required String id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    final repository = await getRepository(id);
    if (repository == null) {
      throw Exception('Repository not found');
    }

    final updatedRepository = repository.copyWith(
      name: name,
      description: description,
      isPublic: isPublic,
    );

    await _databaseService.rawUpdate(
      'UPDATE repositories SET name = ?, description = ?, isPublic = ? WHERE id = ?',
      [
        updatedRepository.name,
        updatedRepository.description,
        updatedRepository.isPublic ? 1 : 0,
        id
      ],
    );

    return updatedRepository;
  }

  Future<RepositoryModel> createFamilyRepository({
    required String name,
    String? description,
    required String userId,
    bool isPublic = false,
  }) async {
    final repository = RepositoryModel(
      name: name,
      description: description,
      userId: userId,
      isPublic: isPublic,
      isActive: true,
      boxIds: [],
    );

    await _databaseService.insert('repositories', repository.toMap());
    return repository;
  }

  Future<RepositoryModel> updateFamilyRepository({
    required String id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    final repository = await getRepository(id);
    if (repository == null) {
      throw Exception('Repository not found');
    }

    final updatedRepository = repository.copyWith(
      name: name,
      description: description,
      isPublic: isPublic,
    );

    await _databaseService.rawUpdate(
      'UPDATE repositories SET name = ?, description = ?, isPublic = ? WHERE id = ?',
      [
        updatedRepository.name,
        updatedRepository.description,
        updatedRepository.isPublic ? 1 : 0,
        id
      ],
    );

    return updatedRepository;
  }

  Future<RepositoryModel> createPersonalRepository({
    required String name,
    String? description,
    required String userId,
    bool isPublic = false,
  }) async {
    final repository = RepositoryModel(
      name: name,
      description: description,
      userId: userId,
      isPublic: isPublic,
      isActive: true,
      boxIds: [],
    );

    await _databaseService.insert('repositories', repository.toMap());
    return repository;
  }

  Future<RepositoryModel> updatePersonalRepository({
    required String id,
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    final repository = await getRepository(id);
    if (repository == null) {
      throw Exception('Repository not found');
    }

    final updatedRepository = repository.copyWith(
      name: name,
      description: description,
      isPublic: isPublic,
    );

    await _databaseService.rawUpdate(
      'UPDATE repositories SET name = ?, description = ?, isPublic = ? WHERE id = ?',
      [
        updatedRepository.name,
        updatedRepository.description,
        updatedRepository.isPublic ? 1 : 0,
        id
      ],
    );

    return updatedRepository;
  }

  void showCreateRepositoryDialog() {
    debugPrint('开始显示创建仓库对话框');
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final currentUserId = _authController.currentUser?.id;

    debugPrint('当前用户ID: $currentUserId');
    if (currentUserId == null) {
      debugPrint('用户未登录，显示错误提示');
      Get.snackbar(
        '错误',
        '请先登录',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    // 检查订阅限制
    final subscription = _subscriptionController.subscription;
    if (subscription == null) {
      debugPrint('未找到订阅信息');
      Get.snackbar(
        '错误',
        '未找到订阅信息，请先登录或检查订阅状态',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
      return;
    }

    // 检查仓库数量限制
    final currentRepositoryCount = _repositories.length;
    debugPrint('当前仓库数量: $currentRepositoryCount');
    if (currentRepositoryCount >= subscription.maxRepositories) {
      debugPrint('已达到仓库数量限制');
      Get.snackbar(
        '提示',
        '当前订阅类型（${_subscriptionController.getSubscriptionTypeName(subscription.type)}）最多支持 ${subscription.maxRepositories} 个仓库，请升级订阅以创建更多仓库',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange[100],
        colorText: Colors.orange[900],
        mainButton: TextButton(
          onPressed: () => Get.toNamed('/subscription'),
          child: const Text('升级订阅'),
        ),
      );
      return;
    }

    try {
      Get.dialog(
        AlertDialog(
          title: const Text('创建新仓库'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '仓库名称',
                  hintText: '请输入仓库名称',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '仓库描述',
                  hintText: '请输入仓库描述（可选）',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                nameController.dispose();
                descriptionController.dispose();
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  Get.snackbar(
                    '错误',
                    '请输入仓库名称',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                try {
                  debugPrint('开始创建仓库');
                  final repository = RepositoryModel(
                    name: nameController.text,
                    description: descriptionController.text,
                    userId: currentUserId.toString(),
                    isPublic: false,
                    isActive: true,
                    boxIds: [],
                  );

                  debugPrint('调用createRepository方法');
                  await createRepository(
                    name: repository.name,
                    description: repository.description,
                    userId: repository.userId,
                    isPublic: repository.isPublic,
                  );
                  debugPrint('createRepository方法调用成功');

                  // 先关闭对话框
                  Get.back();

                  // 然后释放控制器
                  nameController.dispose();
                  descriptionController.dispose();

                  // 最后刷新仓库列表和显示提示
                  await loadRepositories();
                  Get.snackbar(
                    '成功',
                    '仓库创建成功',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } catch (e) {
                  debugPrint('创建仓库失败: $e');
                  debugPrint('错误堆栈: ${StackTrace.current}');
                  Get.snackbar(
                    '错误',
                    '创建仓库失败：${e.toString()}',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                    backgroundColor: Colors.red[100],
                    colorText: Colors.red[900],
                  );
                }
              },
              child: const Text('创建'),
            ),
          ],
        ),
      );
      debugPrint('对话框显示成功');
    } catch (e) {
      debugPrint('显示对话框时发生错误: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
      Get.snackbar(
        '错误',
        '显示创建仓库对话框失败：${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> _createDefaultRepository() async {
    try {
      debugPrint('开始创建默认仓库...');
      final currentUserId = _authController.currentUser?.id;
      if (currentUserId == null) {
        throw Exception('用户未登录');
      }

      // 创建默认仓库
      final repository = RepositoryModel(
        name: '默认仓库',
        description: '这是一个默认仓库，包含一些示例盒子',
        userId: currentUserId.toString(),
        isPublic: false,
        isActive: true,
        boxIds: [],
      );

      debugPrint('保存默认仓库到数据库...');
      await _databaseService.insert('repositories', repository.toMap());
      debugPrint('默认仓库创建成功');

      // 创建默认盒子
      final boxTypes = [BoxType.CUSTOM, BoxType.WARDROBE, BoxType.BOOKSHELF];
      final boxNames = ['自定义盒子', '待办盒子', '笔记盒子'];
      final boxDescriptions = [
        '这是一个自定义盒子，可以存放各种类型的物品',
        '这是一个待办盒子，用于管理待办事项',
        '这是一个笔记盒子，用于记录重要笔记'
      ];

      for (var i = 0; i < 3; i++) {
        debugPrint('创建默认盒子 ${i + 1}...');
        final box = BoxModel(
          name: boxNames[i],
          type: boxTypes[i],
          description: boxDescriptions[i],
          isPublic: false,
          repositoryId: repository.id,
          userId: currentUserId.toString(),
          creatorId: currentUserId.toString(),
          themeColor: '#4A90E2',
          accessLevel: BoxAccessLevel.PRIVATE,
          password: null,
          allowedUserIds: [],
        );

        final boxId = await _databaseService.insertBox(box);
        debugPrint('盒子创建成功，ID: $boxId');

        // 为每个盒子创建默认物品
        await _createDefaultItems(boxId.toString(), boxTypes[i]);
      }

      // 刷新仓库列表
      await loadRepositories();
      debugPrint('默认仓库和盒子创建完成');
    } catch (e) {
      debugPrint('创建默认仓库失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
    }
  }

  Future<void> _createDefaultItems(String boxId, BoxType boxType) async {
    try {
      debugPrint('开始为盒子 $boxId 创建默认物品...');

      List<Map<String, dynamic>> items = [];

      switch (boxType) {
        case BoxType.CUSTOM:
          items = [
            {
              'name': '示例物品1',
              'description': '这是一个示例物品',
              'type': 'custom',
              'status': 'active',
              'priority': 'normal',
              'tags': ['示例', '默认'],
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            {
              'name': '示例物品2',
              'description': '这是另一个示例物品',
              'type': 'custom',
              'status': 'active',
              'priority': 'normal',
              'tags': ['示例', '默认'],
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            {
              'name': '示例物品3',
              'description': '这是第三个示例物品',
              'type': 'custom',
              'status': 'active',
              'priority': 'normal',
              'tags': ['示例', '默认'],
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ];
          break;

        case BoxType.WARDROBE:
          items = [
            {
              'name': '完成项目文档',
              'description': '编写项目说明文档',
              'type': 'todo',
              'status': 'pending',
              'priority': 'high',
              'dueDate':
                  DateTime.now().add(const Duration(days: 7)).toIso8601String(),
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            {
              'name': '代码审查',
              'description': '审查团队成员的代码',
              'type': 'todo',
              'status': 'pending',
              'priority': 'medium',
              'dueDate':
                  DateTime.now().add(const Duration(days: 3)).toIso8601String(),
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            {
              'name': '更新依赖',
              'description': '更新项目依赖到最新版本',
              'type': 'todo',
              'status': 'pending',
              'priority': 'low',
              'dueDate': DateTime.now()
                  .add(const Duration(days: 14))
                  .toIso8601String(),
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ];
          break;

        case BoxType.BOOKSHELF:
          items = [
            {
              'name': '项目计划',
              'description': '项目开发计划和时间安排',
              'type': 'note',
              'content': '1. 需求分析\n2. 设计阶段\n3. 开发阶段\n4. 测试阶段\n5. 部署上线',
              'tags': ['计划', '项目'],
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            {
              'name': '会议记录',
              'description': '团队周会记录',
              'type': 'note',
              'content': '1. 上周工作总结\n2. 本周工作计划\n3. 遇到的问题\n4. 解决方案',
              'tags': ['会议', '记录'],
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
            {
              'name': '学习笔记',
              'description': 'Flutter 学习笔记',
              'type': 'note',
              'content': '1. Widget 生命周期\n2. 状态管理\n3. 路由管理\n4. 数据持久化',
              'tags': ['学习', 'Flutter'],
              'createdAt': DateTime.now().toIso8601String(),
              'updatedAt': DateTime.now().toIso8601String(),
            },
          ];
          break;

        default:
          break;
      }

      // 保存物品到数据库
      for (var item in items) {
        item['boxId'] = boxId;
        await _databaseService.insert('items', item);
      }

      debugPrint('默认物品创建完成');
    } catch (e) {
      debugPrint('创建默认物品失败: $e');
      debugPrint('错误堆栈: ${StackTrace.current}');
    }
  }
}
