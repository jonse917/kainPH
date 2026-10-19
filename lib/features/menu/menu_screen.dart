import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'product_card.dart';
import 'product_form.dart';

import '../../core/theme/kainph_theme.dart';
import '../../core/widgets/category_bar.dart';
import '../../core/widgets/page_header.dart';
import '../../core/widgets/product_grid.dart';
import '../../core/widgets/search_field.dart';
import '../../core/database/app_database.dart';
import '../../core/database/pos_repository.dart';
import '../../core/services/kainph_database.dart';
import '../../core/services/product_image_store.dart';
import 'package:drift/drift.dart' as drift;

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, this.openAddProduct = false});
  final bool openAddProduct;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _search = '';
  String _selectedCategory = 'All';
  final _searchController = TextEditingController();
  late final Stream<List<ProductOffer>> _productsStream;
  late final Stream<List<Category>> _categoriesStream;
  Map<String, String> _imagePaths = const {};
  @override
  void initState() {
    super.initState();
    _productsStream = KainPHDatabase.instance.pos.watchOffers();
    _categoriesStream = KainPHDatabase.instance.pos.watchCategories();
    _loadImages();
    if (widget.openAddProduct) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openAddProduct());
    }
  }

  Future<void> _loadImages() async {
    final images = await ProductImageStore.instance.load();
    if (mounted) setState(() => _imagePaths = images);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MenuProduct> _filtered(List<MenuProduct> products) {
    final q = _search.trim().toLowerCase();
    return products.where((p) {
      final matchCategory = _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchQuery = q.isEmpty || p.name.toLowerCase().contains(q) || p.category.toLowerCase().contains(q);
      return matchCategory && matchQuery;
    }).toList();
  }

  Future<void> _openAddProduct([List<String>? categories]) async {
    final availableCategories = categories?.isNotEmpty == true
        ? categories!
        : (await KainPHDatabase.instance.pos.watchCategories().first)
            .map((category) => category.name)
            .toList();
    if (availableCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Create a category before adding a product.')));
      return;
    }
    final product = await showModalBottomSheet<MenuProduct>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductForm(categories: availableCategories),
    );
    if (product == null) return;
    final now = DateTime.now();
    try {
      await KainPHDatabase.instance.pos.createProduct(ProductsCompanion.insert(
        id: product.id, name: product.name, categoryId: drift.Value(product.category),
        description: drift.Value(product.description),
        price: product.price,
        featured: drift.Value(product.featured), isAvailable: drift.Value(product.available),
        createdAt: now, updatedAt: now,
      ), openingStock: product.stock);
      await ProductImageStore.instance.set(product.id, product.imagePath);
      final imagePaths = await ProductImageStore.instance.load();
      if (!mounted) return;
      // Keep the database stream as the source of truth, but remove any
      // transient UI filter that could hide its newly emitted product.
      setState(() {
        _imagePaths = imagePaths;
        _selectedCategory = 'All';
        _search = '';
      });
      _searchController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} added to the menu.')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add product: $error')),
        );
      }
    }
  }

  Future<void> _openEditProduct(MenuProduct product, List<String> categories) async {
    final availableCategories = categories.contains(product.category)
        ? categories
        : [product.category, ...categories];
    final updated = await showModalBottomSheet<MenuProduct>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ProductForm(product: product, categories: availableCategories),
    );
    if (updated == null) return;
    await KainPHDatabase.instance.pos.updateProduct(product.id, ProductsCompanion(
      name: drift.Value(updated.name), categoryId: drift.Value(updated.category), price: drift.Value(updated.price),
      featured: drift.Value(updated.featured), isAvailable: drift.Value(updated.available),
      description: drift.Value(updated.description),
    ));
    await ProductImageStore.instance.set(product.id, updated.imagePath);
    final imagePaths = await ProductImageStore.instance.load();
    if (mounted) setState(() => _imagePaths = imagePaths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            KainPHPageHeader(
              title: 'Menu',
              subtitle: 'Products available at the register.',
              actions: [
                IconButton(
                  onPressed: _openCategories,
                  icon: const Icon(Icons.category_outlined),
                  tooltip: 'Categories',
                ),
                FilledButton.icon(
                  onPressed: () => _openAddProduct(_currentCategories),
                  icon: const Icon(Icons.add),
                  label: const Text('Add product'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: StreamBuilder<List<ProductOffer>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('Unable to load products.'));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final products = snapshot.data!.map((offer) => MenuProduct(
                    id: offer.product.id, name: offer.product.name, category: offer.product.categoryId ?? 'Meals', price: offer.product.price,
                    featured: offer.product.featured, available: offer.product.isAvailable, description: offer.product.description, imagePath: _imagePaths[offer.product.id],
                    stock: offer.stock, reorderLevel: offer.reorderLevel,
                  )).toList();
                  return StreamBuilder<List<Category>>(
                    stream: _categoriesStream,
                    builder: (context, categorySnapshot) {
                      if (!categorySnapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final categories = categorySnapshot.data!.map((category) => category.name).toList();
                      _currentCategories = categories;
                      if (!categories.contains(_selectedCategory)) _selectedCategory = 'All';
                      return Column(children: [
                        KainPHSearchField(
                          controller: _searchController,
                          hint: 'Search products',
                          onChanged: (value) => setState(() => _search = value),
                        ),
                        const SizedBox(height: 12),
                        KainPHCategoryBar(
                          categories: ['All', ...categories],
                          selected: _selectedCategory,
                          onSelected: (value) => setState(() => _selectedCategory = value),
                        ),
                        const SizedBox(height: 12),
                        Expanded(child: _buildContent(products, categories)),
                      ]);
                    },
                  );
              },
            )),
          ],
        ),
      ),
    );
  }

  List<String> _currentCategories = const [];

  Widget _buildContent(List<MenuProduct> products, List<String> categories) {
    final items = _filtered(products);

    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, size: 48, color: KainPHTheme.sand),
            SizedBox(height: 12),
            Text('No products found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: KainPHTheme.textPrimary)),
            SizedBox(height: 6),
            Text('Add a product to show it here and on the register.', style: TextStyle(color: KainPHTheme.textSecondary)),
          ],
        ),
      );
    }

    return KainPHProductGrid(
      itemCount: items.length,
      itemBuilder: (_, index) {
        final product = items[index];
        return ProductCard(
          product: product,
          onEdit: () => _openEditProduct(product, categories),
          onDelete: () => _deleteProduct(product),
        );
      },
    );
  }

  Future<void> _deleteProduct(MenuProduct product) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Delete product'), content: Text('Delete ${product.name}? Historical sales will be kept.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))],
    ));
    if (confirmed == true) await KainPHDatabase.instance.pos.deleteProduct(product.id);
    if (confirmed == true) {
      await ProductImageStore.instance.set(product.id, null);
      final imagePaths = await ProductImageStore.instance.load();
      if (mounted) setState(() => _imagePaths = imagePaths);
    }
  }

  Future<void> _openCategories() async {
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (_) => const _CategoryManager());
  }
}

