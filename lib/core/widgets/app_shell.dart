import 'package:flutter/material.dart';

import '../../core/services/appearance_settings_store.dart';
import '../../core/theme/kainph_theme.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/cashier/cashier_screen.dart';
import '../../features/customers/customers_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/inventory/inventory_screen.dart';
import '../../features/marketing/marketing_screen.dart';
import '../../features/menu/menu_screen.dart';
import '../../features/pos/pos_screen.dart';
import '../../features/receipts/receipts_screen.dart';
import '../../features/security/security_screen.dart';
import '../../features/settings/settings_home_screen.dart';
import '../../features/system/system_screen.dart';

class KainPHAppShell extends StatefulWidget {
  const KainPHAppShell({super.key});

  @override
  State<KainPHAppShell> createState() => _KainPHAppShellState();
}

class _KainPHAppShellState extends State<KainPHAppShell> {
  int _selectedIndex = 0;
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
      label: 'Cashier',
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
    ),
    _NavigationItem(
      label: 'Customers',
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
    ),
    _NavigationItem(
      label: 'Marketing',
      icon: Icons.campaign_outlined,
      selectedIcon: Icons.campaign,
    ),
    _NavigationItem(
      label: 'Analytics',
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
    ),
    _NavigationItem(
      label: 'Receipts',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
    ),
    _NavigationItem(
      label: 'Security',
      icon: Icons.security_outlined,
      selectedIcon: Icons.security,
    ),
    _NavigationItem(
      label: 'System',
      icon: Icons.settings_applications_outlined,
      selectedIcon: Icons.settings_applications,
    ),
    _NavigationItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  final List<int> _phoneDestinations = const [0, 1, 2, 3];

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
    final isMoreSelected = _selectedIndex >= 4;

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildContent(),
      bottomNavigationBar: NavigationBar(
        selectedIndex:
            isMoreSelected ? 4 : _phoneDestinations.indexOf(_selectedIndex),
        onDestinationSelected: _onPhoneDestinationSelected,
        destinations: [
          ..._phoneDestinations.map(
            (index) => NavigationDestination(
              icon: Icon(_items[index].icon),
              selectedIcon: Icon(_items[index].selectedIcon),
              label: _items[index].label,
            ),
          ),
          const NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }

  void _onPhoneDestinationSelected(int index) {
    if (index < 4) {
      setState(() {
        _selectedIndex = _phoneDestinations[index];
      });
      return;
    }

    _showMoreMenu();
  }

  void _showMoreMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 12),
                child: Text(
                  'More',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              for (final index in [4, 5, 6, 7, 8, 9, 10, 11])
                ListTile(
                  leading: Icon(
                    _items[index].icon,
                    color: KainPHTheme.primary,
                  ),
                  title: Text(_items[index].label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),
            ],
          ),
        );
      },
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
                  child: _buildContent(),
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
              selectedIndex: _selectedIndex,
              onDestinationSelected: _selectPage,
              extended: false,
              labelType: NavigationRailLabelType.all,
              destinations: _items
                  .map(
                    (item) => NavigationRailDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: Text(item.label),
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
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRail() {
    final isExtended = MediaQuery.sizeOf(context).width >= 1000;

    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _selectPage,
      extended: isExtended,
      labelType: isExtended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      leading: const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          '🍴',
          style: TextStyle(fontSize: 28),
        ),
      ),
      destinations: _items
          .map(
            (item) => NavigationRailDestination(
              icon: Icon(item.icon),
              selectedIcon: Icon(item.selectedIcon),
              label: Text(item.label),
            ),
          )
          .toList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        '🍴 KainPH',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
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
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: const Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    'KainPH POS',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isCompact ? 16 : 20,
                          color: KainPHTheme.textPrimary,
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                _offlineBadge(),
                const SizedBox(width: 12),
                const CircleAvatar(
                  radius: 18,
                  child: Icon(Icons.person_outline),
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
        color: KainPHTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off,
            size: 16,
            color: KainPHTheme.success,
          ),
          SizedBox(width: 6),
          Text(
            'Offline',
            style: TextStyle(
              color: KainPHTheme.success,
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
        return const CashierScreen();
      case 5:
        return const CustomersScreen();
      case 6:
        return const MarketingScreen();
      case 7:
        return const AnalyticsScreen();
      case 8:
        return const ReceiptsScreen();
      case 9:
        return const SecurityScreen();
      case 10:
        return const SystemScreen();
      case 11:
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
