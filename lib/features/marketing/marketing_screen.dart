import 'package:flutter/material.dart';

import '../../core/widgets/responsive.dart';

import '../../core/theme/kainph_theme.dart';

class MarketingScreen extends StatelessWidget {
  const MarketingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const summaryCards = [
      _SummaryCard(
          title: 'Active Promotions',
          value: '6',
          detail: '2 ending soon',
          icon: Icons.local_offer_outlined,
          accent: KainPHTheme.primary),
      _SummaryCard(
          title: 'Coupon Usage',
          value: '1,284',
          detail: '92 redeemed today',
          icon: Icons.discount_outlined,
          accent: KainPHTheme.success),
      _SummaryCard(
          title: 'Loyalty Activity',
          value: '812',
          detail: 'Points earned',
          icon: Icons.stars_outlined,
          accent: KainPHTheme.warning),
      _SummaryCard(
          title: 'Top Campaign',
          value: 'Lunch Combo',
          detail: '₱9,870 sales',
          icon: Icons.campaign_outlined,
          accent: KainPHTheme.danger),
    ];

    const promos = [
      _Promo(
          'Lunch Combo', 'Active', 'Buy 1 rice meal + drink', 'Ends in 3 days'),
      _Promo('Student Discount', 'Scheduled', '10% off after 2 PM',
          'Starts next Monday'),
      _Promo('Family Feast', 'Expired', 'Free dessert for 4 pax',
          'Ended last week'),
    ];

    const coupons = [
      _Coupon('SAVE10', '10% Off', 'Active', 'Valid until 30 Sep'),
      _Coupon('BUNDLE25', '₱25 off', 'Scheduled', 'Starts 12 Oct'),
      _Coupon('LOYAL5', '5% off', 'Expired', 'Used up'),
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
              const Text('MARKETING',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: KainPHTheme.textPrimary)),
              const SizedBox(height: 6),
              const Text(
                  'Promotions, coupons, loyalty, and customer engagement.',
                  style: TextStyle(
                      color: KainPHTheme.textSecondary, fontSize: 15)),
              const SizedBox(height: 20),
              LayoutBuilder(
                builder: (context, constraints) {
                  return const ResponsiveGrid(children: summaryCards);
                },
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),
              const Text('Promotions',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: KainPHTheme.textPrimary)),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: promos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final promo = promos[index];
                  final isActive = promo.status == 'Active';
                  final isScheduled = promo.status == 'Scheduled';
                  final statusColor = isActive
                      ? KainPHTheme.success
                      : isScheduled
                          ? KainPHTheme.warning
                          : KainPHTheme.textSecondary;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            KainPHTheme.primary.withValues(alpha: 0.1),
                        child: const Icon(Icons.local_offer_outlined,
                            color: KainPHTheme.primary),
                      ),
                      title: Text(promo.name),
                      subtitle: Text(promo.details),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              promo.status,
                              style: TextStyle(
                                  color: statusColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(promo.timeline,
                              style: const TextStyle(
                                  color: KainPHTheme.textSecondary,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Coupons',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: KainPHTheme.textPrimary)),
              const SizedBox(height: 12),
              Card(
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: coupons.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, index) {
                    final coupon = coupons[index];
                    return ListTile(
                      title: Text(coupon.code),
                      subtitle: Text(coupon.discount),
                      trailing: Text(coupon.status,
                          style: TextStyle(
                              color: coupon.status == 'Active'
                                  ? KainPHTheme.success
                                  : coupon.status == 'Scheduled'
                                      ? KainPHTheme.warning
                                      : KainPHTheme.textSecondary,
                              fontWeight: FontWeight.w600)),
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

class _Promo {
  final String name;
  final String status;
  final String details;
  final String timeline;

  const _Promo(this.name, this.status, this.details, this.timeline);
}

class _Coupon {
  final String code;
  final String discount;
  final String status;
  final String validity;

  const _Coupon(this.code, this.discount, this.status, this.validity);
}
