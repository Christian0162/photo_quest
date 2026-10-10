import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_constants.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../atoms/common/md_primary_button.dart';

class MdInviteCodeCard extends StatelessWidget {
  const MdInviteCodeCard({
    super.key,
    required this.code,
    required this.onCopy,
    required this.onSend,
    this.caption,
  });

  final String? caption;

  final String code;
  final VoidCallback onCopy;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.softPeach,
        borderRadius: BorderRadius.circular(AppRadius.base),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Semantics(
              label: 'Invite code: ${code.split('').join(' ')}',
              excludeSemantics: true,
              child: SelectableText(
                code,
                textAlign: TextAlign.center,
                style: AppTypography.display.copyWith(
                  letterSpacing: AppSpacing.xs,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              caption ??
                  'Works for ${AppConstants.inviteValidDays} days, for up to '
                      '${AppConstants.inviteMaxUses} friends.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: MdSecondaryButton(
                    label: 'Copy',
                    icon: Icons.copy_rounded,
                    onPressed: onCopy,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MdPrimaryButton(
                    label: 'Send',
                    icon: Icons.ios_share_rounded,
                    onPressed: onSend,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
