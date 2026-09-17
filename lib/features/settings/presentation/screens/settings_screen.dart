import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Text(
          'Your memories live only on this device. Nothing is uploaded '
          'anywhere.',
          style: AppTypography.bodyMuted,
        ),
      ),
    );
  }
}
