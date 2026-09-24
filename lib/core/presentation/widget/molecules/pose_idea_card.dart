import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';

/// "Need an idea?" answered: one short, playful pose over the camera, with
/// another idea one tap away. Read out when it changes. See CLAUDE.md §2.4,
/// design system §27.
class PoseIdeaCard extends StatelessWidget {
  const PoseIdeaCard({
    super.key,
    required this.idea,
    required this.onAnother,
    required this.onClose,
  });

  final String idea;
  final VoidCallback onAnother;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.cameraScrim,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.filmYellow, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tips_and_updates_rounded,
                size: AppIconSizes.sm,
                color: AppColors.filmYellow,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'TRY THIS',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.filmYellow,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Hide idea',
                onPressed: onClose,
                icon: const Icon(
                  Icons.close_rounded,
                  size: AppIconSizes.md,
                  color: AppColors.onCameraMuted,
                ),
              ),
            ],
          ),
          Semantics(
            liveRegion: true,
            child: Text(
              idea,
              style: AppTypography.heading3.copyWith(color: AppColors.onCamera),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onAnother,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.onCamera,
                minimumSize: const Size(0, AppTouch.minTarget),
              ),
              icon: const Icon(Icons.shuffle_rounded, size: AppIconSizes.md),
              label: const Text('Another idea'),
            ),
          ),
        ],
      ),
    );
  }
}
