import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vote_controller.dart';
import '../models/vote_model.dart';

class VotePage extends StatelessWidget {
  final VoteController _controller = Get.put(VoteController());

  VotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('投票'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '进行中'),
              Tab(text: '已结束'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateVoteDialog(),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildVoteList('active'),
            _buildVoteList('ended'),
          ],
        ),
      ),
    );
  }

  Widget _buildVoteList(String status) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final votes = _controller.votes.where((v) => v.status == status).toList();
      if (votes.isEmpty) {
        return Center(
          child: Text(status == 'active' ? '暂无进行中的投票' : '暂无已结束的投票'),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: votes.length,
        itemBuilder: (context, index) {
          final vote = votes[index];
          return _buildVoteCard(vote);
        },
      );
    });
  }

  Widget _buildVoteCard(VoteModel vote) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showVoteDetails(vote),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      vote.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(vote.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                vote.description,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '开始时间：${_formatDate(vote.startTime)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '结束时间：${_formatDate(vote.endTime)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '总票数：${vote.totalVotes}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  if (vote.isMultipleChoice)
                    const Text(
                      '多选',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  if (vote.isAnonymous)
                    const Text(
                      '匿名',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVoteDetails(VoteModel vote) async {
    await _controller.loadVoteDetails(vote.id!);
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      vote.title,
                      style: const TextStyle(
                        fontSize: 18,
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
              Text(
                vote.description,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              if (vote.status == 'active' && !_controller.hasVoted())
                _buildVoteOptions(vote)
              else
                _buildVoteResults(vote),
              const SizedBox(height: 16),
              if (vote.status == 'active' &&
                  vote.creatorId == _controller.currentUser?.id)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                        _controller.cancelVote(vote.id!);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('取消投票'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _controller.endVote(vote.id!);
                      },
                      child: const Text('结束投票'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoteOptions(VoteModel vote) {
    return Obx(() {
      final options = _controller.options;
      final selectedOptionIds = <int>{};

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '请选择：',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...options.map((option) {
            return CheckboxListTile(
              title: Text(option.content),
              value: selectedOptionIds.contains(option.id),
              onChanged: (value) {
                if (value ?? false) {
                  if (vote.isMultipleChoice) {
                    selectedOptionIds.add(int.parse(option.id));
                  } else {
                    selectedOptionIds.clear();
                    selectedOptionIds.add(int.parse(option.id));
                  }
                } else {
                  selectedOptionIds.remove(option.id);
                }
              },
            );
          }),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (selectedOptionIds.isEmpty) {
                  Get.snackbar(
                    '错误',
                    '请至少选择一个选项',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }
                Get.back();
                _controller.vote(selectedOptionIds.toList());
              },
              child: const Text('提交'),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildVoteResults(VoteModel vote) {
    return Obx(() {
      final options = _controller.options;
      final votedOptionIds = _controller.getVotedOptionIds();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '投票结果：',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...options.map((option) {
            final percentage = _controller.getOptionPercentage(option);
            final isVoted = votedOptionIds.contains(option.id);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        option.content,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isVoted ? FontWeight.bold : FontWeight.normal,
                          color: isVoted ? Colors.blue : Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isVoted ? Colors.blue : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
          Text(
            '总票数：${vote.totalVotes}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      );
    });
  }

  void _showCreateVoteDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final optionControllers = <TextEditingController>[
      TextEditingController(),
      TextEditingController(),
    ];
    final isMultipleChoice = false.obs;
    final isAnonymous = false.obs;
    DateTime? startTime;
    DateTime? endTime;

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('创建投票'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '标题',
                  hintText: '请输入投票标题',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述',
                  hintText: '请输入投票描述',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            startTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          }
                        }
                      },
                      child: Text(startTime == null
                          ? '选择开始时间'
                          : _formatDate(startTime!)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            endTime = DateTime(
                              date.year,
                              date.month,
                              date.day,
                              time.hour,
                              time.minute,
                            );
                          }
                        }
                      },
                      child: Text(
                          endTime == null ? '选择结束时间' : _formatDate(endTime!)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => CheckboxListTile(
                    title: const Text('允许多选'),
                    value: isMultipleChoice.value,
                    onChanged: (value) {
                      isMultipleChoice.value = value ?? false;
                    },
                  )),
              Obx(() => CheckboxListTile(
                    title: const Text('匿名投票'),
                    value: isAnonymous.value,
                    onChanged: (value) {
                      isAnonymous.value = value ?? false;
                    },
                  )),
              const SizedBox(height: 16),
              const Text(
                '选项：',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...optionControllers.map((controller) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: '选项',
                      hintText: '请输入选项内容',
                    ),
                  ),
                );
              }),
              TextButton(
                onPressed: () {
                  optionControllers.add(TextEditingController());
                },
                child: const Text('添加选项'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty) {
                Get.snackbar(
                  '错误',
                  '请输入投票标题',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              if (descriptionController.text.isEmpty) {
                Get.snackbar(
                  '错误',
                  '请输入投票描述',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              if (startTime == null) {
                Get.snackbar(
                  '错误',
                  '请选择开始时间',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              if (endTime == null) {
                Get.snackbar(
                  '错误',
                  '请选择结束时间',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              if (endTime!.isBefore(startTime!)) {
                Get.snackbar(
                  '错误',
                  '结束时间不能早于开始时间',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              final optionContents = optionControllers
                  .map((controller) => controller.text)
                  .where((text) => text.isNotEmpty)
                  .toList();

              if (optionContents.length < 2) {
                Get.snackbar(
                  '错误',
                  '请至少添加两个选项',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              Get.back();
              _controller.createVote(
                title: titleController.text,
                description: descriptionController.text,
                startTime: startTime!,
                endTime: endTime!,
                isMultipleChoice: isMultipleChoice.value,
                isAnonymous: isAnonymous.value,
                optionContents: optionContents,
              );
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;

    switch (status) {
      case 'active':
        color = Colors.green;
        text = '进行中';
        break;
      case 'ended':
        color = Colors.orange;
        text = '已结束';
        break;
      case 'cancelled':
        color = Colors.red;
        text = '已取消';
        break;
      default:
        color = Colors.grey;
        text = '未知';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
