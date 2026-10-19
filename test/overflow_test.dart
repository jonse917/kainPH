import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kainph/core/widgets/app_shell.dart';
import 'package:kainph/features/dashboard/dashboard_screen.dart';
import 'package:kainph/features/inventory/inventory_screen.dart';
import 'package:kainph/features/menu/menu_screen.dart';
import 'package:kainph/features/pos/pos_screen.dart';
import 'package:kainph/features/settings/appearance_settings_screen.dart';
import 'package:kainph/features/settings/settings_home_screen.dart';
import 'package:kainph/features/settings/tax_receipt_settings_screen.dart';

void main() {
  final sizes = <Size>[
    const Size(1280, 800),
    const Size(900, 700),
    const Size(390, 844),
    const Size(800, 420),
  ];

  final pages = <String, Widget Function()>{
    'shell': () => const KainPHAppShell(),
    'settings': () => const SettingsHomeScreen(),
    'appearance': () => const AppearanceSettingsScreen(),
    'tax': () => const TaxReceiptSettingsScreen(),
    'dashboard': () => const DashboardScreen(),
    'pos': () => const PosScreen(),
    'menu': () => const MenuScreen(),
    'inventory': () => const InventoryScreen(),
  };

  for (final size in sizes) {
    for (final page in pages.entries) {
      testWidgets('${page.key} ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        final overflows = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (details) {
          final message = details.exceptionAsString();
          if (message.contains('overflowed')) {
            final info = details.informationCollector?.call().map((node) => node.toString()).join('\n') ?? '';
            overflows.add('$message\n$info');
            return;
          }
          previous?.call(details);
        };
        addTearDown(() => FlutterError.onError = previous);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.binding.setSurfaceSize(size);
        await tester.pumpWidget(MaterialApp(home: page.value()));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        FlutterError.onError = previous;

        expect(overflows, isEmpty, reason: overflows.join('\n'));
      });
    }
  }
}
