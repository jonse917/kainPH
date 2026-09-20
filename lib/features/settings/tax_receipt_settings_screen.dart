import 'package:flutter/material.dart';

import '../../core/services/tax_settings_store.dart';
import '../../core/theme/kainph_theme.dart';

class TaxReceiptSettingsScreen extends StatefulWidget {
  const TaxReceiptSettingsScreen({
    super.key,
  });

  @override
  State<TaxReceiptSettingsScreen> createState() =>
      _TaxReceiptSettingsScreenState();
}

class _TaxReceiptSettingsScreenState extends State<TaxReceiptSettingsScreen> {
  late TaxReceiptSettings _settings;

  final _businessNameController = TextEditingController();

  final _tinController = TextEditingController();

  final _addressController = TextEditingController();

  final _footerController = TextEditingController();

  final _prefixController = TextEditingController();

  final _taxRateController = TextEditingController();

  final _discountRateController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _settings = TaxReceiptSettingsStore.current;

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await TaxReceiptSettingsStore.load();

    if (!mounted) return;

    setState(() {
      _settings = settings;

      _businessNameController.text = settings.businessName;

      _tinController.text = settings.tin;

      _addressController.text = settings.businessAddress;

      _footerController.text = settings.receiptFooter;

      _prefixController.text = settings.receiptPrefix;

      _taxRateController.text = settings.taxRate.toString();

      _discountRateController.text = settings.seniorPwdDiscountRate.toString();
    });
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _tinController.dispose();
    _addressController.dispose();
    _footerController.dispose();
    _prefixController.dispose();
    _taxRateController.dispose();
    _discountRateController.dispose();

    super.dispose();
  }

  Future<void> _save() async {
    final taxRate = double.tryParse(
          _taxRateController.text.trim(),
        ) ??
        12.0;

    final discountRate = double.tryParse(
          _discountRateController.text.trim(),
        ) ??
        20.0;

    final updated = _settings.copyWith(
      taxRate: taxRate.clamp(0, 100),
      seniorPwdDiscountRate: discountRate.clamp(0, 100),
      businessName: _businessNameController.text.trim(),
      tin: _tinController.text.trim(),
      businessAddress: _addressController.text.trim(),
      receiptFooter: _footerController.text.trim(),
      receiptPrefix: _prefixController.text.trim(),
    );

    await TaxReceiptSettingsStore.save(
      updated,
    );

    if (!mounted) return;

    setState(() {
      _settings = updated;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tax & receipt settings saved.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tax & Receipt Settings',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 12,
            ),
            child: FilledButton.icon(
              onPressed: _save,
              icon: const Icon(
                Icons.save_outlined,
              ),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
            context,
            constraints,
          ) {
            final wide = constraints.maxWidth >= 900;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 1100,
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildIntro(),
                    const SizedBox(height: 20),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTaxCard(),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildReceiptCard(),
                          ),
                        ],
                      )
                    else ...[
                      _buildTaxCard(),
                      const SizedBox(height: 16),
                      _buildReceiptCard(),
                    ],
                    const SizedBox(height: 16),
                    _buildDiscountCard(),
                    const SizedBox(height: 16),
                    _buildPreviewCard(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: KainPHTheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: KainPHTheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tax & Receipt Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Configure how KainPH calculates tax and displays business information on receipts.',
                    style: TextStyle(
                      color: KainPHTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tax Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Choose the tax treatment that matches the business registration.',
              style: TextStyle(
                color: KainPHTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TaxProfile>(
              initialValue: _settings.taxProfile,
              decoration: const InputDecoration(
                labelText: 'Tax status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: TaxProfile.vatRegistered,
                  child: Text(
                    'VAT Registered',
                  ),
                ),
                DropdownMenuItem(
                  value: TaxProfile.nonVat,
                  child: Text(
                    'Non-VAT',
                  ),
                ),
                DropdownMenuItem(
                  value: TaxProfile.vatExempt,
                  child: Text(
                    'VAT-Exempt',
                  ),
                ),
                DropdownMenuItem(
                  value: TaxProfile.custom,
                  child: Text(
                    'Custom Tax',
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _settings = _settings.copyWith(
                    taxProfile: value,
                    taxRate: value == TaxProfile.vatRegistered
                        ? 12.0
                        : _settings.taxRate,
                  );

                  _taxRateController.text = _settings.taxRate.toString();
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _taxRateController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              enabled: _settings.taxProfile == TaxProfile.vatRegistered ||
                  _settings.taxProfile == TaxProfile.custom,
              decoration: const InputDecoration(
                labelText: 'Tax rate',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Prices include tax',
              ),
              subtitle: const Text(
                'Use this when menu prices already include VAT.',
              ),
              value: _settings.pricesIncludeTax,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(
                    pricesIncludeTax: value,
                  );
                });
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Show tax on receipt',
              ),
              subtitle: const Text(
                'Display the tax breakdown on printed receipts.',
              ),
              value: _settings.showTaxOnReceipt,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(
                    showTaxOnReceipt: value,
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Business & Receipt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                labelText: 'Business name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _tinController,
              decoration: const InputDecoration(
                labelText: 'TIN',
                hintText: 'Optional during setup',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Business address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prefixController,
              decoration: const InputDecoration(
                labelText: 'Receipt number prefix',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _footerController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Receipt footer',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscountCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Senior Citizen & PWD',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enable the POS discount option for qualified customers. The business should verify eligibility and applicable rules.',
              style: TextStyle(
                color: KainPHTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Enable Senior/PWD discount',
              ),
              value: _settings.enableSeniorPwdDiscount,
              onChanged: (value) {
                setState(() {
                  _settings = _settings.copyWith(
                    enableSeniorPwdDiscount: value,
                  );
                });
              },
            ),
            TextField(
              controller: _discountRateController,
              enabled: _settings.enableSeniorPwdDiscount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Discount rate',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard() {
    final calculation = TaxCalculator.calculate(
      subtotal: 160,
      settings: _settings,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Checkout Preview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            _previewRow(
              'Sample subtotal',
              _currency(160),
            ),
            if (calculation.taxAmount > 0)
              _previewRow(
                'Tax',
                _currency(
                  calculation.taxAmount,
                ),
              ),
            _previewRow(
              'Total',
              _currency(
                calculation.totalAmount,
              ),
              bold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewRow(
    String label,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

String _currency(double amount) {
  return '₱${amount.toStringAsFixed(2)}';
}
