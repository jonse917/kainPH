import 'package:flutter/material.dart';

import '../../core/theme/kainph_theme.dart';
import 'appearance_settings_screen.dart';
import 'tax_receipt_settings_screen.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _SettingsTile(
        title: 'Appearance',
        subtitle: 'Theme, branding, density, and dashboard preferences.',
        icon: Icons.palette_outlined,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AppearanceSettingsScreen(),
            ),
          );
        },
      ),
      _SettingsTile(
        title: 'Tax & Receipt Settings',
        subtitle: 'Receipt details, tax treatment, and receipt format.',
        icon: Icons.receipt_long_outlined,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const TaxReceiptSettingsScreen(),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: KainPHTheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.settings_outlined,
                                color: KainPHTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Business Settings',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  Text(
                                    'Customize the KainPH experience while keeping the default design system intact.',
                                    style: TextStyle(color: KainPHTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _SettingsColumn(items: items),
                          ),
                        ],
                      )
                    else
                      _SettingsColumn(items: items),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SettingsColumn extends StatelessWidget {
  final List<_SettingsTile> items;

  const _SettingsColumn({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Card(
            child: ListTile(
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: KainPHTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  items[i].icon,
                  color: KainPHTheme.primary,
                ),
              ),
              title: Text(items[i].title),
              subtitle: Text(items[i].subtitle),
              trailing: const Icon(Icons.chevron_right),
              onTap: items[i].onTap,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _SettingsTile {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}
