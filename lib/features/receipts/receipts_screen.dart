import 'package:flutter/material.dart';

import '../../core/theme/kainph_theme.dart';

class ReceiptsScreen extends StatelessWidget {
  const ReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('RECEIPTS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: KainPHTheme.textPrimary)),
            const SizedBox(height: 6),
            const Text('Receipt designer, thermal printing, and reprints.', style: TextStyle(color: KainPHTheme.textSecondary, fontSize: 15)),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 900) {
                  return Column(
                    children: [
                      _receiptPreview(),
                      const SizedBox(height: 12),
                      _printerPanel(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _receiptPreview()),
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: _printerPanel(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Receipt Designer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KAINPH CAFE', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('123 J. P. Rizal St., Cabanatuan', style: TextStyle(color: KainPHTheme.textSecondary)),
                  Divider(),
                  Row(
                    children: [
                      Expanded(child: Text('Chicken Inasal')),
                      Text('₱120.00'),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('Pancit Canton')),
                      Text('₱150.00'),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(child: Text('Soft Drink')),
                      Text('₱40.00'),
                    ],
                  ),
                  Divider(),
                  Row(children: [Expanded(child: Text('Subtotal')), Text('₱310.00')]),
                  Row(children: [Expanded(child: Text('Discount')), Text('-₱30.00')]),
                  Row(children: [Expanded(child: Text('Tax')), Text('₱22.00')]),
                  SizedBox(height: 8),
                  Row(children: [Expanded(child: Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold))), Text('₱302.00', style: TextStyle(fontWeight: FontWeight.bold))]),
                  SizedBox(height: 10),
                  Text('Thank you for choosing KainPH!', textAlign: TextAlign.center, style: TextStyle(color: KainPHTheme.textSecondary)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _printerPanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Thermal Printing', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const _StatusRow(label: 'Printer status', value: 'Connected', status: KainPHTheme.success),
            const _StatusRow(label: 'Paper size', value: '80mm', status: KainPHTheme.primary),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print_outlined),
              label: const Text('Test print'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonalIcon(
              onPressed: () {},
              icon: const Icon(Icons.history_outlined),
              label: const Text('Reprint'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color status;

  const _StatusRow({required this.label, required this.value, required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: KainPHTheme.textSecondary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: status.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(value, style: TextStyle(color: status, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
