import 'package:drift/drift.dart';
import 'dart:async';

import 'app_database.dart';

class SaleLineInput {
  const SaleLineInput({required this.productId, required this.productName, required this.categoryName, required this.unitPrice, required this.quantity});
  final String productId;
  final String productName;
  final String categoryName;
  final double unitPrice;
  final int quantity;
}

class CompleteSaleInput {
  const CompleteSaleInput({required this.id, required this.orderId, required this.receiptNumber, required this.orderType, required this.subtotal, required this.discountAmount, required this.discountType, required this.taxAmount, required this.totalAmount, required this.paymentMethod, required this.cashReceived, required this.changeAmount, required this.items});
  final String id, orderId, receiptNumber, orderType, discountType, paymentMethod;
  final double subtotal, discountAmount, taxAmount, totalAmount, cashReceived, changeAmount;
  final List<SaleLineInput> items;
}

class ProductOffer {
  const ProductOffer({required this.product, required this.stock, required this.reorderLevel});
  final Product product;
  final int stock;
  final int reorderLevel;

  bool get outOfStock => stock <= 0;
  bool get lowStock => stock > 0 && reorderLevel > 0 && stock <= reorderLevel;
}

class DashboardSnapshot {
  const DashboardSnapshot({required this.todaySales, required this.ordersToday, required this.itemsSoldToday, required this.inventoryUnits, required this.lowStock, required this.outOfStock, required this.recentSales, required this.hourlySales});
  final double todaySales;
  final int ordersToday, itemsSoldToday, inventoryUnits, lowStock, outOfStock;
  final List<Sale> recentSales;
  final List<double> hourlySales;
}

/// Transactional domain operations. UI code never writes tables directly.
class PosRepository {
  PosRepository(this.db);
  final AppDatabase db;

  /// Products shown to staff in the menu, including temporarily unavailable ones.
  Stream<List<Product>> watchProducts() => (db.select(db.products)
        ..where((p) => p.isDeleted.equals(false))
        ..orderBy([(p) => OrderingTerm.asc(p.name)]))
      .watch();

  Stream<List<Category>> watchCategories() => (db.select(db.categories)
        ..where((category) => category.isActive.equals(true))
        ..orderBy([(category) => OrderingTerm.asc(category.name)]))
      .watch();

  /// Only products that can be added to a new sale.
  Stream<List<Product>> watchAvailableProducts() => (db.select(db.products)
        ..where((p) => p.isDeleted.equals(false) & p.isAvailable.equals(true))
        ..orderBy([(p) => OrderingTerm.asc(p.name)]))
      .watch();

  /// Menu and register view: each product with the stock counted against it.
  Stream<List<ProductOffer>> watchOffers() {
    late StreamController<List<ProductOffer>> controller;
    final subscriptions = <StreamSubscription>[];
    List<Product>? products;
    List<InventoryData>? inventory;

    void emit() {
      if (products == null || inventory == null || controller.isClosed) return;
      final byProduct = <String, List<InventoryData>>{};
      for (final item in inventory!) {
        final productId = item.productId;
        if (productId == null) continue;
        byProduct.putIfAbsent(productId, () => []).add(item);
      }
      controller.add([
        for (final product in products!)
          ProductOffer(
            product: product,
            stock: (byProduct[product.id] ?? const <InventoryData>[]).fold(0, (total, item) => total + item.quantity),
            reorderLevel: (byProduct[product.id] ?? const <InventoryData>[]).fold(0, (level, item) => item.reorderLevel > level ? item.reorderLevel : level),
          ),
      ]);
    }

    controller = StreamController<List<ProductOffer>>(
      onListen: () {
        subscriptions.add(watchProducts().listen((rows) {
          products = rows;
          emit();
        }));
        subscriptions.add(watchInventory().listen((rows) {
          inventory = rows;
          emit();
        }));
      },
      onCancel: () async {
        for (final subscription in subscriptions) {
          await subscription.cancel();
        }
      },
    );
    return controller.stream;
  }

  Stream<List<InventoryData>> watchInventory() => (db.select(db.inventory)
        ..where((i) => i.isDeleted.equals(false))
        ..orderBy([(i) => OrderingTerm.asc(i.name)]))
      .watch();

  Stream<List<Sale>> watchSales() => (db.select(db.sales)
        ..orderBy([(s) => OrderingTerm.desc(s.completedAt)]))
      .watch();

