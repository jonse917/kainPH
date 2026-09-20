import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum KainPHThemeMode {
  light,
  dark,
  system,
}

enum KainPHDensity {
  comfortable,
  standard,
  compact,
}

enum KainPHFontScale {
  small,
  standard,
  large,
}

enum KainPHNavigationMode {
  sidebar,
  compactSidebar,
  bottom,
}

enum KainPHDashboardLayout {
  standard,
  salesFocus,
  operations,
  minimal,
}

class AppearanceSettings {
  final KainPHThemeMode themeMode;
  final Color accentColor;
  final KainPHDensity density;
  final KainPHFontScale fontScale;
  final KainPHNavigationMode navigationMode;
  final KainPHDashboardLayout dashboardLayout;
  final Set<String> visibleSections;
  final String? businessLogoPath;
  final String businessName;
  final String businessTagline;
  final Color brandColor;

  const AppearanceSettings({
    this.themeMode = KainPHThemeMode.light,
    this.accentColor = const Color(0xFFE85D04),
    this.density = KainPHDensity.standard,
    this.fontScale = KainPHFontScale.standard,
    this.navigationMode = KainPHNavigationMode.sidebar,
    this.dashboardLayout = KainPHDashboardLayout.standard,
    this.visibleSections = const {
      'Sales Overview',
      'Quick Actions',
      'Low Stock',
      'Recent Orders',
      'Business Pulse',
      'Top Products',
      'Payment Summary',
    },
    this.businessLogoPath,
    this.businessName = 'KainPH Food Business',
    this.businessTagline = 'Serving every meal with warmth.',
    this.brandColor = const Color(0xFFE85D04),
  });

  double get fontScaleFactor {
    switch (fontScale) {
      case KainPHFontScale.small:
        return 0.92;
      case KainPHFontScale.standard:
        return 1.0;
      case KainPHFontScale.large:
        return 1.12;
    }
  }

  double get densityMultiplier {
    switch (density) {
      case KainPHDensity.comfortable:
        return 1.16;
      case KainPHDensity.standard:
        return 1.0;
      case KainPHDensity.compact:
        return 0.86;
    }
  }

  AppearanceSettings copyWith({
    KainPHThemeMode? themeMode,
    Color? accentColor,
    KainPHDensity? density,
    KainPHFontScale? fontScale,
    KainPHNavigationMode? navigationMode,
    KainPHDashboardLayout? dashboardLayout,
    Set<String>? visibleSections,
    String? businessLogoPath,
    bool clearBusinessLogo = false,
    String? businessName,
    String? businessTagline,
    Color? brandColor,
  }) {
    return AppearanceSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      density: density ?? this.density,
      fontScale: fontScale ?? this.fontScale,
      navigationMode: navigationMode ?? this.navigationMode,
      dashboardLayout: dashboardLayout ?? this.dashboardLayout,
      visibleSections: visibleSections ?? this.visibleSections,
      businessLogoPath: clearBusinessLogo ? null : (businessLogoPath ?? this.businessLogoPath),
      businessName: businessName ?? this.businessName,
      businessTagline: businessTagline ?? this.businessTagline,
      brandColor: brandColor ?? this.brandColor,
    );
  }

  static AppearanceSettings get defaultSettings => const AppearanceSettings();
}

class AppearanceSettingsStore {
  static const _themeModeKey = 'kainph_appearance_theme_mode';
  static const _accentColorKey = 'kainph_appearance_accent_color';
  static const _densityKey = 'kainph_appearance_density';
  static const _fontScaleKey = 'kainph_appearance_font_scale';
  static const _navigationModeKey = 'kainph_appearance_navigation_mode';
  static const _dashboardLayoutKey = 'kainph_appearance_dashboard_layout';
  static const _visibleSectionsKey = 'kainph_appearance_visible_sections';
  static const _businessLogoPathKey = 'kainph_appearance_business_logo_path';
  static const _businessNameKey = 'kainph_appearance_business_name';
  static const _businessTaglineKey = 'kainph_appearance_business_tagline';
  static const _brandColorKey = 'kainph_appearance_brand_color';

  static final ValueNotifier<AppearanceSettings> notifier =
      ValueNotifier(AppearanceSettings.defaultSettings);

