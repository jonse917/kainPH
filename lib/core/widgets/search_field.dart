import 'package:flutter/material.dart';

import '../theme/kainph_theme.dart';

class KainPHSearchField extends StatelessWidget {
  const KainPHSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.all(Radius.circular(999));
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, size: 20),
        border: const OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: KainPHTheme.sand)),
        enabledBorder: const OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: KainPHTheme.sand)),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
