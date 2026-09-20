import 'package:flutter/material.dart';

import '../../core/theme/kainph_theme.dart';
import '../../core/widgets/responsive.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const summaryCards = [
      _SummaryCard(
          title: "Today's Sales",
          value: '₱28,450',
          detail: '+12.4%',
          icon: Icons.trending_up,
          accent: KainPHTheme.primary),
      _SummaryCard(
          title: 'Orders',
          value: '348',
          detail: 'Strong lunch rush',
          icon: Icons.receipt_long_outlined,
          accent: KainPHTheme.success),
      _SummaryCard(
          title: 'Avg. Order',
          value: '₱81.75',
          detail: 'Up ₱6.20',
          icon: Icons.shopping_bag_outlined,
          accent: KainPHTheme.warning),
      _SummaryCard(
          title: 'Gross Profit',
          value: '₱11,540',
          detail: '40.5% margin',
          icon: Icons.pie_chart_outline,
          accent: KainPHTheme.danger),
    ];

    final hourly = [
      {'label': '8', 'value': 15},
      {'label': '10', 'value': 24},
      {'label': '12', 'value': 68},
      {'label': '14', 'value': 43},
      {'label': '16', 'value': 55},
      {'label': '18', 'value': 80},
      {'label': '20', 'value': 62},
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
              const Text('ANALYTICS',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: KainPHTheme.textPrimary)),
              const SizedBox(height: 6),
              const Text('Sales, products, customer, and operational insights.',
                  style: TextStyle(
                      color: KainPHTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  // Use ResponsiveGrid so summary cards adapt to width and text scaling
                  return const ResponsiveGrid(children: summaryCards);
                },
              ),
              const SizedBox(height: 24),
              const Text('Hourly sales',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: KainPHTheme.textPrimary)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  // Allow chart area to size flexibly with a safe minimum height to avoid forcing fixed layout
                  // Use BoxConstraints to allow expanding/shrinking instead of a hard fixed height
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 140),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: hourly.map((entry) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height:
                                      (entry['value'] as int).toDouble() * 2.2,
                                  decoration: BoxDecoration(
                                    color: KainPHTheme.primary
                                        .withValues(alpha: 0.85),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(entry['label'] as String,
                                    style: const TextStyle(
                                        color: KainPHTheme.textSecondary,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Top performers',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: KainPHTheme.textPrimary)),
              const SizedBox(height: 12),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final items = [
                      'Chicken Inasal',
                      'Pancit Canton',
                      'Halo-Halo',
                      'Iced Coffee'
                    ];
                    final values = ['₱6,420', '₱5,980', '₱4,110', '₱3,860'];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            KainPHTheme.primary.withValues(alpha: 0.1),
                        child: Text('${index + 1}'),
                      ),
                      title: Text(items[index]),
                      trailing: Text(values[index],
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;

  const _SummaryCard(
      {required this.title,
      required this.value,
      required this.detail,
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                    color: KainPHTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: KainPHTheme.textPrimary)),
            const SizedBox(height: 4),
            Text(detail,
                style: const TextStyle(
                    fontSize: 11, color: KainPHTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
