import 'package:flutter/material.dart';

import 'core/services/appearance_settings_store.dart';
import 'core/services/kainph_database.dart';
import 'core/theme/kainph_theme.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppearanceSettingsStore.load();

  await KainPHDatabase.instance.initialize();

  runApp(const KainPHApp());
}

class KainPHApp extends StatelessWidget {
  const KainPHApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppearanceSettings>(
      valueListenable: AppearanceSettingsStore.notifier,
      builder: (context, settings, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'KainPH POS',
          theme: KainPHTheme.light(settings),
          darkTheme: KainPHTheme.dark(settings),
          themeMode: switch (settings.themeMode) {
            KainPHThemeMode.light => ThemeMode.light,
            KainPHThemeMode.dark => ThemeMode.dark,
            KainPHThemeMode.system => ThemeMode.system,
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
