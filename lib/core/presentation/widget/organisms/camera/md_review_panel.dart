import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_shadows.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/memories/entities/photo.dart';
import '../../../types/camera/capture_state.dart';
import '../../atoms/common/md_local_photo.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/camera/md_print_pop_in.dart';
import '../../molecules/camera/md_shot_media.dart';

/// Keep / Retake for the photo just taken. Keep is primary; Retake stays
/// one tap away. See CLAUDE.md §35, design system §30.
class MdReviewPanel extends StatelessWidget {
  const MdReviewPanel({
    super.key,
    required this.state,
    required this.onKeep,
    required this.onRetake,
  });

  final CaptureState state;
  final VoidCallback onKeep;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final photo = state.lastPhoto;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (photo != null)
          MdPrintPopIn(
            child: Container(
              height: MediaQuery.sizeOf(context).height * 0.34,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.paper,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.print,
              ),
              child: AspectRatio(
                aspectRatio: photo.width > 0 && photo.height > 0
                    ? photo.width / photo.height
                    : 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: photo.kind == PhotoKind.photo
                      ? MdLocalPhoto(
                          path: photo.thumbnailPath,
                          semanticLabel: 'The photo you just took',
                        )
                      : MdShotMedia(
                          photo: photo,
                          semanticLabel: 'What you just captured',
                        ),
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          liveRegion: true,
          child: Text(
            state.isLastShot ? "Nice one — that's the last shot!" : 'Nice one!',
            style: AppTypography.heading2.copyWith(color: AppColors.onCamera),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        MdPrimaryButton(
          label: state.isLastShot ? 'Keep it & finish' : 'Keep it',
          icon: Icons.check_rounded,
          onPressed: onKeep,
        ),
        const SizedBox(height: AppSpacing.sm),
        MdSecondaryButton(
          label: 'Retake',
          icon: Icons.replay_rounded,
          onDark: true,
          onPressed: onRetake,
        ),
      ],
    );
  }
}
