import 'package:flutter/material.dart';

import '../../core/widgets/responsive.dart';

import '../../core/theme/kainph_theme.dart';

class SystemScreen extends StatelessWidget {
  const SystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const cards = [
      _SystemCard(
          title: 'Backup',
          subtitle: 'Last backup 2 hours ago',
          icon: Icons.backup_outlined,
          accent: KainPHTheme.primary),
      _SystemCard(
          title: 'Restore',
          subtitle: '4 local backup sets',
          icon: Icons.restore_outlined,
          accent: KainPHTheme.success),
      _SystemCard(
          title: 'Data Export',
          subtitle: 'Sales / inventory / customers',
          icon: Icons.download_outlined,
          accent: KainPHTheme.warning),
      _SystemCard(
          title: 'Printer Setup',
          subtitle: 'Thermal printer ready',
          icon: Icons.print_outlined,
          accent: KainPHTheme.danger),
    ];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SYSTEM',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: KainPHTheme.textPrimary)),
              const SizedBox(height: 6),
              const Text(
                  'Offline backups, device management, and maintenance controls.',
                  style: TextStyle(
                      color: KainPHTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Use ResponsiveGrid for consistent KPI behavior
                  return const ResponsiveGrid(children: cards);
                },
              ),
              const SizedBox(height: 24),
              const Text('Sync status',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: KainPHTheme.textPrimary)),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _StatusRow(
                          label: 'Offline mode',
                          value: 'Connected',
                          color: KainPHTheme.success),
                      Divider(),
                      _StatusRow(
                          label: 'Pending sync',
                          value: '3 items',
                          color: KainPHTheme.warning),
                      Divider(),
                      _StatusRow(
                          label: 'Last sync',
                          value: 'Today, 8:10 PM',
                          color: KainPHTheme.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SystemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _SystemCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.accent});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 6),
            Text(subtitle,
                style: const TextStyle(
                    color: KainPHTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatusRow(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: Text(label,
                style: const TextStyle(color: KainPHTheme.textSecondary))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20)),
          child: Text(value,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
