/// Sample menu photos from the KainPH UI asset pack.
/// Prices here are illustrative design samples, not business rules.
class KainPHCatalog {
  const KainPHCatalog._();

  static const wordmark = 'assets/brand/kainph_wordmark_reference.png';
  static const background = 'assets/brand/kainph_official_background.jpg';

  static const samples = <KainPHSampleProduct>[
    KainPHSampleProduct(id: 'sample-americano', name: 'Americano', category: 'Coffee', price: 100),
    KainPHSampleProduct(id: 'sample-cafe-latte', name: 'Café Latte', category: 'Coffee', price: 120),
    KainPHSampleProduct(id: 'sample-cappuccino', name: 'Cappuccino', category: 'Coffee', price: 120),
    KainPHSampleProduct(id: 'sample-caramel-macchiato', name: 'Caramel Macchiato', category: 'Coffee', price: 140),
    KainPHSampleProduct(id: 'sample-spanish-latte', name: 'Spanish Latte', category: 'Coffee', price: 110),
    KainPHSampleProduct(id: 'sample-mocha', name: 'Mocha', category: 'Coffee', price: 140),
    KainPHSampleProduct(id: 'sample-iced-coffee', name: 'Iced Coffee', category: 'Drinks', price: 120),
    KainPHSampleProduct(id: 'sample-matcha', name: 'Iced Matcha Latte', category: 'Drinks', price: 140),
    KainPHSampleProduct(id: 'sample-chicken-sandwich', name: 'Chicken Sandwich', category: 'Snacks', price: 150),
    KainPHSampleProduct(id: 'sample-beef-burger', name: 'Beef Burger', category: 'Snacks', price: 180),
    KainPHSampleProduct(id: 'sample-carbonara', name: 'Carbonara', category: 'Pasta', price: 140),
    KainPHSampleProduct(id: 'sample-chicken-pesto', name: 'Chicken Pesto', category: 'Rice Meals', price: 160),
  ];

  static const _assets = <String, String>{
    'americano': 'assets/products/americano_reference.png',
    'cafe latte': 'assets/products/cafe_latte_reference.png',
    'cappuccino': 'assets/products/cappuccino_reference.png',
    'caramel macchiato': 'assets/products/caramel_macchiato_reference.png',
    'spanish latte': 'assets/products/spanish_latte_reference.png',
    'mocha': 'assets/products/mocha_reference.png',
    'iced coffee': 'assets/products/iced_coffee_reference.png',
    'iced matcha latte': 'assets/products/matcha_latte_reference.png',
    'chicken sandwich': 'assets/products/chicken_sandwich_reference.png',
    'beef burger': 'assets/products/beef_burger_reference.png',
    'carbonara': 'assets/products/carbonara_reference.png',
    'chicken pesto': 'assets/products/chicken_pesto_reference.png',
  };

  static String? assetFor(String name) {
    final key = name.toLowerCase().replaceAll('é', 'e').replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
    return _assets[key];
  }
}

class KainPHSampleProduct {
  const KainPHSampleProduct({required this.id, required this.name, required this.category, required this.price});
  final String id;
  final String name;
  final String category;
  final double price;
}
