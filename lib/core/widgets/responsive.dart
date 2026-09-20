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
      // Decide columns based on width
      int columns;
      if (width < 480) {
        columns = minColumns; // mostly single or two columns on narrow phones
      } else if (width < 800) {
        columns = minColumns;
      } else if (width < 1100) {
        columns = (minColumns + 1).clamp(minColumns, maxColumns);
      } else {
        columns = maxColumns;
      }

      // Leave enough vertical room for card content. The previous, wider ratios
      // made summary and product cards too short on phones, which could cause a
      // RenderFlex overflow when text wrapped or the user increased text size.
      double childAspectRatio;
      if (width < 480) {
        childAspectRatio = 1.15;
      } else if (width < 800) {
        childAspectRatio = 1.25;
      } else if (width < 1100) {
        childAspectRatio = 1.4;
      } else {
        childAspectRatio = 1.5;
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: children.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (context, index) => children[index],
      );
    });
  }
}
