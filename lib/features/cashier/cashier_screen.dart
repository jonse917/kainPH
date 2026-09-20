import 'package:flutter/material.dart';

import '../../core/theme/kainph_theme.dart';
import '../../core/widgets/responsive.dart';

class CashierScreen extends StatelessWidget {
  const CashierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const summaryCards = [
      _SummaryCard(
        title: 'Current Session',
        value: 'Open',
        detail: 'Mia • 9:00 AM - ongoing',
        icon: Icons.access_time_filled,
        accent: KainPHTheme.primary,
      ),
      _SummaryCard(
        title: 'Opening Cash',
        value: '₱2,500.00',
        detail: 'Cash drawer started',
        icon: Icons.attach_money,
        accent: KainPHTheme.success,
      ),
      _SummaryCard(
        title: 'Cash Sales',
        value: '₱8,240.00',
        detail: '+₱1,230 today',
        icon: Icons.payments_outlined,
        accent: KainPHTheme.warning,
      ),
      _SummaryCard(
        title: 'Expected Drawer',
        value: '₱10,455.00',
        detail: 'Projected balance',
        icon: Icons.account_balance_wallet_outlined,
        accent: KainPHTheme.danger,
      ),
    ];

    const movements = [
      _Movement('Cash In', '₱500.00', 'Pickup from owner', '10:25 AM'),
      _Movement('Cash Out', '₱180.00', 'Change fund replenishment', '12:45 PM'),
      _Movement('Cash Sales', '₱1,240.00', 'Receipt #1042', '2:30 PM'),
    ];

    final double bottomPad = MediaQuery.of(context).viewInsets.bottom + 16;

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cashier',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: KainPHTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage sessions, cash movement, and end-of-day closing.',
              style: TextStyle(
                color: KainPHTheme.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                return const ResponsiveGrid(children: summaryCards);
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Cash drawer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: KainPHTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current balance',
                      style: TextStyle(
                        color: KainPHTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '₱10,455.00',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.add_circle_outline,
                            label: 'Cash In',
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.remove_circle_outline,
                            label: 'Cash Out',
                            onPressed: () {},
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.lock_clock,
                            label: 'Close Day',
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Session history',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: KainPHTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: movements.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final movement = movements[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: KainPHTheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        movement.type.contains('Cash In')
                            ? Icons.add
                            : movement.type.contains('Cash Out')
                                ? Icons.remove
                                : Icons.payments_outlined,
                        color: KainPHTheme.primary,
                      ),
                    ),
                    title: Text(movement.type),
                    subtitle: Text(movement.note),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          movement.amount,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          movement.time,
                          style: const TextStyle(
                            color: KainPHTheme.textSecondary,
                            fontSize: 11,
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
            Row(
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
                const Spacer(),
                Icon(Icons.arrow_right_alt_rounded, color: accent),
              ],
            ),
            const SizedBox(height: 12),
            Text(title,
                style: const TextStyle(
                  color: KainPHTheme.textSecondary,
                  fontSize: 12,
                )),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: KainPHTheme.textPrimary,
                )),
            const SizedBox(height: 4),
            Text(detail,
                style: const TextStyle(
                  fontSize: 11,
                  color: KainPHTheme.textSecondary,
                )),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _Movement {
  final String type;
  final String amount;
  final String note;
  final String time;

  const _Movement(this.type, this.amount, this.note, this.time);
}
