class MenuProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final bool featured;
  final bool available;
  final List<String> variants;
  final List<String> modifiers;
  final String description;
  final String? imagePath;

  const MenuProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.featured = false,
    this.available = true,
    this.variants = const [],
    this.modifiers = const [],
    this.description = '',
    this.imagePath,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'featured': featured,
        'available': available,
        'variants': variants,
        'modifiers': modifiers,
        'description': description,
        'imagePath': imagePath,
      };

  factory MenuProduct.fromMap(Map<String, dynamic> map) => MenuProduct(
        id: map['id'] as String,
        name: map['name'] as String,
        category: map['category'] as String,
        price: (map['price'] as num).toDouble(),
        featured: map['featured'] as bool? ?? false,
        available: map['available'] as bool? ?? true,
        variants: List<String>.from(map['variants'] as List? ?? const []),
        modifiers: List<String>.from(map['modifiers'] as List? ?? const []),
        description: map['description'] as String? ?? '',
        imagePath: map['imagePath'] as String?,
      );
}

const List<String> demoCategories = [
  'All',
  'Meals',
  'Grilled',
  'Sides',
  'Desserts',
  'Drinks',
];

const List<MenuProduct> demoProducts = [
  MenuProduct(
    id: 'chicken-inasal',
    name: 'Chicken Inasal',
    category: 'Grilled',
    price: 220.00,
    featured: true,
    variants: ['Half', 'Whole'],
    modifiers: ['Extra Rice', 'Spicy Sauce'],
    description: 'Classic Bacolod-style grilled chicken marinated in vinegar and achuete.',
  ),
  MenuProduct(
    id: 'pork-bbq',
    name: 'Pork BBQ',
    category: 'Grilled',
    price: 35.00,
    modifiers: ['Extra Skewer', 'Sweet Sauce'],
  ),
  MenuProduct(
    id: 'sisig',
    name: 'Sisig',
    category: 'Meals',
    price: 180.00,
    modifiers: ['With Egg', 'Extra Chili'],
  ),
  MenuProduct(
    id: 'pancit-canton',
    name: 'Pancit Canton',
    category: 'Meals',
    price: 120.00,
  ),
  MenuProduct(
    id: 'halo-halo',
    name: 'Halo-Halo',
    category: 'Desserts',
    price: 95.00,
    featured: true,
  ),
  MenuProduct(
    id: 'iced-coffee',
    name: 'Iced Coffee',
    category: 'Drinks',
    price: 75.00,
  ),
  MenuProduct(
    id: 'lumpia-shanghai',
    name: 'Lumpia Shanghai',
    category: 'Sides',
    price: 65.00,
  ),
];
