import 'package:flutter/material.dart';
import '../../core/theme/kainph_theme.dart';
import 'mock_data.dart';

class InventoryItemCard extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onTap;

  const InventoryItemCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: KainPHTheme.primary.withValues(alpha: 0.08),
                    child: const Icon(Icons.inventory_2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Stock: ${item.stock} ${item.unit}'),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (item.isOutOfStock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Out of stock', style: TextStyle(color: Colors.red)),
                    )
                  else if (item.isLow)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Low stock', style: TextStyle(color: Colors.orange)),
                    ),
                  const Spacer(),
                  Text('Reorder: ${item.reorderLevel}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
