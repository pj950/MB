import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../utils/date_formatter.dart';

class ExpiryWarningDialog extends StatelessWidget {
  final List<ItemModel> items;
  final VoidCallback onDismiss;

  const ExpiryWarningDialog({
    super.key,
    required this.items,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('即将过期的物品'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final daysUntilExpiry =
                item.expiryDate!.difference(DateTime.now()).inDays;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(item.imagePath),
              ),
              title: Text(item.name),
              subtitle: Text(
                '还有 $daysUntilExpiry 天过期',
                style: TextStyle(
                  color: daysUntilExpiry <= 3 ? Colors.red : Colors.orange,
                ),
              ),
              trailing: Text(
                DateFormatter.formatDate(item.expiryDate!),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('我知道了'),
        ),
      ],
    );
  }
}
