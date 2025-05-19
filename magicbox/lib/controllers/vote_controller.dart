import 'package:get/get.dart';
import '../models/vote_model.dart' as vote_model;
import '../models/vote_option_model.dart' as option_model;
import '../models/vote_record_model.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class VoteController extends GetxController {
  final DatabaseService _databaseService = Get.find<DatabaseService>();
  final UserModel? currentUser = Get.find<UserModel?>();

  final RxList<vote_model.VoteModel> votes = <vote_model.VoteModel>[].obs;
  final RxList<option_model.VoteOptionModel> options =
      <option_model.VoteOptionModel>[].obs;
  final RxList<VoteRecordModel> records = <VoteRecordModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentChannelId = 0.obs;
  final Rx<vote_model.VoteModel?> currentVote = Rx<vote_model.VoteModel?>(null);

  @override
  void onInit() {
    super.onInit();
    ever(currentChannelId, (_) => loadVotes());
  }

  Future<void> loadVotes() async {
    if (currentChannelId.value == 0) return;

    try {
      isLoading.value = true;
      votes.value = await _databaseService
          .getChannelVotes(currentChannelId.value.toString());
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
      currentVote.value = await _databaseService.getVote(voteId.toString());
      if (currentVote.value != null) {
        final optionsList =
            await _databaseService.getVoteOptions(voteId.toString());
        options.value = optionsList.cast<option_model.VoteOptionModel>();
        if (currentUser != null) {
          final recordsList = await _databaseService.getUserVoteRecords(
            currentUser!.id!.toString(),
            voteId.toString(),
          );
          records.value = recordsList.cast<VoteRecordModel>();
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
      final newVote = vote_model.VoteModel(
        id: DateTime.now().millisecondsSinceEpoch,
        channelId: currentChannelId.value,
        creatorId: int.parse(currentUser!.id!),
        title: title,
        description: description,
        startTime: startTime,
        endTime: endTime,
        isMultipleChoice: isMultipleChoice,
        isAnonymous: isAnonymous,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final voteId = await _databaseService.createVote(newVote);

      // 创建选项
      for (final content in optionContents) {
        final newOption = option_model.VoteOptionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          voteId: voteId,
          content: content,
          voteCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _databaseService.createVoteOption(newOption);
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
        currentUser!.id!.toString(),
        currentVote.value!.id!.toString(),
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
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        voteId: currentVote.value!.id!.toString(),
        optionId: optionIds.first.toString(),
        userId: currentUser!.id!.toString(),
        createdAt: DateTime.now(),
      );
      await _databaseService.createVoteRecord(record);

      // 更新选项票数
      for (final optionId in optionIds) {
        final option = options.firstWhere((o) => o.id == optionId.toString());
        await _databaseService.updateVoteOptionCount(
          optionId.toString(),
          option.voteCount + 1,
        );
      }

      // 更新总票数
      await _databaseService.updateVoteTotalVotes(
        currentVote.value!.id!.toString(),
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

    final vote = await _databaseService.getVote(voteId.toString());
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
      await _databaseService.updateVoteStatus(voteId.toString(), 'ended');
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

    final vote = await _databaseService.getVote(voteId.toString());
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
      await _databaseService.updateVoteStatus(voteId.toString(), 'cancelled');
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
    return records.map((record) => int.parse(record.optionId)).toList();
  }

  double getOptionPercentage(option_model.VoteOptionModel option) {
    if (currentVote.value == null || currentVote.value!.totalVotes == 0) {
      return 0;
    }
    return option.voteCount / currentVote.value!.totalVotes * 100;
  }
}
