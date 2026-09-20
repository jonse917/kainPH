import 'package:flutter/material.dart';
import 'dart:io';
import '../theme/kainph_theme.dart';

/// A generic product card used across POS and Menu screens.
class KainPHProductCard extends StatelessWidget {
  final String title;
  final double price;
  final IconData? icon;
  final String? imagePath;
  final bool featured;
  final bool available;
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
    this.onEdit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final image = Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: KainPHTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: imagePath != null && imagePath!.isNotEmpty
                ? Image.file(
                    File(imagePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                  )
                : icon != null
                ? Icon(icon, size: 48, color: KainPHTheme.primary)
                : const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
          );
          // Grid tiles have a bounded height, but ListView rows do not. Using
          // Expanded in an unbounded row prevents the whole Menu list from
          // laying out on phones.
          final imageSection = constraints.maxHeight.isFinite
              ? Expanded(child: image)
              : SizedBox(height: 116, child: image);
          return InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              imageSection,
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                    maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      tooltip: 'Edit',
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '₱${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: KainPHTheme.primary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (featured)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: KainPHTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Featured',
                        style: TextStyle(color: KainPHTheme.primary, fontSize: 12),
                      ),
                    ),
                  if (!available)
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Unavailable',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
          );
        },
      ),
    );
  }
}
