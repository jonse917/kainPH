import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
}

class Products extends Table {
  TextColumn get id => text()();
  TextColumn get categoryId => text().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get price => real().customConstraint('CHECK (price >= 0)')();
  BoolColumn get featured => boolean().withDefault(const Constant(false))();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  BoolColumn get trackInventory => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
}

class Inventory extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text().nullable().references(Products, #id, onDelete: KeyAction.setNull)();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get unit => text()();
  IntColumn get quantity => integer().withDefault(const Constant(0)).customConstraint('CHECK (quantity >= 0)')();
  IntColumn get reorderLevel => integer().withDefault(const Constant(0)).customConstraint('CHECK (reorder_level >= 0)')();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
}

class Orders extends Table {
  TextColumn get id => text()();
  TextColumn get orderType => text()();
  TextColumn get status => text()();
  TextColumn get customerName => text().nullable()();
  TextColumn get tableNumber => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
}

class OrderItems extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get productId => text().nullable()(); // Snapshot reference: product can be soft-deleted.
  TextColumn get productName => text()();
  TextColumn get categoryName => text()();
  RealColumn get unitPrice => real().customConstraint('CHECK (unit_price >= 0)')();
  IntColumn get quantity => integer().customConstraint('CHECK (quantity > 0)')();
  RealColumn get lineTotal => real().customConstraint('CHECK (line_total >= 0)')();
  @override Set<Column> get primaryKey => {id};
}

class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get receiptNumber => text().unique()();
  RealColumn get subtotal => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0))();
  TextColumn get discountType => text().withDefault(const Constant('None'))();
  RealColumn get taxAmount => real().withDefault(const Constant(0))();
  RealColumn get totalAmount => real().customConstraint('CHECK (total_amount >= 0)')();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  DateTimeColumn get completedAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
}

class Payments extends Table {
  TextColumn get id => text()();
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get method => text()();
  RealColumn get amount => real().customConstraint('CHECK (amount >= 0)')();
  RealColumn get cashReceived => real().withDefault(const Constant(0))();
  RealColumn get changeAmount => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
}

class StockMovements extends Table {
  TextColumn get id => text()();
  TextColumn get inventoryId => text().references(Inventory, #id)();
  TextColumn get type => text()(); // sale, adjustment_in, adjustment_out
  IntColumn get quantityDelta => integer()();
  TextColumn get referenceId => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  @override Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Categories, Products, Inventory, Orders, OrderItems, Sales, Payments, StockMovements])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'kainph_pos', web: DriftWebOptions(sqlite3Wasm: Uri.parse('sqlite3.wasm'), driftWorker: Uri.parse('drift_worker.js'))));
  AppDatabase.forTesting(super.executor);

  @override int get schemaVersion => 1;
}
