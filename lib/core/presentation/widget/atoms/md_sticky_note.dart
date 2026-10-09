import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';

/// A memory's note, clipped to its photo like a sticky note left on a
/// photobooth print — a little square of paper, handwritten and tilted,
/// held on with a paperclip. Used wherever a memory's [text] should feel
/// written, not printed. See CLAUDE.md §2.5, §36, design system §33-35.
class MdStickyNote extends StatelessWidget {
  const MdStickyNote({super.key, required this.text, this.width = 156});

  final String text;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      // A few degrees, like it was pressed on by hand, not laid square.
      angle: 0.08,
      alignment: Alignment.topRight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: width,
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.ms,
              AppSpacing.lg,
              AppSpacing.ms,
              AppSpacing.ms,
            ),
            decoration: BoxDecoration(
              color: AppColors.filmYellow,
              borderRadius: BorderRadius.circular(AppSpacing.xxs),
              boxShadow: AppShadows.print,
            ),
            // No line limit: a note is never cut off mid-sentence.
            child: Text(
              text,
              style: AppTypography.script.copyWith(
                fontSize: 16,
                height: 1.25,
                color: AppColors.inkBrown,
              ),
            ),
          ),
          // A paperclip, holding the note to the photo underneath it.
          Positioned(
            top: -AppSpacing.xs,
            left: AppSpacing.lg,
            child: Transform.rotate(
              angle: -0.55,
              child: Icon(
                Icons.attach_file_rounded,
                size: AppIconSizes.xl,
                color: AppColors.textMuted,
                shadows: const [Shadow(color: AppColors.shadow, blurRadius: 3)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
