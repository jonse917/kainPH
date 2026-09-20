import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TaxProfile {
  vatRegistered,
  nonVat,
  vatExempt,
  custom,
}

class TaxReceiptSettings {
  final TaxProfile taxProfile;
  final double taxRate;
  final bool pricesIncludeTax;
  final bool showTaxOnReceipt;

  final bool enableSeniorPwdDiscount;
  final double seniorPwdDiscountRate;

  final String businessName;
  final String tin;
  final String businessAddress;
  final String receiptFooter;
  final String receiptPrefix;

  const TaxReceiptSettings({
    this.taxProfile = TaxProfile.vatRegistered,
    this.taxRate = 12.0,
    this.pricesIncludeTax = true,
    this.showTaxOnReceipt = true,
    this.enableSeniorPwdDiscount = true,
    this.seniorPwdDiscountRate = 20.0,
    this.businessName = 'KainPH Food Business',
    this.tin = '',
    this.businessAddress = '',
    this.receiptFooter = 'Thank you for dining with us!',
    this.receiptPrefix = 'KPH',
  });

  TaxReceiptSettings copyWith({
    TaxProfile? taxProfile,
    double? taxRate,
    bool? pricesIncludeTax,
    bool? showTaxOnReceipt,
    bool? enableSeniorPwdDiscount,
    double? seniorPwdDiscountRate,
    String? businessName,
    String? tin,
    String? businessAddress,
    String? receiptFooter,
    String? receiptPrefix,
  }) {
    return TaxReceiptSettings(
      taxProfile: taxProfile ?? this.taxProfile,
      taxRate: taxRate ?? this.taxRate,
      pricesIncludeTax: pricesIncludeTax ?? this.pricesIncludeTax,
      showTaxOnReceipt: showTaxOnReceipt ?? this.showTaxOnReceipt,
      enableSeniorPwdDiscount:
          enableSeniorPwdDiscount ?? this.enableSeniorPwdDiscount,
      seniorPwdDiscountRate:
          seniorPwdDiscountRate ?? this.seniorPwdDiscountRate,
      businessName: businessName ?? this.businessName,
      tin: tin ?? this.tin,
      businessAddress: businessAddress ?? this.businessAddress,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      receiptPrefix: receiptPrefix ?? this.receiptPrefix,
    );
  }
}

class TaxReceiptSettingsStore {
  static const _taxProfileKey = 'kainph_tax_profile';
  static const _taxRateKey = 'kainph_tax_rate';
  static const _pricesIncludeTaxKey = 'kainph_prices_include_tax';
  static const _showTaxKey = 'kainph_show_tax_on_receipt';

  static const _seniorPwdEnabledKey = 'kainph_senior_pwd_discount_enabled';

  static const _seniorPwdRateKey = 'kainph_senior_pwd_discount_rate';

  static const _businessNameKey = 'kainph_business_name';
  static const _tinKey = 'kainph_business_tin';
  static const _addressKey = 'kainph_business_address';
  static const _footerKey = 'kainph_receipt_footer';
  static const _prefixKey = 'kainph_receipt_prefix';

  static final ValueNotifier<TaxReceiptSettings> notifier =
      ValueNotifier(const TaxReceiptSettings());

  static TaxReceiptSettings get current => notifier.value;

  static Future<TaxReceiptSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    final profileIndex =
        prefs.getInt(_taxProfileKey) ?? TaxProfile.vatRegistered.index;

    final safeProfileIndex =
        profileIndex.clamp(0, TaxProfile.values.length - 1);

    final settings = TaxReceiptSettings(
      taxProfile: TaxProfile.values[safeProfileIndex],
      taxRate: prefs.getDouble(_taxRateKey) ?? 12.0,
      pricesIncludeTax: prefs.getBool(_pricesIncludeTaxKey) ?? true,
      showTaxOnReceipt: prefs.getBool(_showTaxKey) ?? true,
      enableSeniorPwdDiscount: prefs.getBool(_seniorPwdEnabledKey) ?? true,
      seniorPwdDiscountRate: prefs.getDouble(_seniorPwdRateKey) ?? 20.0,
      businessName: prefs.getString(_businessNameKey) ?? 'KainPH Food Business',
      tin: prefs.getString(_tinKey) ?? '',
      businessAddress: prefs.getString(_addressKey) ?? '',
      receiptFooter:
          prefs.getString(_footerKey) ?? 'Thank you for dining with us!',
      receiptPrefix: prefs.getString(_prefixKey) ?? 'KPH',
    );

    notifier.value = settings;

    return settings;
  }

  static Future<void> save(
    TaxReceiptSettings settings,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      _taxProfileKey,
      settings.taxProfile.index,
    );

    await prefs.setDouble(
      _taxRateKey,
      settings.taxRate,
    );

    await prefs.setBool(
      _pricesIncludeTaxKey,
      settings.pricesIncludeTax,
    );

    await prefs.setBool(
      _showTaxKey,
      settings.showTaxOnReceipt,
    );

    await prefs.setBool(
      _seniorPwdEnabledKey,
      settings.enableSeniorPwdDiscount,
    );

    await prefs.setDouble(
      _seniorPwdRateKey,
      settings.seniorPwdDiscountRate,
    );

    await prefs.setString(
      _businessNameKey,
      settings.businessName,
    );

    await prefs.setString(
      _tinKey,
      settings.tin,
    );

    await prefs.setString(
      _addressKey,
      settings.businessAddress,
    );

    await prefs.setString(
      _footerKey,
      settings.receiptFooter,
    );

    await prefs.setString(
      _prefixKey,
      settings.receiptPrefix,
    );

    notifier.value = settings;
  }

  static Future<void> reset() async {
    await save(
      const TaxReceiptSettings(),
    );
  }
}

class TaxCalculation {
  final double grossAmount;
  final double netAmount;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;

  const TaxCalculation({
    required this.grossAmount,
    required this.netAmount,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
  });
}

class TaxCalculator {
  static TaxCalculation calculate({
    required double subtotal,
    required TaxReceiptSettings settings,
    String discountType = 'None',
  }) {
    double discount = 0;

    final discountAllowed = settings.enableSeniorPwdDiscount &&
        (discountType == 'Senior' || discountType == 'PWD');

    if (discountAllowed) {
      discount = subtotal * (settings.seniorPwdDiscountRate / 100);
    }

    final discountedAmount = (subtotal - discount).clamp(0.0, double.infinity);

    final hasVat = settings.taxProfile == TaxProfile.vatRegistered;

    final hasCustomTax = settings.taxProfile == TaxProfile.custom;

    final appliesTax = hasVat || hasCustomTax;

    if (!appliesTax || settings.taxRate <= 0) {
      return TaxCalculation(
        grossAmount: subtotal,
        netAmount: discountedAmount,
        taxAmount: 0,
        discountAmount: discount,
        totalAmount: discountedAmount,
      );
    }

    if (settings.pricesIncludeTax) {
      final tax =
          discountedAmount * settings.taxRate / (100 + settings.taxRate);

      final net = discountedAmount - tax;

      return TaxCalculation(
        grossAmount: subtotal,
        netAmount: net,
        taxAmount: tax,
        discountAmount: discount,
        totalAmount: discountedAmount,
      );
    }

    final tax = discountedAmount * (settings.taxRate / 100);

    final total = discountedAmount + tax;

    return TaxCalculation(
      grossAmount: subtotal,
      netAmount: discountedAmount,
      taxAmount: tax,
      discountAmount: discount,
      totalAmount: total,
    );
  }
}
