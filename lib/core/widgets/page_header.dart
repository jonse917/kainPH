import 'package:flutter/material.dart';

import '../theme/kainph_theme.dart';

class KainPHPageHeader extends StatelessWidget {
  const KainPHPageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.1,
                  letterSpacing: -0.4,
                  fontWeight: FontWeight.w600,
                  color: KainPHTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  color: KainPHTheme.textSecondary,
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        if (actions.isNotEmpty) ...[
          const SizedBox(width: 12),
          Wrap(spacing: 8, runSpacing: 8, children: actions),
        ],
      ],
    );
  }
}

class KainPHSectionTitle extends StatelessWidget {
  const KainPHSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w600,
        color: KainPHTheme.textPrimary,
      ),
    );
  }
}
