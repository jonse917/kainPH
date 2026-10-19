import 'package:flutter/material.dart';

import '../../core/services/appearance_settings_store.dart';
import '../../core/theme/kainph_catalog.dart';
import '../../core/theme/kainph_theme.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/menu/menu_screen.dart';
import '../../features/pos/pos_screen.dart';
import '../../features/settings/settings_home_screen.dart';

class KainPHAppShell extends StatefulWidget {
  const KainPHAppShell({super.key});

  @override
  State<KainPHAppShell> createState() => _KainPHAppShellState();
}

class _KainPHAppShellState extends State<KainPHAppShell> {
  int _selectedIndex = 1;
  bool _openMenuProductForm = false;

  final List<_NavigationItem> _items = const [
    _NavigationItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
    ),
    _NavigationItem(
      label: 'POS',
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale,
    ),
    _NavigationItem(
      label: 'Menu',
      icon: Icons.restaurant_menu_outlined,
      selectedIcon: Icons.restaurant_menu,
    ),
    _NavigationItem(
      label: 'Inventory',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
    ),
    _NavigationItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final navigationMode = AppearanceSettingsStore.current.navigationMode;

    if (width < 700 || navigationMode == KainPHNavigationMode.bottom) {
      return _buildPhoneLayout();
    }

    if (navigationMode == KainPHNavigationMode.compactSidebar) {
      return _buildCompactSidebarLayout();
    }

    return _buildLargeLayout();
  }

  Widget _buildPhoneLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectPage,
        destinations: [
          for (final item in _items)
            NavigationDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: item.label,
            ),
        ],
      ),
    );
  }

  Widget _buildLargeLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildNavigationRail(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _canvas(_buildContent()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSidebarLayout() {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 88,
            child: NavigationRail(
              backgroundColor: KainPHTheme.coffee,
              indicatorColor: KainPHTheme.primary,
              selectedIconTheme: const IconThemeData(color: Colors.white),
              unselectedIconTheme: const IconThemeData(color: Color(0xFFF7EFE5)),
              selectedLabelTextStyle: const TextStyle(color: KainPHTheme.primary, fontSize: 11),
              unselectedLabelTextStyle: const TextStyle(color: Color(0xFFF7EFE5), fontSize: 11),
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectPage,
              extended: false,
              scrollable: true,
              labelType: NavigationRailLabelType.all,
              minWidth: 72,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Icon(Icons.coffee, color: KainPHTheme.primary),
              ),
              destinations: _items
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _canvas(_buildContent()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _canvas(Widget child) {
    return ColoredBox(
      color: KainPHTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: child,
        ),
      ),
    );
  }

  Widget _buildNavigationRail() {
    final isExtended = MediaQuery.sizeOf(context).width >= 1000;

    return NavigationRail(
      backgroundColor: KainPHTheme.coffee,
      selectedIndex: _selectedIndex,
      onDestinationSelected: _selectPage,
      extended: isExtended,
      scrollable: true,
      minWidth: 80,
      indicatorColor: KainPHTheme.primary,
      selectedIconTheme: const IconThemeData(color: Colors.white),
      unselectedIconTheme: const IconThemeData(color: Color(0xFFF7EFE5)),
      selectedLabelTextStyle: const TextStyle(color: KainPHTheme.primary, fontSize: 12),
      unselectedLabelTextStyle: const TextStyle(color: Color(0xFFF7EFE5), fontSize: 12),
      labelType: isExtended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: isExtended
            ? Image.asset(KainPHCatalog.wordmark, height: 36)
            : const Icon(Icons.coffee, color: KainPHTheme.primary),
      ),
      destinations: _items
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: KainPHTheme.coffee,
      foregroundColor: Colors.white,
      title: Image.asset(KainPHCatalog.wordmark, height: 32),
      actions: [
        _offlineBadge(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTopBar() {
    // Responsive top bar: reduce height on small/landscape displays so content keeps priority.
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxH = constraints.maxHeight.isFinite ? constraints.maxHeight : 72.0;
        // Prefer a compact top bar when vertical space is limited.
        final height = (maxH * 0.08).clamp(48.0, 72.0);
        final isCompact = height <= 56.0 || MediaQuery.sizeOf(context).width < 600;

        return ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48, maxHeight: 72),
          child: Container(
            height: height,
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 24),
            decoration: const BoxDecoration(
              color: KainPHTheme.coffee,
              border: Border(
                bottom: BorderSide(color: Color(0x22FFFFFF)),
              ),
            ),
            child: Row(
              children: [
                Image.asset(KainPHCatalog.wordmark, height: isCompact ? 28 : 34),
                const SizedBox(width: 8),
                _offlineBadge(),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: KainPHTheme.primary,
                  child: Icon(Icons.person_outline, color: Colors.white, size: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _offlineBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 16,
            color: Color(0xFFB7E4C7),
          ),
          SizedBox(width: 6),
          Text(
            'Offline',
            style: TextStyle(
              color: Color(0xFFB7E4C7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return DashboardScreen(
          onNavigate: _selectPage,
          onAddProduct: () => setState(() {
            _selectedIndex = 2;
            _openMenuProductForm = true;
          }),
        );
      case 1:
        return const PosScreen();
      case 2:
        return MenuScreen(key: ValueKey('menu-$_openMenuProductForm'), openAddProduct: _openMenuProductForm);
      case 3:
        return const InventoryScreen();
      case 4:
        return const SettingsHomeScreen();
      default:
        return const DashboardScreen();
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
      if (index != 2) _openMenuProductForm = false;
    });
  }
}

class _NavigationItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
