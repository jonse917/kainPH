import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/database/pos_repository.dart';
import '../../core/services/kainph_database.dart';
import '../../core/theme/kainph_theme.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/responsive.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.onNavigate, this.onAddProduct});
  final ValueChanged<int>? onNavigate;
  final VoidCallback? onAddProduct;
  @override
  Widget build(BuildContext context) => Scaffold(body: StreamBuilder<DashboardSnapshot>(
    stream: KainPHDatabase.instance.pos.watchDashboard(),
    builder: (context, snapshot) {
      if (snapshot.hasError) return const Center(child: Text('Unable to load dashboard data.'));
      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
      final d = snapshot.data!;
      return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        KainPHPageHeader(title: 'Dashboard', subtitle: d.ordersToday == 0 ? 'No sales yet today' : '${d.ordersToday} order${d.ordersToday == 1 ? '' : 's'} recorded today.'), const SizedBox(height: 20),
        ResponsiveGrid(children: [
          _Card('Today\'s Sales', _money(d.todaySales), '${d.ordersToday} Orders', Icons.payments_outlined, KainPHTheme.primary),
          _Card('Items Sold', '${d.itemsSoldToday}', d.itemsSoldToday == 0 ? 'No items sold yet' : 'Items sold today', Icons.shopping_bag_outlined, KainPHTheme.success),
          _Card('Inventory', '${d.inventoryUnits} units', '${d.lowStock} low · ${d.outOfStock} out', Icons.inventory_2_outlined, KainPHTheme.warning),
          _Card('Out of Stock', '${d.outOfStock}', d.outOfStock == 0 ? 'All tracked items available' : 'Action needed', Icons.warning_amber_rounded, KainPHTheme.danger),
        ]), const SizedBox(height: 24), const KainPHSectionTitle('Quick actions'), const SizedBox(height: 10),
        _Action(Icons.shopping_cart_outlined, 'New Sale', () => onNavigate?.call(1)),
        _Action(Icons.add_box_outlined, 'Add Product', onAddProduct),
        _Action(Icons.inventory_2_outlined, 'Inventory', () => onNavigate?.call(3)),
        const SizedBox(height: 24), const KainPHSectionTitle('Sales trend'), const SizedBox(height: 10), _Trend(d.hourlySales),
        const SizedBox(height: 24), const KainPHSectionTitle('Recent transactions'), const SizedBox(height: 10), _Recent(sales: d.recentSales),
      ]));
    },
  ));
}
String _money(double value) => '₱${value.toStringAsFixed(2)}';
class _Card extends StatelessWidget {
  const _Card(this.title, this.value, this.detail, this.icon, this.color);
  final String title, value, detail;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: KainPHTheme.textSecondary, fontSize: 12, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: -0.3, color: KainPHTheme.textPrimary)),
            const SizedBox(height: 6),
            Text(detail, style: const TextStyle(color: KainPHTheme.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
class _Action extends StatelessWidget {
  const _Action(this.icon, this.title, this.onTap);
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: KainPHTheme.surface, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: KainPHTheme.coffee, size: 18),
          ),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.arrow_forward, size: 18, color: KainPHTheme.textSecondary),
        ),
      ),
    );
  }
}
class _Trend extends StatelessWidget {
  const _Trend(this.values);
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    final max = values.fold<double>(0, (a, b) => a > b ? a : b);
    if (max == 0) {
      return const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('No sales yet today'))));
    }
    return Card(child: SizedBox(height: 190, child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(values.length, (index) {
        return Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Expanded(child: Align(alignment: Alignment.bottomCenter, child: Container(
              height: 120 * values[index] / max,
              decoration: BoxDecoration(color: KainPHTheme.primary.withValues(alpha: 0.9), borderRadius: const BorderRadius.vertical(top: Radius.circular(10))),
            ))),
            Text('${index * 3}:00', style: const TextStyle(fontSize: 10, color: KainPHTheme.textSecondary)),
          ]),
        ));
      })),
    )));
  }
}
class _Recent extends StatelessWidget { const _Recent({required this.sales}); final List<Sale> sales; @override Widget build(BuildContext c) { if(sales.isEmpty)return const Card(child:Padding(padding:EdgeInsets.all(24),child:Center(child:Text('No transactions yet')))); return Card(child:Column(children:sales.map((s)=>ListTile(leading:const Icon(Icons.receipt_long_outlined),title:Text(s.receiptNumber),subtitle:Text('${s.completedAt.hour.toString().padLeft(2,'0')}:${s.completedAt.minute.toString().padLeft(2,'0')}'),trailing:Text(_money(s.totalAmount),style:const TextStyle(fontWeight:FontWeight.bold)))).toList())); }}
