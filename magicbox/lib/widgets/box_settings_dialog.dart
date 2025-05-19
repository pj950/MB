import 'package:flutter/material.dart';
import '../models/box_model.dart';

class BoxSettingsDialog extends StatefulWidget {
  final BoxModel box;
  final Function(BoxModel) onSave;

  const BoxSettingsDialog({
    super.key,
    required this.box,
    required this.onSave,
  });

  @override
  State<BoxSettingsDialog> createState() => _BoxSettingsDialogState();
}

class _BoxSettingsDialogState extends State<BoxSettingsDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late BoxType _selectedType;
  late bool _isPublic;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.box.name);
    _descriptionController =
        TextEditingController(text: widget.box.description);
    _selectedType = widget.box.type;
    _isPublic = widget.box.isPublic;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('仓库设置'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '仓库名称',
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<BoxType>(
              value: _selectedType,
              items: BoxType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
              decoration: const InputDecoration(
                labelText: '仓库类型',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述（选填）',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('公开仓库'),
              value: _isPublic,
              onChanged: (value) {
                setState(() => _isPublic = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('请输入仓库名称')),
              );
              return;
            }
            final updatedBox = widget.box.copyWith(
              name: _nameController.text,
              type: _selectedType,
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              isPublic: _isPublic,
            );
            widget.onSave(updatedBox);
            Navigator.of(context).pop();
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
