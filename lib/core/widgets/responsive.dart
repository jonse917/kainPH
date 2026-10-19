import 'package:flutter/material.dart';

/// Centralized responsive helper for KainPH.
/// Use LayoutBuilder / constraints to decide breakpoints rather than fixed device checks.
class KainPHResponsive {
  const KainPHResponsive._();

  static bool isPhone(BoxConstraints constraints) => constraints.maxWidth < 600;
  static bool isTablet(BoxConstraints constraints) => constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
  static bool isDesktop(BoxConstraints constraints) => constraints.maxWidth >= 1024;

  /// Helper that returns a compact flag when either width or height is constrained.
  static bool isCompact(BoxConstraints constraints) {
    return constraints.maxWidth < 600 || constraints.maxHeight < 420;
  }
}

/// ResponsiveGrid adapts column count and child aspect ratio based on available constraints.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final int minColumns;
  final int maxColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 12.0,
    this.minColumns = 2,
    this.maxColumns = 4,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      int columns;
      if (width < 800) {
        columns = minColumns;
      } else if (width < 1100) {
        columns = (minColumns + 1).clamp(minColumns, maxColumns);
      } else {
        columns = maxColumns;
      }

      // Size tiles by their content. A fixed aspect ratio made summary cards
      // shorter than their text and painted yellow overflow stripes.
      final itemWidth = (width - spacing * (columns - 1)) / columns;

      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final child in children)
            SizedBox(width: itemWidth, child: child),
        ],
      );
    });
  }
}
