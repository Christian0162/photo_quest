import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/quests/entities/quest.dart';
import '../../../types/display_labels.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/common/md_sticker.dart';
import '../../molecules/common/md_poster_card.dart';
import 'md_quest_card.dart';

/// Home's hero: today's Quest as a full-bleed poster. The example photo
/// fills the card, the title sits on a charcoal fade at the bottom, and one
/// chunky button starts it. Tilted stickers pop on top so it feels like a
/// thing you could pick up. See CLAUDE.md §31, design system §14.
class MdTodayQuestCard extends StatelessWidget {
  const MdTodayQuestCard({
    super.key,
    required this.quest,
    required this.onStart,
  });

  final Quest quest;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return MdPosterCard(
      aspectRatio: 4 / 5.2,
      background: MdQuestHeroCover(quest: quest),
      overlay: [
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          child: MdSticker(
            label: "Today's quest",
            icon: Icons.bolt_rounded,
            color: AppColors.warmCoral,
            tilt: -0.06,
            delay: const Duration(milliseconds: 450),
          ),
        ),
        Positioned(
          top: AppSpacing.md,
          right: AppSpacing.md,
          child: MdSticker(
            label: questTypeLabel(quest.type),
            icon: questTypeIcon(quest.type),
            color: AppColors.paper,
            tilt: 0.05,
            delay: const Duration(milliseconds: 600),
          ),
        ),
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  quest.title,
                  style: AppTypography.display.copyWith(
                    color: AppColors.warmCream,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (quest.description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  quest.description!,
                  style: AppTypography.body.copyWith(
                    color: AppColors.warmCream,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              MdPrimaryButton(
                label: "Let's do it",
                icon: Icons.photo_camera_rounded,
                onPressed: onStart,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
