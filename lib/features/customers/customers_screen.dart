import 'package:flutter/material.dart';

import '../../core/theme/kainph_theme.dart';
import '../../core/widgets/responsive.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customerData = <Map<String, dynamic>>[
      {'name': 'Alma Santos', 'spent': '₱18,900', 'visits': 42, 'points': 640, 'status': 'Returning'},
      {'name': 'Rico Dela Cruz', 'spent': '₱12,160', 'visits': 31, 'points': 510, 'status': 'Loyal'},
      {'name': 'Maya Ramos', 'spent': '₱9,440', 'visits': 18, 'points': 340, 'status': 'Birthday'},
    ];

    const summaryCards = [
      _SummaryCard(title: 'Total Customers', value: '1,284', detail: '+64 this month', icon: Icons.people_alt_outlined, accent: KainPHTheme.primary),
      _SummaryCard(title: 'Returning', value: '742', detail: '57.8% retention', icon: Icons.repeat_outlined, accent: KainPHTheme.success),
      _SummaryCard(title: 'Loyalty Members', value: '412', detail: 'Active rewards', icon: Icons.stars_outlined, accent: KainPHTheme.warning),
      _SummaryCard(title: 'Recent', value: '98', detail: 'Last 7 days', icon: Icons.access_time_outlined, accent: KainPHTheme.danger),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Customers', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: KainPHTheme.textPrimary)),
            const SizedBox(height: 6),
            const Text('Customer profiles, loyalty, and repeat orders.', style: TextStyle(color: KainPHTheme.textSecondary, fontSize: 15)),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                if (width < 600) {
                  // Stack cards vertically for narrow screens (phone portrait)
                  return Wrap(
                    runSpacing: 12,
                    children: summaryCards
                        .map((card) => SizedBox(width: width, child: card))
                        .toList(),
                  );
                }

                // Responsive grid for summary KPI cards
                return const ResponsiveGrid(children: summaryCards);
              },
            ),
            const SizedBox(height: 24),
            const Text('Recent customers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: KainPHTheme.textPrimary)),
            const SizedBox(height: 12),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: customerData.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final customer = customerData[index];
                  final name = customer['name'] as String;
                  final spent = customer['spent'] as String;
                  final visits = customer['visits'] as int;
                  final points = customer['points'] as int;
                  final status = customer['status'] as String;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: KainPHTheme.primary.withValues(alpha: 0.1),
                      child: Text(name.substring(0, 1)),
                    ),
                    title: Text(name),
                    subtitle: Text('$visits visits • $points pts'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(spent, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: status == 'Birthday'
                                ? KainPHTheme.warning.withValues(alpha: 0.12)
                                : KainPHTheme.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: status == 'Birthday' ? KainPHTheme.warning : KainPHTheme.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
  });

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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: KainPHTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: KainPHTheme.textPrimary)),
            const SizedBox(height: 4),
            Text(detail, style: const TextStyle(fontSize: 11, color: KainPHTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
