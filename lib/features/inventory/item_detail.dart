import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'stock_adjustment_form.dart';

class InventoryItemDetail extends StatelessWidget {
  final InventoryItem item;
  final ValueChanged<int>? onAdjust;
  final VoidCallback? onDelete;

  const InventoryItemDetail({super.key, required this.item, this.onAdjust, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(item.name),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${item.category}'),
            const SizedBox(height: 8),
            Text('Current stock: ${item.stock} ${item.unit}'),
            const SizedBox(height: 8),
            Text('Reorder level: ${item.reorderLevel} ${item.unit}'),
            const SizedBox(height: 12),
            const Text('Stock movements', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            // Mock movement list
            const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.add, color: Colors.green),
                  title: Text('Purchase received'),
                  subtitle: Text('+20 kg • 2 days ago'),
                ),
                ListTile(
                  leading: Icon(Icons.remove, color: Colors.red),
                  title: Text('Used in Chicken Inasal'),
                  subtitle: Text('-5 kg • 1 day ago'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDelete == null ? null : () { Navigator.of(context).pop(); onDelete!(); },
          child: const Text('Delete'),
        ),
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            showModalBottomSheet<int>(
              context: context,
              isScrollControlled: true,
              builder: (_) => StockAdjustmentForm(item: item),
            ).then((change) { if (change != null) onAdjust?.call(change); });
          },
          child: const Text('Adjust Stock'),
        ),
      ],
    );
  }
}
