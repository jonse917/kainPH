import 'package:drift/drift.dart';

import '../database/app_database.dart';
import '../database/pos_repository.dart';
import '../theme/kainph_catalog.dart';

/// Application composition root for the local, offline-first POS database.
class KainPHDatabase {
  KainPHDatabase._();
  static final KainPHDatabase instance = KainPHDatabase._();

  final AppDatabase database = AppDatabase();
  late final PosRepository pos = PosRepository(database);

  Future<void> initialize() async {
    final now = DateTime.now();
    for (final name in const ['Meals', 'Grilled', 'Sides', 'Desserts', 'Drinks', 'Coffee', 'Rice Meals', 'Snacks', 'Pasta']) {
      await database.into(database.categories).insertOnConflictUpdate(
        CategoriesCompanion.insert(id: name, name: name, createdAt: now, updatedAt: now),
      );
    }
    final existing = await database.select(database.products).get();
    if (existing.isNotEmpty) return;
    for (final sample in KainPHCatalog.samples) {
      await pos.createProduct(ProductsCompanion.insert(
        id: sample.id,
        name: sample.name,
        categoryId: Value(sample.category),
        price: sample.price,
        createdAt: now,
        updatedAt: now,
      ));
    }
  }
  Future<void> close() => database.close();

  Future<void> saveSale({
    required String saleId,
    required String receiptNumber,
    required String orderType,
    required double subtotal,
    required double discountAmount,
    required String discountType,
    required double taxAmount,
    required double totalAmount,
    required String paymentMethod,
    required double cashReceived,
    required double changeAmount,
    required List<Map<String, dynamic>> items,
  }) => pos.completeSale(CompleteSaleInput(
        id: saleId,
        orderId: 'ORDER-$saleId',
        receiptNumber: receiptNumber,
        orderType: orderType,
        subtotal: subtotal,
        discountAmount: discountAmount,
        discountType: discountType,
        taxAmount: taxAmount,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
        cashReceived: cashReceived,
        changeAmount: changeAmount,
        items: items.map((item) => SaleLineInput(
          productId: item['productId'] as String,
          productName: item['productName'] as String,
          categoryName: item['category'] as String,
          unitPrice: (item['unitPrice'] as num).toDouble(),
          quantity: item['quantity'] as int,
        )).toList(),
      ));
}
