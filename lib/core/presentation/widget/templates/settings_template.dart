import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../molecules/md_app_card.dart';
import '../organisms/md_app_scaffold.dart';

/// Quiet, short settings: mostly reassurance that memories are private and
/// stay on this device. See CLAUDE.md §56.
class SettingsTemplate extends StatelessWidget {
  const SettingsTemplate({super.key, required this.onOpenLicenses});

  final VoidCallback onOpenLicenses;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      showAppBar: true,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.xxl,
        ),
        children: [
          Semantics(
            header: true,
            child: Text('Settings', style: AppTypography.heading1),
          ),
          const SizedBox(height: AppSpacing.lg),
          MdAppCard(
            color: AppColors.softPeach,
            elevated: false,
            padding: const EdgeInsets.all(AppSpacing.ml),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_rounded),
                const SizedBox(width: AppSpacing.ms),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Private by design', style: AppTypography.heading3),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Your photos and memories live only on this phone. '
                        'Nothing is uploaded anywhere — you decide what to '
                        'share.',
                        style: AppTypography.body,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          MdAppCard(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Open-source licenses'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: onOpenLicenses,
            ),
          ),
        ],
      ),
    );
  }
}
