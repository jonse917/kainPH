import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/services/tax_settings_store.dart';
import '../../core/theme/kainph_theme.dart';
import '../../core/services/kainph_database.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/cart_item.dart';
import '../../core/widgets/summary_row.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<_Product> _products = const [];

  final Map<String, int> _cart = {};

  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _orderType = 'Dine In';
  String? _customerName;
  String? _tableNumber;
  StreamSubscription? _productsSubscription;

  @override
  void initState() {
    super.initState();
    _productsSubscription = KainPHDatabase.instance.pos.watchAvailableProducts().listen((products) {
      if (!mounted) return;
      setState(() {
        _products = products.map((product) => _Product(
          id: product.id,
          name: product.name,
          category: product.categoryId ?? 'Uncategorized',
          price: product.price,
          icon: _iconForCategory(product.categoryId),
        )).toList();
        _cart.removeWhere((id, _) => !_products.any((product) => product.id == id));
      });
    });
  }

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  List<String> get _categories => [
        'All',
        ..._products.map((product) => product.category).toSet(),
      ];

  List<_Product> get _filteredProducts {
    final q = _searchQuery.trim().toLowerCase();

    final list = _selectedCategory == 'All'
        ? _products
        : _products
            .where((product) => product.category == _selectedCategory)
            .toList();

    if (q.isEmpty) {
      return list;
    }

    return list.where((product) {
      return product.name.toLowerCase().contains(q) ||
          product.category.toLowerCase().contains(q);
    }).toList();
  }

  double get _subtotal {
    double total = 0;

    for (final entry in _cart.entries) {
      final product = _products.firstWhere(
        (product) => product.id == entry.key,
      );

      total += product.price * entry.value;
    }

    return total;
  }

  int get _itemCount {
    return _cart.values.fold(
      0,
      (total, quantity) => total + quantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 800) {
              return _buildPhoneLayout();
            }

            return _buildLargeLayout();
          },
        ),
      ),
    );
  }

  // ============================================================
  // PHONE LAYOUT
  // ============================================================

  Widget _buildPhoneLayout() {
    return Column(
      children: [
        _buildHeader(),
        _buildCategoryBar(),
        Expanded(
          child: _buildProductGrid(),
        ),
        _buildMobileCartBar(),
      ],
    );
  }

  Widget _buildMobileCartBar() {
    return Material(
      elevation: 8,
      color: Theme.of(context).cardColor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$_itemCount item${_itemCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatCurrency(_subtotal),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: _cart.isEmpty ? null : _showCartSheet,
                child: const Text('View Cart'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LARGE LAYOUT
  // ============================================================

  Widget _buildLargeLayout() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildCategoryBar(),
                    Expanded(
                      child: _buildProductGrid(),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: _buildCartPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactHeader = constraints.maxWidth < 900;

        if (compactHeader) {
          final veryCompact = MediaQuery.sizeOf(context).height < 500;
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: veryCompact ? 12 : 16,
              vertical: veryCompact ? 8 : 12,
            ),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.point_of_sale,
                      color: KainPHTheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'New Sale',
                      style: TextStyle(
                        fontSize: veryCompact ? 16 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        final name = await showDialog<String>(
                          context: context,
                          builder: (c) {
                            final controller = TextEditingController(
                                text: _customerName ?? '');
                            return AlertDialog(
                              title: const Text('Select Customer'),
                              content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                    hintText: 'Customer name'),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.of(c).pop(),
                                    child: const Text('Cancel')),
                                ElevatedButton(
                                    onPressed: () => Navigator.of(c)
                                        .pop(controller.text.trim()),
                                    child: const Text('Save')),
                              ],
                            );
                          },
                        );

                        if (name != null) {
                          setState(() {
                            _customerName = name.isEmpty ? null : name;
                          });
                        }
                      },
                      icon: const Icon(Icons.person_add_alt_1_outlined),
                      tooltip: 'Customer',
                    ),
                    IconButton(
                      onPressed: () async {
                        final table = await showDialog<String>(
                          context: context,
                          builder: (c) {
                            final controller =
                                TextEditingController(text: _tableNumber ?? '');
                            return AlertDialog(
                              title: const Text('Table / Reference'),
                              content: TextField(
                                controller: controller,
                                decoration: const InputDecoration(
                                    hintText: 'Table number or reference'),
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.of(c).pop(),
                                    child: const Text('Cancel')),
                                ElevatedButton(
                                    onPressed: () => Navigator.of(c)
                                        .pop(controller.text.trim()),
                                    child: const Text('Save')),
                              ],
                            );
                          },
                        );

                        if (table != null) {
                          setState(() {
                            _tableNumber = table.isEmpty ? null : table;
                          });
                        }
                      },
                      icon: const Icon(Icons.table_chart_outlined),
                      tooltip: 'Table / Ref',
                    ),
                  ],
                ),
                // On very short/landscape screens keep the header to one row.
                // This protects the product grid and cart bar from vertical
                // RenderFlex overflows; the full controls remain available in
                // the regular phone layout.
                if (!veryCompact) ...[
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search products',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Theme.of(context).cardColor,
                      filled: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                  const SizedBox(height: 12),
                  _orderTypeSelector(),
                ],
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE5E7EB),
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.point_of_sale,
                color: KainPHTheme.primary,
              ),
              const SizedBox(width: 10),
              const Text(
                'New Sale',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Theme.of(context).cardColor,
                    filled: true,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              const SizedBox(width: 12),
              _orderTypeSelector(),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () async {
                  final name = await showDialog<String>(
                    context: context,
                    builder: (c) {
                      final controller =
                          TextEditingController(text: _customerName ?? '');
                      return AlertDialog(
                        title: const Text('Select Customer'),
                        content: TextField(
                          controller: controller,
                          decoration:
                              const InputDecoration(hintText: 'Customer name'),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(c).pop(),
                              child: const Text('Cancel')),
                          ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(c).pop(controller.text.trim()),
                              child: const Text('Save')),
                        ],
                      );
                    },
                  );

                  if (name != null) {
                    setState(() {
                      _customerName = name.isEmpty ? null : name;
                    });
                  }
                },
                icon: const Icon(Icons.person_add_alt_1_outlined),
                tooltip: 'Customer',
              ),
              IconButton(
                onPressed: () async {
                  final table = await showDialog<String>(
                    context: context,
                    builder: (c) {
                      final controller =
                          TextEditingController(text: _tableNumber ?? '');
                      return AlertDialog(
                        title: const Text('Table / Reference'),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                              hintText: 'Table number or reference'),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(c).pop(),
                              child: const Text('Cancel')),
                          ElevatedButton(
                              onPressed: () =>
                                  Navigator.of(c).pop(controller.text.trim()),
                              child: const Text('Save')),
                        ],
                      );
                    },
                  );

                  if (table != null) {
                    setState(() {
                      _tableNumber = table.isEmpty ? null : table;
                    });
                  }
                },
                icon: const Icon(Icons.table_chart_outlined),
                tooltip: 'Table / Ref',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _orderTypeSelector() {
    final types = ['Dine In', 'Take Out', 'Delivery', 'Parked'];
    return Wrap(
      spacing: 6,
      children: types.map((t) {
        final selected = _orderType == t;
        return ChoiceChip(
          label: Text(t),
          selected: selected,
          onSelected: (_) => setState(() => _orderType = t),
        );
      }).toList(),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategoryBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth < 600 || constraints.maxHeight < 200;
        final height = isCompact ? 48.0 : 64.0;

        return SizedBox(
          height: height,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(
              horizontal: isCompact ? 12 : 16,
              vertical: isCompact ? 8 : 12,
            ),
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            separatorBuilder: (context, index) {
              return const SizedBox(width: 8);
            },
            itemBuilder: (context, index) {
              final category = _categories[index];
              final selected = category == _selectedCategory;

              return ChoiceChip(
                label: Text(category),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  Widget _buildProductGrid() {
    final products = _filteredProducts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Determine max cross axis extent so more columns appear on larger screens.
        final maxExtent =
            width < 400 ? width / 2 : (width < 800 ? 220.0 : 240.0);
        // Use childAspectRatio to allow height to flow naturally and avoid fixed heights.
        final childAspect = (width < 400) ? 0.95 : (width < 800 ? 1.0 : 1.05);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxExtent,
            childAspectRatio: childAspect,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];

            return KainPHProductCard(
              title: product.name,
              price: product.price,
              icon: product.icon,
              onTap: () => _addToCart(product),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // CART
  // ============================================================

  Widget _buildCartPanel() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Current Order',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (_cart.isNotEmpty)
                    TextButton(
                      onPressed: _clearCart,
                      child: const Text('Clear'),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.restaurant_outlined, size: 16),
                        const SizedBox(width: 8),
                        Text(_orderType),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_customerName != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person, size: 16),
                          const SizedBox(width: 8),
                          Text(_customerName!),
                        ],
                      ),
                    ),
                  if (_tableNumber != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.table_chart, size: 16),
                          const SizedBox(width: 8),
                          Text(_tableNumber!),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: _cart.isEmpty ? _buildEmptyCart() : _buildCartItems(),
        ),
        _buildCartSummary(),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: KainPHTheme.textSecondary,
            ),
            SizedBox(height: 12),
            Text(
              'No items yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tap a product to add it to the order.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: KainPHTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: _cart.entries.map((entry) {
        final product = _products.firstWhere(
          (product) => product.id == entry.key,
        );

        return KainPHCartItem(
          title: product.name,
          icon: product.icon,
          quantity: entry.value,
          lineTotal: _formatCurrency(product.price * entry.value),
          onIncrease: () => _addToCart(product),
          onDecrease: () => _removeFromCart(product),
          onRemove: () => _removeProduct(product),
        );
      }).toList(),
    );
  }

  Widget _buildCartSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Column(
        children: [
          SummaryRow(
            label: 'Items',
            value: '$_itemCount',
          ),
          const SizedBox(height: 8),
          SummaryRow(
            label: 'Subtotal',
            value: _formatCurrency(_subtotal),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _cart.isEmpty ? null : _showCheckoutSheet,
              child: Text(
                'PAY ${_formatCurrency(_subtotal)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CART ACTIONS
  // ============================================================

  void _addToCart(_Product product) {
    setState(() {
      _cart.update(
        product.id,
        (quantity) => quantity + 1,
        ifAbsent: () => 1,
      );
    });
  }

  void _removeFromCart(_Product product) {
    setState(() {
      final quantity = _cart[product.id] ?? 0;

      if (quantity <= 1) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = quantity - 1;
      }
    });
  }

  void _removeProduct(_Product product) {
    setState(() {
      _cart.remove(product.id);
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
  }

  // ============================================================
  // MOBILE CART
  // ============================================================

  void _showCartSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: _buildCartPanel(),
        );
      },
    );
  }

  // ============================================================
  // CHECKOUT
  // ============================================================

  void _showCheckoutSheet() {
    if (_cart.isEmpty) {
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return _CheckoutSheet(
          subtotal: _subtotal,
          itemCount: _itemCount,
          onComplete: _completeSale,
        );
      },
    );
  }

  // ============================================================
  // COMPLETE SALE
  // ============================================================

  Future<void> _completeSale(
    String paymentMethod,
    String discountType,
    double cashReceived,
  ) async {
    if (_cart.isEmpty) {
      return;
    }

    final subtotal = _subtotal;
    final settings = TaxReceiptSettingsStore.current;

    final calculation = TaxCalculator.calculate(
      subtotal: subtotal,
      settings: settings,
      discountType: discountType,
    );

    if (paymentMethod == 'Cash' && cashReceived < calculation.totalAmount) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient cash received.'),
        ),
      );

      return;
    }

    final change =
        paymentMethod == 'Cash' ? cashReceived - calculation.totalAmount : 0.0;

    final now = DateTime.now();

    final saleId = 'SALE-${now.microsecondsSinceEpoch}';

    final receiptNumber =
        '${settings.receiptPrefix}-${now.microsecondsSinceEpoch}';

    final items = <Map<String, dynamic>>[];

    for (final entry in _cart.entries) {
      final product = _products.firstWhere(
        (product) => product.id == entry.key,
      );

      final quantity = entry.value;

      items.add(
        {
          'productId': product.id,
          'productName': product.name,
          'category': product.category,
          'unitPrice': product.price,
          'quantity': quantity,
          'lineTotal': product.price * quantity,
        },
      );
    }

    try {
      await KainPHDatabase.instance.saveSale(
        saleId: saleId,
        receiptNumber: receiptNumber,
        orderType: 'Dine In',
        subtotal: subtotal,
        discountAmount: calculation.discountAmount,
        discountType: discountType,
        taxAmount: calculation.taxAmount,
        totalAmount: calculation.totalAmount,
        paymentMethod: paymentMethod,
        cashReceived: cashReceived,
        changeAmount: change,
        items: items,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();

      setState(() {
        _cart.clear();
      });

      _showSaleComplete(
        paymentMethod: paymentMethod,
        total: calculation.totalAmount,
        change: change,
        taxAmount: calculation.taxAmount,
        discountAmount: calculation.discountAmount,
        settings: settings,
        receiptNumber: receiptNumber,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to save sale: $error',
          ),
        ),
      );
    }
  }
  // ============================================================
  // SALE COMPLETE
  // ============================================================

  Future<void> _showSaleComplete({
    required String paymentMethod,
    required double total,
    required double change,
    required double taxAmount,
    required double discountAmount,
    required TaxReceiptSettings settings,
    required String receiptNumber,
  }) async {
    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: KainPHTheme.primary,
              ),
              SizedBox(width: 10),
              Text('Sale Complete'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummaryRow(
                  label: 'Payment',
                  value: paymentMethod,
                ),

                if (discountAmount > 0) ...[
                  const SizedBox(height: 8),
                  SummaryRow(
                    label: discountTypeLabel(discountAmount, settings),
                    value: '-${_formatCurrency(discountAmount)}',
                  ),
                ],
                Text(
                  receiptNumber,
                  style: const TextStyle(
                    color: KainPHTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                // TAX IS OPTIONAL.
                //
                // Tax is shown only when:
                // 1. A tax amount actually exists.
                // 2. The user enabled "Show Tax on Receipt".
                if (settings.showTaxOnReceipt && taxAmount > 0) ...[
                  const SizedBox(height: 8),
                  SummaryRow(
                    label: _taxLabel(settings),
                    value: _formatCurrency(taxAmount),
                  ),
                ],

                const SizedBox(height: 8),

                SummaryRow(
                  label: 'Total',
                  value: _formatCurrency(total),
                ),

                if (paymentMethod == 'Cash') ...[
                  const SizedBox(height: 8),
                  SummaryRow(
                    label: 'Change',
                    value: _formatCurrency(change),
                  ),
                ],

                const SizedBox(height: 16),

                Text(
                  settings.businessName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (settings.tin.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'TIN: ${settings.tin}',
                    style: const TextStyle(
                      color: KainPHTheme.textSecondary,
                    ),
                  ),
                ],

                if (settings.businessAddress.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      settings.businessAddress,
                      style: const TextStyle(
                        color: KainPHTheme.textSecondary,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                Text(
                  settings.receiptFooter,
                  style: const TextStyle(
                    color: KainPHTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// CHECKOUT SHEET
// ============================================================

class _CheckoutSheet extends StatefulWidget {
  final double subtotal;
  final int itemCount;

  final Future<void> Function(
    String paymentMethod,
    String discountType,
    double cashReceived,
  ) onComplete;

  const _CheckoutSheet({
    required this.subtotal,
    required this.itemCount,
    required this.onComplete,
  });

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  final TextEditingController _cashController = TextEditingController();

  String _paymentMethod = 'Cash';
  String _discountType = 'None';

  bool _isCompleting = false;

  TaxReceiptSettings get _settings {
    return TaxReceiptSettingsStore.current;
  }

  TaxCalculation get _calculation {
    return TaxCalculator.calculate(
      subtotal: widget.subtotal,
      settings: _settings,
      discountType: _discountType,
    );
  }

  double get _discount {
    return _calculation.discountAmount;
  }

  double get _total {
    return _calculation.totalAmount;
  }

  double get _cashReceived {
    return double.tryParse(
          _cashController.text.trim(),
        ) ??
        0;
  }

  double get _change {
    final change = _cashReceived - _total;

    return change < 0 ? 0 : change;
  }

  bool get _canComplete {
    if (_isCompleting) {
      return false;
    }

    if (_paymentMethod != 'Cash') {
      return true;
    }

    return _cashReceived >= _total;
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (!_canComplete) {
      return;
    }

    setState(() {
      _isCompleting = true;
    });

    try {
      await widget.onComplete(
        _paymentMethod,
        _discountType,
        _cashReceived,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        bottom: keyboardHeight,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Checkout',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '${widget.itemCount} item${widget.itemCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: KainPHTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // TOTAL
              // ==================================================

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SummaryRow(
                        label: 'Subtotal',
                        value: _formatCurrency(widget.subtotal),
                      ),

                      if (_discount > 0) ...[
                        const SizedBox(height: 8),
                        SummaryRow(
                          label: 'Discount',
                          value: '-${_formatCurrency(_discount)}',
                        ),
                      ],

                      // ==================================================
                      // OPTIONAL TAX
                      // ==================================================
                      //
                      // No tax appears when:
                      // - Non-VAT
                      // - VAT Exempt
                      // - Tax rate is zero
                      //
                      // And even when tax exists, the receipt display
                      // setting can hide it.

                      if (_settings.showTaxOnReceipt &&
                          _calculation.taxAmount > 0) ...[
                        const SizedBox(height: 8),
                        SummaryRow(
                          label: _taxLabel(_settings),
                          value: _formatCurrency(
                            _calculation.taxAmount,
                          ),
                        ),
                      ],

                      const Divider(height: 24),

                      Row(
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatCurrency(_total),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: KainPHTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ==================================================
              // DISCOUNT
              // ==================================================

              const Text(
                'Discount',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: [
                  _discountChip('None'),
                  if (_settings.enableSeniorPwdDiscount) ...[
                    _discountChip('Senior'),
                    _discountChip('PWD'),
                  ],
                ],
              ),

              const SizedBox(height: 20),

              // ==================================================
              // PAYMENT
              // ==================================================

              const Text(
                'Payment Method',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _paymentChip(
                    'Cash',
                    Icons.payments_outlined,
                  ),
                  _paymentChip(
                    'GCash',
                    Icons.phone_android,
                  ),
                  _paymentChip(
                    'Maya',
                    Icons.account_balance_wallet_outlined,
                  ),
                  _paymentChip(
                    'Card',
                    Icons.credit_card,
                  ),
                ],
              ),

              // ==================================================
              // CASH
              // ==================================================

              if (_paymentMethod == 'Cash') ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _cashController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    labelText: 'Cash Received',
                    prefixText: '₱ ',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SummaryRow(
                  label: 'Change',
                  value: _formatCurrency(_change),
                ),
              ],

              const SizedBox(height: 24),

              // ==================================================
              // COMPLETE SALE
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _canComplete ? _handleComplete : null,
                  child: _isCompleting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'COMPLETE SALE • ${_formatCurrency(_total)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _discountChip(String type) {
    return ChoiceChip(
      label: Text(type),
      selected: _discountType == type,
      onSelected: (_) {
        setState(() {
          _discountType = type;
        });
      },
    );
  }

  Widget _paymentChip(
    String method,
    IconData icon,
  ) {
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 18,
      ),
      label: Text(method),
      selected: _paymentMethod == method,
      onSelected: (_) {
        setState(() {
          _paymentMethod = method;
        });
      },
    );
  }
}

// ============================================================
// PRODUCT CARD
// ============================================================

// Replaced by shared KainPHProductCard in core/widgets

// ============================================================
// PRODUCT MODEL
// ============================================================

class _Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final IconData icon;

  const _Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
  });
}

IconData _iconForCategory(String? category) {
  switch (category) {
    case 'Drinks': return Icons.local_drink;
    case 'Sides': return Icons.fastfood;
    case 'Desserts': return Icons.icecream;
    case 'Grilled': return Icons.outdoor_grill;
    default: return Icons.restaurant;
  }
}

// ============================================================
// TAX LABEL
// ============================================================

String _taxLabel(TaxReceiptSettings settings) {
  switch (settings.taxProfile) {
    case TaxProfile.vatRegistered:
      return 'VAT ${settings.taxRate.toStringAsFixed(0)}%';

    case TaxProfile.custom:
      return 'Tax ${settings.taxRate.toStringAsFixed(0)}%';

    case TaxProfile.nonVat:
      return 'Tax';

    case TaxProfile.vatExempt:
      return 'Tax';
  }
}

// ============================================================
// DISCOUNT LABEL
// ============================================================
//
// Kept as a helper so the sale-complete dialog remains clean.

String discountTypeLabel(
  double discountAmount,
  TaxReceiptSettings settings,
) {
  if (discountAmount <= 0) {
    return 'Discount';
  }

  return 'Discount';
}

// ============================================================
// CURRENCY
// ============================================================

String _formatCurrency(double amount) {
  return '₱${amount.toStringAsFixed(2)}';
}
