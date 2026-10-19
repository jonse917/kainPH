import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/services/appearance_settings_store.dart';
import '../../core/theme/kainph_theme.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  late AppearanceSettings _settings;
  final ImagePicker _picker = ImagePicker();
  final _businessNameController = TextEditingController();
  final _businessTaglineController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _settings = AppearanceSettingsStore.current;
    _businessNameController.text = _settings.businessName;
    _businessTaglineController.text = _settings.businessTagline;
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessTaglineController.dispose();
    super.dispose();
  }

  Future<void> _applySettings() async {
    final updated = _settings.copyWith(
      businessName: _businessNameController.text.trim().isNotEmpty
          ? _businessNameController.text.trim()
          : 'KainPH Food Business',
      businessTagline: _businessTaglineController.text.trim().isNotEmpty
          ? _businessTaglineController.text.trim()
          : 'Serving every meal with warmth.',
    );

    setState(() {
      _settings = updated;
    });

    await AppearanceSettingsStore.save(updated);
  }

  Future<void> _resetDefaults() async {
    if (!mounted) {
      return;
    }

    final currentContext = context;
    final confirmed = await showDialog<bool>(
      context: currentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset appearance?'),
          content: const Text('Reset appearance to KainPH defaults?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final defaults = AppearanceSettings.defaultSettings;
    setState(() {
      _settings = defaults;
      _businessNameController.text = defaults.businessName;
      _businessTaglineController.text = defaults.businessTagline;
    });
    await AppearanceSettingsStore.reset();
  }

  Future<void> _pickCustomAccentColor() async {
    if (!mounted) {
      return;
    }

    final currentContext = context;
    final messenger = ScaffoldMessenger.of(currentContext);
    final controller = TextEditingController(
      text: _settings.accentColor.toARGB32().toRadixString(16).toUpperCase().padLeft(6, '0'),
    );

    final picked = await showDialog<String>(
      context: currentContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Custom Accent Color'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Hex color (e.g. FF8A3D)',
                prefixText: '#',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    if (picked == null || picked.isEmpty) {
      return;
    }

    final hex = picked.replaceAll('#', '').trim();
    if (hex.length != 6) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Use a 6-digit hex color like FF8A3D.')),
      );
      return;
    }

    final parsed = int.tryParse('FF$hex', radix: 16);
    if (parsed == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Color value is invalid.')),
      );
      return;
    }

    final updated = _settings.copyWith(accentColor: Color(parsed));
    if (!mounted) {
      return;
    }
    setState(() => _settings = updated);
    await AppearanceSettingsStore.save(updated);
  }

  Future<void> _pickLogo() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    final updated = _settings.copyWith(businessLogoPath: picked.path);
    setState(() => _settings = updated);
    await AppearanceSettingsStore.save(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        actions: [
          TextButton.icon(
            onPressed: _resetDefaults,
            icon: const Icon(Icons.refresh_outlined),
            label: const Text('Reset'),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 960;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildSettingsPanel()),
                          const SizedBox(width: 20),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: _AppearancePreview(settings: _settings),
                          ),
                        ],
                      )
                    else ...[
                      _buildSettingsPanel(),
                      const SizedBox(height: 20),
                      _AppearancePreview(settings: _settings),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: 'Appearance',
          children: [
            _OptionRow(
              title: 'Theme',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: KainPHThemeMode.values
                    .map(
                      (mode) => ChoiceChip(
                        label: Text(_themeLabel(mode)),
                        selected: _settings.themeMode == mode,
                        onSelected: (_) async {
                          setState(() => _settings = _settings.copyWith(themeMode: mode));
                          await AppearanceSettingsStore.save(_settings);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            _OptionRow(
              title: 'Accent Color',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...[
                    const Color(0xFFE85D04),
                    const Color(0xFFEA580C),
                    const Color(0xFF16A34A),
                    const Color(0xFF2563EB),
                    const Color(0xFF7C3AED),
                    const Color(0xFFDC2626),
                  ].map(
                    (color) => GestureDetector(
                      onTap: () async {
                        final updated = _settings.copyWith(accentColor: color);
                        setState(() => _settings = updated);
                        await AppearanceSettingsStore.save(updated);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _settings.accentColor == color ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickCustomAccentColor,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                        border: Border.all(color: KainPHTheme.primary, width: 1.5),
                      ),
                      child: const Icon(Icons.color_lens_outlined, size: 16, color: KainPHTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
            _OptionRow(
              title: 'Interface Density',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: KainPHDensity.values
                    .map(
                      (d) => ChoiceChip(
                        label: Text(_densityLabel(d)),
                        selected: _settings.density == d,
                        onSelected: (_) async {
                          setState(() => _settings = _settings.copyWith(density: d));
                          await AppearanceSettingsStore.save(_settings);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            _OptionRow(
              title: 'Text Size',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: KainPHFontScale.values
                    .map(
                      (scale) => ChoiceChip(
                        label: Text(_fontScaleLabel(scale)),
                        selected: _settings.fontScale == scale,
                        onSelected: (_) async {
                          setState(() => _settings = _settings.copyWith(fontScale: scale));
                          await AppearanceSettingsStore.save(_settings);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
            _OptionRow(
              title: 'Navigation Style',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: KainPHNavigationMode.values
                    .map(
                      (mode) => ChoiceChip(
                        label: Text(_navigationLabel(mode)),
                        selected: _settings.navigationMode == mode,
                        onSelected: (_) async {
                          setState(() => _settings = _settings.copyWith(navigationMode: mode));
                          await AppearanceSettingsStore.save(_settings);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionCard(
          title: 'Branding',
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: KainPHTheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (_settings.businessLogoPath != null && File(_settings.businessLogoPath!).existsSync())
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_settings.businessLogoPath!),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _settings.brandColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.storefront_outlined,
                        color: _settings.brandColor,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _settings.businessName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _settings.businessTagline,
                          style: const TextStyle(
                            color: KainPHTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Select Logo'),
                  ),
                ),
                const SizedBox(width: 8),
                if (_settings.businessLogoPath != null)
                  TextButton.icon(
                    onPressed: () async {
                      final updated = _settings.copyWith(clearBusinessLogo: true);
                      setState(() => _settings = updated);
                      await AppearanceSettingsStore.save(updated);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _businessNameController,
              decoration: const InputDecoration(labelText: 'Business Name'),
              onChanged: (_) async {
                await _applySettings();
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _businessTaglineController,
              decoration: const InputDecoration(labelText: 'Business Tagline'),
              onChanged: (_) async {
                await _applySettings();
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Brand Color'),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final updated = _settings.copyWith(brandColor: _settings.brandColor == const Color(0xFFE85D04) ? const Color(0xFF2563EB) : const Color(0xFFE85D04));
                    setState(() => _settings = updated);
                    await AppearanceSettingsStore.save(updated);
                  },
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: _settings.brandColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _applySettings,
          icon: const Icon(Icons.check_circle_outlined),
          label: const Text('Apply Changes'),
        ),
      ],
    );
  }

  String _themeLabel(KainPHThemeMode mode) {
    switch (mode) {
      case KainPHThemeMode.light:
        return 'Light';
      case KainPHThemeMode.dark:
        return 'Dark';
      case KainPHThemeMode.system:
        return 'System';
    }
  }

  String _densityLabel(KainPHDensity density) {
    switch (density) {
      case KainPHDensity.comfortable:
        return 'Comfortable';
      case KainPHDensity.standard:
        return 'Standard';
      case KainPHDensity.compact:
        return 'Compact';
    }
  }

  String _fontScaleLabel(KainPHFontScale value) {
    switch (value) {
      case KainPHFontScale.small:
        return 'Small';
      case KainPHFontScale.standard:
        return 'Standard';
      case KainPHFontScale.large:
        return 'Large';
    }
  }

  String _navigationLabel(KainPHNavigationMode mode) {
    switch (mode) {
      case KainPHNavigationMode.sidebar:
        return 'Sidebar';
      case KainPHNavigationMode.compactSidebar:
        return 'Compact Sidebar';
      case KainPHNavigationMode.bottom:
        return 'Bottom';
    }
  }

}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final String title;
  final Widget child;

  const _OptionRow({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _AppearancePreview extends StatelessWidget {
  final AppearanceSettings settings;

  const _AppearancePreview({required this.settings});

  @override
  Widget build(BuildContext context) {
    final theme = KainPHTheme.resolveTheme(settings);
    return Theme(
      data: theme,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      settings.businessName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: settings.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off, size: 12),
                        SizedBox(width: 4),
                        Text('Offline'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: settings.accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Today\'s Sales', style: TextStyle(color: KainPHTheme.textSecondary)),
                    const SizedBox(height: 6),
                    Text(
                      '₱28,450.00',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: settings.accentColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {},
                child: const Text('New Sale'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonal(
                      onPressed: () {},
                      child: const Text('View Orders'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Reports'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
