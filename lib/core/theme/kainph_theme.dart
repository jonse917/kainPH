import 'package:flutter/material.dart';

import '../services/appearance_settings_store.dart';

class KainPHTypography {
  const KainPHTypography._();

  static TextTheme scaleTextTheme({
    required Brightness brightness,
    required double scale,
  }) {
    final base = brightness == Brightness.dark
        ? ThemeData.dark(useMaterial3: true).textTheme
        : ThemeData.light(useMaterial3: true).textTheme;

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: (32 * scale).roundToDouble()),
      displayMedium: base.displayMedium?.copyWith(fontSize: (28 * scale).roundToDouble()),
      displaySmall: base.displaySmall?.copyWith(fontSize: (24 * scale).roundToDouble()),
      headlineLarge: base.headlineLarge?.copyWith(fontSize: (26 * scale).roundToDouble()),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: (22 * scale).roundToDouble()),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: (20 * scale).roundToDouble()),
      titleLarge: base.titleLarge?.copyWith(fontSize: (18 * scale).roundToDouble()),
      titleMedium: base.titleMedium?.copyWith(fontSize: (16 * scale).roundToDouble()),
      titleSmall: base.titleSmall?.copyWith(fontSize: (14 * scale).roundToDouble()),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: (16 * scale).roundToDouble()),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: (14 * scale).roundToDouble()),
      bodySmall: base.bodySmall?.copyWith(fontSize: (12 * scale).roundToDouble()),
      labelLarge: base.labelLarge?.copyWith(fontSize: (14 * scale).roundToDouble()),
      labelMedium: base.labelMedium?.copyWith(fontSize: (12 * scale).roundToDouble()),
      labelSmall: base.labelSmall?.copyWith(fontSize: (11 * scale).roundToDouble()),
    );
  }
}

class KainPHTheme {
  KainPHTheme._();

  static const Color primary = Color(0xFFE85D04);
  static const Color background = Color(0xFFF8F7F4);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);

  static const double radiusSmall = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge = 16;

  static const double spacingSmall = 8;
  static const double spacingMedium = 16;
  static const double spacingLarge = 24;

  static ThemeData light([AppearanceSettings? settings]) {
    final appearance = settings ?? AppearanceSettings.defaultSettings;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: appearance.accentColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      visualDensity: _visualDensityFor(appearance.density),
      scaffoldBackgroundColor: background,
      primaryColor: appearance.accentColor,
      colorScheme: colorScheme,
      textTheme: KainPHTypography.scaleTextTheme(
        brightness: Brightness.light,
        scale: appearance.fontScaleFactor,
      ).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    );
  }

  static ThemeData dark([AppearanceSettings? settings]) {
    final appearance = settings ?? AppearanceSettings.defaultSettings;

    final darkScheme = ColorScheme.fromSeed(
      seedColor: appearance.accentColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      visualDensity: _visualDensityFor(appearance.density),
      primaryColor: appearance.accentColor,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: const Color(0xFF111827),
      textTheme: KainPHTypography.scaleTextTheme(
        brightness: Brightness.dark,
        scale: appearance.fontScaleFactor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111827),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
      ),
    );
  }

  static ThemeData resolveTheme(AppearanceSettings settings) {
    final brightness = switch (settings.themeMode) {
      KainPHThemeMode.light => Brightness.light,
      KainPHThemeMode.dark => Brightness.dark,
      KainPHThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };

    return brightness == Brightness.dark ? dark(settings) : light(settings);
  }

  static VisualDensity _visualDensityFor(KainPHDensity density) {
    switch (density) {
      case KainPHDensity.comfortable:
        return VisualDensity.comfortable;
      case KainPHDensity.standard:
        return VisualDensity.standard;
      case KainPHDensity.compact:
        return VisualDensity.compact;
    }
  }
}
