import 'package:flutter/material.dart';
import 'mock_data.dart';

class ProductDetail extends StatelessWidget {
  final MenuProduct product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductDetail({super.key, required this.product, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.image, size: 28),
          const SizedBox(width: 10),
          Expanded(child: Text(product.name)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 120, maxHeight: 240),
              child: Container(
                width: double.infinity,
                color: Colors.grey.shade200,
                child: const Center(child: Icon(Icons.image, size: 56, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Price: ₱${product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Category: ${product.category}'),
            const SizedBox(height: 8),
            Text('Available: ${product.available ? 'Yes' : 'No'}'),
            const SizedBox(height: 8),
            if (product.variants.isNotEmpty) ...[
              const Text('Variants', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: product.variants.map((v) => Chip(label: Text(v))).toList(),
              ),
              const SizedBox(height: 8),
            ],
            if (product.modifiers.isNotEmpty) ...[
              const Text('Modifiers', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: product.modifiers.map((v) => Chip(label: Text(v))).toList(),
              ),
              const SizedBox(height: 8),
            ],
            if (product.description.isNotEmpty) ...[
              const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(product.description),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () { Navigator.of(context).pop(); onDelete?.call(); },
          child: const Text('Delete'),
        ),
        ElevatedButton(
          onPressed: () { Navigator.of(context).pop(); onEdit?.call(); },
          child: const Text('Edit'),
        ),
      ],
    );
  }
}
