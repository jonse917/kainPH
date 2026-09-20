import 'package:flutter/material.dart';
import '../../core/widgets/product_card.dart';
import 'mock_data.dart';
import 'product_detail.dart';

class ProductCard extends StatelessWidget {
  final MenuProduct product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({super.key, required this.product, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return KainPHProductCard(
      title: product.name,
      price: product.price,
      icon: null,
      imagePath: product.imagePath,
      featured: product.featured,
      available: product.available,
      onTap: () => showDialog<void>(
        context: context,
        builder: (_) => ProductDetail(product: product, onEdit: onEdit, onDelete: onDelete),
      ),
      onEdit: onEdit,
    );
  }
}
