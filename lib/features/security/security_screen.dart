import 'package:flutter/material.dart';

import '../../core/theme/kainph_theme.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const roles = [
      _Role('Owner', 'Full access'),
      _Role('Manager', 'Inventory + sales + discounts'),
      _Role('Cashier', 'POS + receipts'),
      _Role('Custom Role', 'Custom permission set'),
    ];

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SECURITY', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: KainPHTheme.textPrimary)),
            const SizedBox(height: 6),
            const Text('Staff PIN, permissions, audit logs, and approval workflows.', style: TextStyle(color: KainPHTheme.textSecondary, fontSize: 15)),
            const SizedBox(height: 20),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Staff PIN', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text('Active staff', style: TextStyle(color: KainPHTheme.textSecondary)),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        _PinChip('Mia', 'Active'),
                        SizedBox(width: 8),
                        _PinChip('Jerome', 'Active'),
                        SizedBox(width: 8),
                        _PinChip('Ana', 'Reset'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Roles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: KainPHTheme.textPrimary)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: roles
                  .map((role) => ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(role.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(role.access, style: const TextStyle(color: KainPHTheme.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
            const Text('Permissions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: KainPHTheme.textPrimary)),
            const SizedBox(height: 12),
            const Card(
              child: Column(
                children: [
                  _PermissionRow(label: 'Void transactions', enabled: true),
                  _PermissionRow(label: 'Discount approval', enabled: true),
                  _PermissionRow(label: 'Adjust stock', enabled: false),
                  _PermissionRow(label: 'View audit logs', enabled: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PinChip extends StatelessWidget {
  final String name;
  final String status;

  const _PinChip(this.name, this.status);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: KainPHTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('$name • $status', style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}

class _Role {
  final String name;
  final String access;

  const _Role(this.name, this.access);
}

class _PermissionRow extends StatelessWidget {
  final String label;
  final bool enabled;

  const _PermissionRow({required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label),
      value: enabled,
      onChanged: (_) {},
      activeThumbColor: KainPHTheme.primary,
    );
  }
}