  /// A single live projection for the merchant dashboard. Any sale, order line,
  /// or inventory change re-emits a fresh database-backed snapshot.
  Stream<DashboardSnapshot> watchDashboard() {
    late StreamController<DashboardSnapshot> controller;
    final subscriptions = <StreamSubscription>[];
    var loading = false;
    Future<void> refresh() async {
      if (loading) {
        return;
      }
      loading = true;
      try {
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);
        final sales = await (db.select(db.sales)..orderBy([(s) => OrderingTerm.desc(s.completedAt)])).get();
        final todaySales = sales.where((sale) => !sale.completedAt.isBefore(start)).toList();
        final todayOrderIds = todaySales.map((sale) => sale.orderId).toSet();
        final lines = await db.select(db.orderItems).get();
        final inventory = await (db.select(db.inventory)..where((item) => item.isDeleted.equals(false))).get();
        final hourly = List<double>.filled(7, 0);
        for (final sale in todaySales) {
          final bucket = sale.completedAt.hour ~/ 3;
          hourly[bucket.clamp(0, 6)] += sale.totalAmount;
        }
        if (!controller.isClosed) {
          controller.add(DashboardSnapshot(
            todaySales: todaySales.fold(0, (total, sale) => total + sale.totalAmount),
            ordersToday: todaySales.length,
            itemsSoldToday: lines.where((line) => todayOrderIds.contains(line.orderId)).fold(0, (total, line) => total + line.quantity),
            inventoryUnits: inventory.fold(0, (total, item) => total + item.quantity),
            lowStock: inventory.where((item) => item.quantity > 0 && item.quantity <= item.reorderLevel).length,
            outOfStock: inventory.where((item) => item.quantity == 0).length,
            recentSales: sales.take(5).toList(),
            hourlySales: hourly,
          ));
        }
      } finally { loading = false; }
    }
    controller = StreamController<DashboardSnapshot>(
      onListen: () {
        subscriptions.add(db.select(db.sales).watch().listen((_) => refresh()));
        subscriptions.add(db.select(db.orderItems).watch().listen((_) => refresh()));
        subscriptions.add(db.select(db.inventory).watch().listen((_) => refresh()));
        refresh();
      },
      onCancel: () async { for (final subscription in subscriptions) { await subscription.cancel(); } },
    );
    return controller.stream;
  }

  Future<void> createProduct(ProductsCompanion product, {int openingStock = 0}) async {
    final stock = openingStock < 0 ? 0 : openingStock;
    await db.transaction(() async {
      await db.into(db.products).insert(product);
      // Every sellable product gets one stock record. Zero means out of stock
      // on the register until Inventory receives more.
      await db.into(db.inventory).insert(InventoryCompanion.insert(
        id: 'INV-${product.id.value}', productId: Value(product.id.value),
        name: product.name.value, category: product.categoryId.value ?? 'Uncategorized',
        unit: 'pcs', quantity: Value(stock), reorderLevel: const Value(5),
        createdAt: product.createdAt.value, updatedAt: product.updatedAt.value,
      ));
    });
  }

  Future<void> createCategory(String name) async {
    final value = name.trim();
    if (value.isEmpty) throw ArgumentError.value(name, 'name', 'must not be empty');
    final now = DateTime.now();
    await db.into(db.categories).insert(CategoriesCompanion.insert(
      id: value, name: value, createdAt: now, updatedAt: now,
    ));
  }

  /// Category ids are also product references, so a rename creates the new
  /// category first and repoints dependent product and inventory records in one
  /// transaction before removing the old category.
  Future<void> renameCategory(String id, String name) async {
    final value = name.trim();
    if (value.isEmpty) throw ArgumentError.value(name, 'name', 'must not be empty');
    if (value == id) return;
    final now = DateTime.now();
    await db.transaction(() async {
      await db.into(db.categories).insert(CategoriesCompanion.insert(id: value, name: value, createdAt: now, updatedAt: now));
      await (db.update(db.products)..where((product) => product.categoryId.equals(id))).write(ProductsCompanion(categoryId: Value(value), updatedAt: Value(now)));
      await (db.update(db.inventory)..where((item) => item.category.equals(id))).write(InventoryCompanion(category: Value(value), updatedAt: Value(now)));
      await (db.delete(db.categories)..where((category) => category.id.equals(id))).go();
    });
  }

  Future<void> deleteCategory(String id) async {
    final now = DateTime.now();
    await db.transaction(() async {
      await (db.update(db.inventory)..where((item) => item.category.equals(id))).write(InventoryCompanion(category: const Value('Uncategorized'), updatedAt: Value(now)));
      await (db.delete(db.categories)..where((category) => category.id.equals(id))).go();
    });
  }

  Future<void> updateProduct(String id, ProductsCompanion product) async {
    final now = DateTime.now();
    await db.transaction(() async {
      await (db.update(db.products)..where((p) => p.id.equals(id)))
          .write(product.copyWith(updatedAt: Value(now)));
      final updates = InventoryCompanion(
        name: product.name,
        category: product.categoryId.present
            ? Value(product.categoryId.value ?? 'Uncategorized')
            : const Value.absent(),
        updatedAt: Value(now),
      );
      await (db.update(db.inventory)..where((i) => i.productId.equals(id)))
          .write(updates);
    });
  }

  /// Soft deletion preserves the product snapshot referenced by historical sale lines.
  Future<void> deleteProduct(String id) async {
    final now = DateTime.now();
    await db.transaction(() async {
      await (db.update(db.products)..where((p) => p.id.equals(id))).write(
        ProductsCompanion(isDeleted: const Value(true), isAvailable: const Value(false), updatedAt: Value(now)),
      );
      await (db.update(db.inventory)..where((i) => i.productId.equals(id))).write(
        InventoryCompanion(isDeleted: const Value(true), updatedAt: Value(now)),
      );
    });
  }

  Future<void> adjustInventory({required String inventoryId, required int delta, required String type, String? note}) async {
    if (delta == 0) throw ArgumentError.value(delta, 'delta', 'must not be zero');
    await db.transaction(() async {
      final item = await (db.select(db.inventory)..where((i) => i.id.equals(inventoryId))).getSingle();
      final next = item.quantity + delta;
      if (next < 0) throw StateError('Insufficient stock for ${item.name}.');
      await (db.update(db.inventory)..where((i) => i.id.equals(inventoryId))).write(InventoryCompanion(quantity: Value(next), updatedAt: Value(DateTime.now())));
      await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(id: _id('MOV'), inventoryId: inventoryId, type: type, quantityDelta: delta, note: Value(note), createdAt: DateTime.now()));
    });
  }

  Future<void> completeSale(CompleteSaleInput input) async {
    if (input.items.isEmpty) throw ArgumentError('A sale needs at least one item.');
    if (input.totalAmount < 0) throw ArgumentError('Sale total cannot be negative.');
    await db.transaction(() async {
      final now = DateTime.now();
      await db.into(db.orders).insert(OrdersCompanion.insert(id: input.orderId, orderType: input.orderType, status: 'completed', createdAt: now, updatedAt: now));
      for (final line in input.items) {
        await db.into(db.orderItems).insert(OrderItemsCompanion.insert(id: _id('ITEM'), orderId: input.orderId, productId: Value(line.productId), productName: line.productName, categoryName: line.categoryName, unitPrice: line.unitPrice, quantity: line.quantity, lineTotal: line.unitPrice * line.quantity));
      }
      await db.into(db.sales).insert(SalesCompanion.insert(id: input.id, orderId: input.orderId, receiptNumber: input.receiptNumber, subtotal: input.subtotal, discountAmount: Value(input.discountAmount), discountType: Value(input.discountType), taxAmount: Value(input.taxAmount), totalAmount: input.totalAmount, completedAt: now));
      await db.into(db.payments).insert(PaymentsCompanion.insert(id: _id('PAY'), saleId: input.id, method: input.paymentMethod, amount: input.totalAmount, cashReceived: Value(input.cashReceived), changeAmount: Value(input.changeAmount), createdAt: now));

      for (final line in input.items) {
        final product = await (db.select(db.products)..where((p) => p.id.equals(line.productId))).getSingleOrNull();
        if (product != null && !product.isAvailable) throw StateError('${line.productName} is unavailable.');
        final stocks = await (db.select(db.inventory)..where((i) => i.productId.equals(line.productId) & i.isDeleted.equals(false))).get();
        if (stocks.isEmpty || stocks.every((stock) => stock.quantity <= 0)) {
          throw StateError('${line.productName} is out of stock.');
        }
        for (final stock in stocks) {
          if (stock.quantity < line.quantity) throw StateError('Insufficient stock for ${stock.name}.');
          await (db.update(db.inventory)..where((i) => i.id.equals(stock.id))).write(InventoryCompanion(quantity: Value(stock.quantity - line.quantity), updatedAt: Value(now)));
          await db.into(db.stockMovements).insert(StockMovementsCompanion.insert(id: _id('MOV'), inventoryId: stock.id, type: 'sale', quantityDelta: -line.quantity, referenceId: Value(input.id), note: Value('Sale ${input.receiptNumber}'), createdAt: now));
        }
      }
    });
  }

  static String _id(String prefix) => '$prefix-${DateTime.now().microsecondsSinceEpoch}';
}
