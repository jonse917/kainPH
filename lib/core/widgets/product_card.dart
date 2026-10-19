import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/kainph_catalog.dart';
import '../theme/kainph_theme.dart';

/// A generic product card used across POS and Menu screens.
class KainPHProductCard extends StatelessWidget {
  final String title;
  final double price;
  final IconData? icon;
  final String? imagePath;
  final bool featured;
  final bool available;
  final int? stock;
  final int reorderLevel;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  const KainPHProductCard({
    super.key,
    required this.title,
    required this.price,
    this.icon,
    this.imagePath,
    this.featured = false,
    this.available = true,
    this.stock,
    this.reorderLevel = 0,
    this.onEdit,
    this.onTap,
  });

  bool get _outOfStock => stock != null && stock! <= 0;
  bool get _lowStock => stock != null && stock! > 0 && reorderLevel > 0 && stock! <= reorderLevel;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final catalogAsset = KainPHCatalog.assetFor(title);
          final blocked = !available || _outOfStock;
          final image = Stack(
            fit: StackFit.expand,
            children: [
              ColoredBox(
                color: KainPHTheme.surface,
                child: Opacity(
                  opacity: blocked ? 0.45 : 1,
                  child: imagePath != null && imagePath!.isNotEmpty && !kIsWeb
                      ? Image.file(
                          File(imagePath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (_, __, ___) => _fallbackImage(icon, catalogAsset),
                        )
                      : _fallbackImage(icon, catalogAsset),
                ),
              ),
              if (blocked || _lowStock)
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _statusPill(
                    !available
                        ? 'Unavailable'
                        : _outOfStock
                            ? 'Out of stock'
                            : '$stock left',
                    !available || _outOfStock ? KainPHTheme.danger : KainPHTheme.warning,
                  ),
                ),
            ],
          );
          final imageSection = constraints.maxHeight.isFinite
              ? Expanded(child: image)
              : SizedBox(height: 140, width: double.infinity, child: image);
          return InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageSection,
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, letterSpacing: 0.1),
                            ),
                          ),
                          if (onEdit != null)
                            IconButton(
                              onPressed: onEdit,
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.edit, size: 18),
                              tooltip: 'Edit',
                            ),
                        ],
                      ),
                      Text(
                        '₱${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: 0.2,
                          color: KainPHTheme.textPrimary,
                        ),
                      ),
                      if (featured && available && !_outOfStock) ...[
                        const SizedBox(height: 6),
                        const Text(
                          'FEATURED',
                          style: TextStyle(fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w600, color: KainPHTheme.primary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusPill(String label, Color color) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _fallbackImage(IconData? icon, String? catalogAsset) {
    if (catalogAsset != null) {
      return Image.asset(
        catalogAsset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Center(child: Icon(icon ?? Icons.restaurant, size: 40, color: KainPHTheme.primary));
  }
}
