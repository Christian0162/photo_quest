import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../types/settings/backup_state.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/common/md_app_card.dart';

/// Settings: the backup switch, how much online storage is used, and "Back up
/// now". Honest about what it does: it saves a smaller copy of each memory
/// online, on Wi-Fi; the originals stay on the phone.
class MdBackupCard extends StatelessWidget {
  const MdBackupCard({
    super.key,
    required this.backup,
    required this.onToggled,
    required this.onBackUpNow,
  });

  final BackupState backup;
  final ValueChanged<bool> onToggled;
  final VoidCallback onBackUpNow;

  @override
  Widget build(BuildContext context) {
    final usage = backup.usage;

    return MdAppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: backup.enabled,
            onChanged: onToggled,
            title: Text('Back up my memories', style: AppTypography.heading3),
            subtitle: const Padding(
              padding: EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'Save a smaller copy of each new memory online when you are '
                'on Wi-Fi. Your originals stay on this phone.',
              ),
            ),
          ),
          if (usage != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              label: 'Online storage: ${usage.label}',
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: usage.fraction,
                      minHeight: AppSpacing.sm,
                      color: usage.isFull
                          ? AppColors.error
                          : AppColors.warmCoral,
                      backgroundColor: AppColors.sunken,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(usage.label, style: AppTypography.caption),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          MdSecondaryButton(
            label: backup.running
                ? (backup.total == 0
                      ? 'Getting ready…'
                      : 'Backing up ${backup.done} of ${backup.total}…')
                : 'Back up now',
            icon: Icons.cloud_upload_outlined,
            onPressed: backup.running ? null : onBackUpNow,
          ),
          if (backup.message != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              liveRegion: true,
              child: Text(
                backup.message!,
                style: AppTypography.body.copyWith(
                  color: backup.isError
                      ? AppColors.error
                      : AppColors.successInk,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
