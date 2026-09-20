class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String unit;
  final int stock;
  final int reorderLevel;
  final bool tracked;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.stock,
    required this.reorderLevel,
    this.tracked = true,
  });

  bool get isLow => stock <= reorderLevel;
  bool get isOutOfStock => stock <= 0;

  Map<String, dynamic> toMap() => {
        'id': id, 'name': name, 'category': category, 'unit': unit,
        'stock': stock, 'reorderLevel': reorderLevel, 'tracked': tracked,
      };

  factory InventoryItem.fromMap(Map<String, dynamic> map) => InventoryItem(
        id: map['id'] as String,
        name: map['name'] as String,
        category: map['category'] as String,
        unit: map['unit'] as String,
        stock: (map['stock'] as num).toInt(),
        reorderLevel: (map['reorderLevel'] as num).toInt(),
        tracked: map['tracked'] as bool? ?? true,
      );
}

const List<String> inventoryCategories = [
  'All',
  'Ingredients',
  'Packaging',
  'Beverages',
  'Dry Goods',
];

const List<InventoryItem> demoInventory = [
  InventoryItem(
    id: 'rice-10kg',
    name: 'Rice (10kg)',
    category: 'Dry Goods',
    unit: 'bag',
    stock: 12,
    reorderLevel: 5,
  ),
  InventoryItem(
    id: 'chicken-thigh',
    name: 'Chicken Thighs (kg)',
    category: 'Ingredients',
    unit: 'kg',
    stock: 8,
    reorderLevel: 10,
  ),
  InventoryItem(
    id: 'soy-sauce',
    name: 'Soy Sauce (L)',
    category: 'Ingredients',
    unit: 'L',
    stock: 2,
    reorderLevel: 3,
  ),
  InventoryItem(
    id: 'paper-bag',
    name: 'Paper Bag',
    category: 'Packaging',
    unit: 'pcs',
    stock: 150,
    reorderLevel: 50,
  ),
  InventoryItem(
    id: 'coke-1l',
    name: 'Coke 1L',
    category: 'Beverages',
    unit: 'bottle',
    stock: 0,
    reorderLevel: 10,
  ),
];
