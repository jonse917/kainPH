import 'package:flutter/material.dart';

import '../../core/theme/kainph_catalog.dart';
import '../../core/theme/kainph_theme.dart';
import '../../core/widgets/app_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _continue();
  }

  Future<void> _continue() async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const KainPHAppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KainPHTheme.coffee,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(KainPHCatalog.background),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
        child: const SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 28),
              child: _RunningStatus(),
            ),
          ),
        ),
      ),
    );
  }
}

class _RunningStatus extends StatelessWidget {
  const _RunningStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 10, color: KainPHTheme.success),
          SizedBox(width: 8),
          Text(
            'Running',
            style: TextStyle(
              color: Color(0xFFB7E4C7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
