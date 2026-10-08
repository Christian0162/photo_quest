import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/people/enum/mood.dart';
import '../../../utils/app_haptics.dart';
import '../../types/mood_icon.dart';

/// "Feeling happy" with a small chevron: how you feel right now, one tap to
/// change it. Always an icon plus words, never color alone. See CLAUDE.md
/// §65.
class MdMoodPill extends StatelessWidget {
  const MdMoodPill({super.key, required this.mood, required this.onTap});

  final Mood? mood;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mood = this.mood;
    final label = mood == null
        ? 'How are you feeling?'
        : 'Feeling ${mood.label.toLowerCase()}';

    return Semantics(
      button: true,
      label: '$label. Change how you feel.',
      excludeSemantics: true,
      child: Material(
        color: AppColors.softPeach,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () {
            AppHaptics.selection();
            onTap();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.ms,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    mood?.icon ?? Icons.add_reaction_outlined,
                    size: AppIconSizes.sm + 2,
                    color: mood == null
                        ? AppColors.textPrimary
                        : AppColors.coralInk,
                  ),
                  const SizedBox(width: AppSpacing.xs + 2),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: AppIconSizes.sm + 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
