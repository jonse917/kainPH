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

  static const Color primary = Color(0xFFF56B0B);
  static const Color primaryPressed = Color(0xFFDE5900);
  static const Color background = Color(0xFFFFF9F1);
  static const Color surface = Color(0xFFF7EFE5);
  static const Color coffee = Color(0xFF382116);
  static const Color coffeeRaised = Color(0xFF4A2D1E);
  static const Color sand = Color(0xFFE8DCCE);

  static const Color textPrimary = Color(0xFF241B16);
  static const Color textSecondary = Color(0xFF75685D);

  static const Color success = Color(0xFF2E9D57);
  static const Color warning = Color(0xFFE7A12C);
  static const Color danger = Color(0xFFC53B32);

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
      primary: appearance.accentColor,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: textPrimary,
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
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: textSecondary),
        prefixIconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: sand),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: sand),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: appearance.accentColor, width: 1.5),
        ),
      ),
      dividerTheme: const DividerThemeData(color: sand, thickness: 1, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        indicatorColor: appearance.accentColor.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            letterSpacing: 0.2,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? coffee : textSecondary,
          );
        }),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: sand.withValues(alpha: 0.85)),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        selectedColor: appearance.accentColor,
        backgroundColor: Colors.white,
        side: BorderSide(color: sand.withValues(alpha: 0.9)),
        labelStyle: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500, letterSpacing: 0.15),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: appearance.accentColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(44, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
