import 'package:shared_preferences/shared_preferences.dart';

/// Local presentation metadata for product photos. Product, price, stock and
/// sales data remain in Drift; this only maps a product id to its device image.
class ProductImageStore {
  ProductImageStore._();
  static final instance = ProductImageStore._();
  static const _prefix = 'kainph_product_image_';

  Future<Map<String, String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final key in prefs.getKeys().where((key) => key.startsWith(_prefix)))
        key.substring(_prefix.length): prefs.getString(key)!,
    };
  }

  Future<void> set(String productId, String? path) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix$productId';
    if (path == null || path.isEmpty) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, path);
    }
  }
}
