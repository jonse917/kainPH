import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'product_card.dart';
import 'product_form.dart';

import '../../core/widgets/responsive.dart';
import '../../core/database/app_database.dart';
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
  late final Stream<List<Product>> _productsStream;
  late final Stream<List<Category>> _categoriesStream;
  Map<String, String> _imagePaths = const {};
  @override
  void initState() {
    super.initState();
    _productsStream = KainPHDatabase.instance.pos.watchProducts();
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
      ));
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
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            onPressed: () => _openAddProduct(_currentCategories),
            icon: const Icon(Icons.add),
            tooltip: 'Add product',
          ),
          IconButton(onPressed: _openCategories, icon: const Icon(Icons.category_outlined), tooltip: 'Manage categories'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(child: StreamBuilder<List<Product>>(
              stream: _productsStream,
              builder: (context, snapshot) {
                  if (snapshot.hasError) return const Center(child: Text('Unable to load products.'));
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final products = snapshot.data!.map((row) => MenuProduct(
                    id: row.id, name: row.name, category: row.categoryId ?? 'Meals', price: row.price,
                    featured: row.featured, available: row.isAvailable, description: row.description, imagePath: _imagePaths[row.id],
                  )).toList();
                  return StreamBuilder<List<Category>>(
                    stream: _categoriesStream,
                    builder: (context, categorySnapshot) {
                      if (!categorySnapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final categories = categorySnapshot.data!.map((category) => category.name).toList();
                      _currentCategories = categories;
                      if (!categories.contains(_selectedCategory)) _selectedCategory = 'All';
                      return Column(children: [
                        _buildControls(isWide, categories), const SizedBox(height: 12),
                        Expanded(child: _buildContent(isWide, products, categories)),
                      ]);
                    },
                  );
              },
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddProduct(_currentCategories),
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildControls(bool isWide, List<String> categories) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldWrap = constraints.maxWidth < 520;

        if (shouldWrap) {
          return Wrap(
            runSpacing: 12,
            spacing: 12,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                child: SizedBox(
                  width: constraints.maxWidth,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search products',
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedCategory,
                items: ['All', ...categories]
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v ?? 'All'),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search products',
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(
              value: _selectedCategory,
              items: ['All', ...categories]
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v ?? 'All'),
            ),
          ],
        );
      },
    );
  }

  List<String> _currentCategories = const [];

  Widget _buildContent(bool isWide, List<MenuProduct> products, List<String> categories) {
    final items = _filtered(products);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text('No products found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Use the Add Product button to create menu items.'),
          ],
        ),
      );
    }

    if (isWide) {
      // Use ResponsiveGrid instead of fixed crossAxisCount grid so columns adapt to available width.
      return ResponsiveGrid(
        children: items.map((p) => ProductCard(product: p, onEdit: () => _openEditProduct(p, categories), onDelete: () => _deleteProduct(p))).toList(),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final p = items[i];
        return ProductCard(product: p, onEdit: () => _openEditProduct(p, categories), onDelete: () => _deleteProduct(p));
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