class _CategoryManager extends StatelessWidget {
  const _CategoryManager();
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: StreamBuilder<List<Category>>(stream: KainPHDatabase.instance.pos.watchCategories(), builder: (context, snapshot) {
      final categories = snapshot.data ?? const <Category>[];
      return SizedBox(height: 440, child: Column(children: [
        const ListTile(title: Text('Manage Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
        Expanded(child: ListView.builder(itemCount: categories.length, itemBuilder: (_, index) {
          final category = categories[index];
          return ListTile(title: Text(category.name), trailing: Wrap(children: [
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(context, category)),
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _delete(context, category)),
          ]));
        })),
        Padding(padding: const EdgeInsets.all(16), child: FilledButton.icon(onPressed: () => _create(context), icon: const Icon(Icons.add), label: const Text('Add Category')),
      )]));
    }),
  ));

  Future<void> _create(BuildContext context) => _prompt(context, title: 'Add Category', onSave: KainPHDatabase.instance.pos.createCategory);
  Future<void> _edit(BuildContext context, Category category) => _prompt(context, title: 'Edit Category', initial: category.name, onSave: (name) => KainPHDatabase.instance.pos.renameCategory(category.id, name));
  Future<void> _prompt(BuildContext context, {required String title, String initial = '', required Future<void> Function(String) onSave}) async {
    final controller = TextEditingController(text: initial);
    final name = await showDialog<String>(context: context, builder: (dialogContext) => AlertDialog(title: Text(title), content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(labelText: 'Category name')), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text), child: const Text('Save'))]));
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;
    try { await onSave(name); } catch (_) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not save category. Category names must be unique.'))); }
  }
  Future<void> _delete(BuildContext context, Category category) async {
    final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: const Text('Delete category'), content: Text('Delete ${category.name}? Products will become uncategorized.'), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete'))]));
    if (confirmed == true) await KainPHDatabase.instance.pos.deleteCategory(category.id);
  }
}
