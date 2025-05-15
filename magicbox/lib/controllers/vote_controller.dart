import 'package:get/get.dart';
import '../services/database_service.dart';
import '../models/vote_model.dart';
import '../models/vote_option_model.dart';
import '../models/vote_record_model.dart';
import '../models/user_model.dart';

class VoteController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel? currentUser = Get.find<UserModel?>();

  final RxList<VoteModel> votes = <VoteModel>[].obs;
  final RxList<VoteOptionModel> options = <VoteOptionModel>[].obs;
  final RxList<VoteRecordModel> records = <VoteRecordModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentChannelId = 0.obs;
  final Rx<VoteModel?> currentVote = Rx<VoteModel?>(null);

  @override
  void onInit() {
    super.onInit();
    ever(currentChannelId, (_) => loadVotes());
  }

  Future<void> loadVotes() async {
    if (currentChannelId.value == 0) return;

    try {
      isLoading.value = true;
      votes.value = await _databaseService.getChannelVotes(currentChannelId.value);
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载投票列表失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadVoteDetails(int voteId) async {
    try {
      isLoading.value = true;
      currentVote.value = await _databaseService.getVote(voteId);
      if (currentVote.value != null) {
        options.value = await _databaseService.getVoteOptions(voteId);
        if (currentUser != null) {
          records.value = await _databaseService.getUserVoteRecords(currentUser!.id!, voteId);
        }
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '加载投票详情失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createVote({
    required String title,
    required String description,
    required DateTime startTime,
    required DateTime endTime,
    required bool isMultipleChoice,
    required bool isAnonymous,
    required List<String> optionContents,
  }) async {
    if (currentUser == null) {
      Get.snackbar(
        '错误',
        '请先登录',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 创建投票
      final vote = VoteModel(
        channelId: currentChannelId.value,
        creatorId: currentUser!.id!,
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        isMultipleChoice: isMultipleChoice,
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final voteId = await _databaseService.createVote(vote);

      // 创建选项
      for (final content in optionContents) {
        final option = VoteOptionModel(
          voteId: voteId,
          content: content,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _databaseService.createVoteOption(option);
      }

      Get.snackbar(
        '成功',
        '创建投票成功',
        snackPosition: SnackPosition.BOTTOM,
      );
      loadVotes();
    } catch (e) {
      Get.snackbar(
        '错误',
        '创建投票失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> vote(List<int> optionIds) async {
    if (currentUser == null) {
      Get.snackbar(
        '错误',
        '请先登录',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (currentVote.value == null) {
      Get.snackbar(
        '错误',
        '投票不存在',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (currentVote.value!.status != 'active') {
      Get.snackbar(
        '错误',
        '投票已结束',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (DateTime.now().isBefore(currentVote.value!.startTime)) {
      Get.snackbar(
        '错误',
        '投票未开始',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (DateTime.now().isAfter(currentVote.value!.endTime)) {
      Get.snackbar(
        '错误',
        '投票已结束',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (!currentVote.value!.isMultipleChoice && optionIds.length > 1) {
      Get.snackbar(
        '错误',
        '该投票不支持多选',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 检查是否已投票
      final userRecords = await _databaseService.getUserVoteRecords(
        currentUser!.id!,
        currentVote.value!.id!,
      );
      if (userRecords.isNotEmpty) {
        Get.snackbar(
          '错误',
          '您已经投过票了',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // 创建投票记录
      final record = VoteRecordModel(
        voteId: currentVote.value!.id!,
        userId: currentUser!.id!,
        optionIds: optionIds,
        createdAt: DateTime.now(),
      );
      await _databaseService.createVoteRecord(record);

      // 更新选项票数
      for (final optionId in optionIds) {
        final option = options.firstWhere((o) => o.id == optionId);
        await _databaseService.updateVoteOptionCount(
          optionId,
          option.voteCount + 1,
        );
      }

      // 更新总票数
      await _databaseService.updateVoteTotalVotes(
        currentVote.value!.id!,
        currentVote.value!.totalVotes + 1,
      );

      Get.snackbar(
        '成功',
        '投票成功',
        snackPosition: SnackPosition.BOTTOM,
      );
      loadVoteDetails(currentVote.value!.id!);
    } catch (e) {
      Get.snackbar(
        '错误',
        '投票失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> endVote(int voteId) async {
    if (currentUser == null) {
      Get.snackbar(
        '错误',
        '请先登录',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final vote = await _databaseService.getVote(voteId);
    if (vote == null) {
      Get.snackbar(
        '错误',
        '投票不存在',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (vote.creatorId != currentUser!.id!) {
      Get.snackbar(
        '错误',
        '只有创建者可以结束投票',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _databaseService.updateVoteStatus(voteId, 'ended');
      Get.snackbar(
        '成功',
        '结束投票成功',
        snackPosition: SnackPosition.BOTTOM,
      );
      loadVotes();
    } catch (e) {
      Get.snackbar(
        '错误',
        '结束投票失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelVote(int voteId) async {
    if (currentUser == null) {
      Get.snackbar(
        '错误',
        '请先登录',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final vote = await _databaseService.getVote(voteId);
    if (vote == null) {
      Get.snackbar(
        '错误',
        '投票不存在',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (vote.creatorId != currentUser!.id!) {
      Get.snackbar(
        '错误',
        '只有创建者可以取消投票',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _databaseService.updateVoteStatus(voteId, 'cancelled');
      Get.snackbar(
        '成功',
        '取消投票成功',
        snackPosition: SnackPosition.BOTTOM,
      );
      loadVotes();
    } catch (e) {
      Get.snackbar(
        '错误',
        '取消投票失败：$e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool hasVoted() {
    return records.isNotEmpty;
  }

  List<int> getVotedOptionIds() {
    if (records.isEmpty) return [];
    return records.first.optionIds;
  }

  double getOptionPercentage(VoteOptionModel option) {
    if (currentVote.value == null || currentVote.value!.totalVotes == 0) {
      return 0;
    }
    return option.voteCount / currentVote.value!.totalVotes * 100;
  }
} 