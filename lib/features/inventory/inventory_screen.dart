import 'package:flutter/material.dart';

import '../../core/theme/kainph_theme.dart';
import '../../core/widgets/responsive.dart';
import 'inventory_item_card.dart';
import 'item_detail.dart';
import 'mock_data.dart';
import '../../core/services/kainph_database.dart';
import '../../core/database/app_database.dart';
import 'package:drift/drift.dart' as drift;

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _search = '';
  String _category = 'All';
  List<InventoryItem> _items = const [];

  @override
  void initState() { super.initState(); _loadItems(); }

  Future<void> _loadItems() async {
    final store = KainPHDatabase.instance;
    final rows = await (store.database.select(store.database.inventory)
          ..where((row) => row.isDeleted.equals(false)))
        .get();
    final items = rows.map((row) => InventoryItem(
      id: row.id, name: row.name, category: row.category, unit: row.unit,
      stock: row.quantity, reorderLevel: row.reorderLevel,
    )).toList();
    if (mounted) setState(() => _items = items);
  }

  Future<void> _adjust(InventoryItem item, int change) async {
    await KainPHDatabase.instance.pos.adjustInventory(
      inventoryId: item.id, delta: change, type: change > 0 ? 'adjustment_in' : 'adjustment_out',
    );
    await _loadItems();
  }

  Future<void> _delete(InventoryItem item) async {
    final db = KainPHDatabase.instance.database;
    await (db.update(db.inventory)..where((row) => row.id.equals(item.id)))
        .write(InventoryCompanion(isDeleted: const drift.Value(true), updatedAt: drift.Value(DateTime.now())));
    await _loadItems();
  }

  Future<void> _createItem() async {
    final name = TextEditingController();
    final stock = TextEditingController(text: '0');
    final reorder = TextEditingController(text: '0');
    final item = await showDialog<InventoryItem>(context: context, builder: (context) => AlertDialog(
      title: const Text('Add stock item'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: name, decoration: const InputDecoration(labelText: 'Item name')),
        TextField(controller: stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Opening stock')),
        TextField(controller: reorder, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reorder level')),
      ]),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () {
        final opening = int.tryParse(stock.text); final level = int.tryParse(reorder.text);
        if (name.text.trim().isEmpty || opening == null || level == null) return;
        Navigator.pop(context, InventoryItem(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name.text.trim(), category: 'Ingredients', unit: 'pcs', stock: opening, reorderLevel: level));
      }, child: const Text('Add'))],
    ));
    name.dispose(); stock.dispose(); reorder.dispose();
    if (item == null) return;
    final now = DateTime.now();
    await KainPHDatabase.instance.database.into(KainPHDatabase.instance.database.inventory).insert(
      InventoryCompanion.insert(id: item.id, name: item.name, category: item.category, unit: item.unit,
        quantity: drift.Value(item.stock), reorderLevel: drift.Value(item.reorderLevel), createdAt: now, updatedAt: now),
    );
    await _loadItems();
  }

  List<InventoryItem> get _filtered {
    final q = _search.trim().toLowerCase();
    final base = _category == 'All'
        ? _items
        : _items.where((item) => item.category == _category).toList();

    if (q.isEmpty) return base;

    return base.where((item) {
      return item.name.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    final lowStock = _items.where((item) => item.isLow).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inventory',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: KainPHTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Stock overview, purchasing and movement tracking.',
                style: TextStyle(
                  color: KainPHTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  final shouldWrap = constraints.maxWidth < 520;

                  if (shouldWrap) {
                    return Wrap(
                      runSpacing: 12,
                      spacing: 12,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth,
                          child: TextField(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: 'Search stock',
                            ),
                            onChanged: (value) => setState(() => _search = value),
                          ),
                        ),
                        DropdownButton<String>(
                          value: _category,
                          items: inventoryCategories
                              .map((category) => DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _category = value ?? 'All'),
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search stock',
                          ),
                          onChanged: (value) => setState(() => _search = value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _category,
                        items: inventoryCategories
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _category = value ?? 'All'),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  const cards = [
                    _SummaryCard(
                      title: 'Total Stock',
                      value: '38',
                      detail: 'Units tracked',
                      icon: Icons.widgets_outlined,
                      accent: KainPHTheme.primary,
                    ),
                    _SummaryCard(
                      title: 'Low Stock',
                      value: '3',
                      detail: 'Needs reorder soon',
                      icon: Icons.warning_amber_rounded,
                      accent: KainPHTheme.warning,
                    ),
                    _SummaryCard(
                      title: 'Out of Stock',
                      value: '1',
                      detail: 'Critical items',
                      icon: Icons.remove_circle_outline,
                      accent: KainPHTheme.danger,
                    ),
                    _SummaryCard(
                      title: 'Suppliers',
                      value: '12',
                      detail: 'Active partners',
                      icon: Icons.local_shipping_outlined,
                      accent: KainPHTheme.success,
                    ),
                  ];

                  final width = constraints.maxWidth;
                  if (width < 520) {
                    // Stack vertically for small screens
                    return Wrap(
                      runSpacing: 12,
                      children: cards.map((c) => SizedBox(width: width, child: c)).toList(),
                    );
                  }

                  // Use centralized ResponsiveGrid so card layout adapts to width and text scaling
                  return const ResponsiveGrid(children: cards);
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Low stock warnings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: KainPHTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (lowStock.isEmpty)
                const Card(child: ListTile(title: Text('No low-stock items')))
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: lowStock
                      .map((item) => ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: isWide ? 230 : double.infinity),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.warning_amber_rounded,
                                            color: KainPHTheme.warning),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${item.stock} ${item.unit} left',
                                      style: const TextStyle(
                                        color: KainPHTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    FilledButton.tonal(
                                      onPressed: () {},
                                      child: const Text('Reorder'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              const SizedBox(height: 24),
              const Text(
                'Stock list',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: KainPHTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              if (_filtered.isEmpty)
                              Card(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minHeight: 120),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.search_off_rounded,
                                            size: 46,
                                            color: Colors.grey.shade400),
                                        const SizedBox(height: 12),
                                        const Text('No matching inventory items found.'),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            else if (isWide)
                              // Use ResponsiveGrid for inventory items so columns adapt and cards can grow vertically when needed.
                              ResponsiveGrid(
                                children: _filtered.map((item) {
                                  return InventoryItemCard(
                                    item: item,
                                    onTap: () => showDialog<void>(
                                      context: context,
                                      builder: (_) => InventoryItemDetail(item: item, onAdjust: (change) => _adjust(item, change), onDelete: () => _delete(item)),
                                    ),
                                  );
                                }).toList(),
                              )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final item = _filtered[index];
                    return InventoryItemCard(
                      item: item,
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (_) => InventoryItemDetail(item: item, onAdjust: (change) => _adjust(item, change), onDelete: () => _delete(item)),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createItem,
        icon: const Icon(Icons.add),
        label: const Text('Add stock item'),
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
                const Icon(Icons.trending_up_rounded, size: 18, color: KainPHTheme.success),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: KainPHTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: KainPHTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: const TextStyle(
                fontSize: 11,
                color: KainPHTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