  static AppearanceSettings get current => notifier.value;

  static Future<AppearanceSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    final themeModeIndex = prefs.getInt(_themeModeKey)?.clamp(0, KainPHThemeMode.values.length - 1) ??
        KainPHThemeMode.light.index;
    final densityIndex = prefs.getInt(_densityKey)?.clamp(0, KainPHDensity.values.length - 1) ??
        KainPHDensity.standard.index;
    final fontScaleIndex = prefs.getInt(_fontScaleKey)?.clamp(0, KainPHFontScale.values.length - 1) ??
        KainPHFontScale.standard.index;
    final navigationModeIndex = prefs.getInt(_navigationModeKey)?.clamp(0, KainPHNavigationMode.values.length - 1) ??
        KainPHNavigationMode.sidebar.index;
    final dashboardLayoutIndex = prefs.getInt(_dashboardLayoutKey)?.clamp(0, KainPHDashboardLayout.values.length - 1) ??
        KainPHDashboardLayout.standard.index;

    final settings = AppearanceSettings(
      themeMode: KainPHThemeMode.values[themeModeIndex],
      accentColor: _colorFromInt(prefs.getInt(_accentColorKey) ?? const Color(0xFFE85D04).toARGB32()),
      density: KainPHDensity.values[densityIndex],
      fontScale: KainPHFontScale.values[fontScaleIndex],
      navigationMode: KainPHNavigationMode.values[navigationModeIndex],
      dashboardLayout: KainPHDashboardLayout.values[dashboardLayoutIndex],
      visibleSections: (prefs.getStringList(_visibleSectionsKey) ?? const [
        'Sales Overview',
        'Quick Actions',
        'Low Stock',
        'Recent Orders',
        'Business Pulse',
        'Top Products',
        'Payment Summary',
      ]).toSet(),
      businessLogoPath: prefs.getString(_businessLogoPathKey),
      businessName: prefs.getString(_businessNameKey) ?? 'KainPH Food Business',
      businessTagline: prefs.getString(_businessTaglineKey) ?? 'Serving every meal with warmth.',
      brandColor: _colorFromInt(prefs.getInt(_brandColorKey) ?? const Color(0xFFE85D04).toARGB32()),
    );

    notifier.value = settings;
    return settings;
  }

  static Future<void> save(AppearanceSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_themeModeKey, settings.themeMode.index);
    await prefs.setInt(_accentColorKey, settings.accentColor.toARGB32());
    await prefs.setInt(_densityKey, settings.density.index);
    await prefs.setInt(_fontScaleKey, settings.fontScale.index);
    await prefs.setInt(_navigationModeKey, settings.navigationMode.index);
    await prefs.setInt(_dashboardLayoutKey, settings.dashboardLayout.index);
    await prefs.setStringList(_visibleSectionsKey, settings.visibleSections.toList());
    if (settings.businessLogoPath != null) {
      await prefs.setString(_businessLogoPathKey, settings.businessLogoPath!);
    } else {
      await prefs.remove(_businessLogoPathKey);
    }
    await prefs.setString(_businessNameKey, settings.businessName);
    await prefs.setString(_businessTaglineKey, settings.businessTagline);
    await prefs.setInt(_brandColorKey, settings.brandColor.toARGB32());

    notifier.value = settings;
  }

  static Future<void> reset() async {
    final defaults = AppearanceSettings.defaultSettings;
    await save(defaults);
  }

  static Color _colorFromInt(int value) => Color(value);
}

String appearanceSettingsToJson(AppearanceSettings settings) {
  final map = <String, dynamic>{
    'themeMode': settings.themeMode.index,
    'accentColor': settings.accentColor.toARGB32(),
    'density': settings.density.index,
    'fontScale': settings.fontScale.index,
    'navigationMode': settings.navigationMode.index,
    'dashboardLayout': settings.dashboardLayout.index,
    'visibleSections': settings.visibleSections.toList(),
    'businessLogoPath': settings.businessLogoPath,
    'businessName': settings.businessName,
    'businessTagline': settings.businessTagline,
    'brandColor': settings.brandColor.toARGB32(),
  };
  return const JsonEncoder().convert(map);
}
