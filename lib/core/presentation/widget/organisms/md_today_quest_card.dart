import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../types/display_labels.dart';
import '../atoms/md_primary_button.dart';
import '../molecules/md_app_card.dart';
import 'md_quest_card.dart';

/// Home's hero: one inviting Quest for today with a prominent example image
/// and a single "Start" action. See CLAUDE.md §31, design system §14.
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
    return MdAppCard(
      padding: const EdgeInsets.all(AppSpacing.ms),
      radius: AppRadius.photo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: MdQuestHeroCover(quest: quest),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("TODAY'S QUEST", style: AppTypography.overline),
                const SizedBox(height: AppSpacing.xs),
                Text(quest.title, style: AppTypography.heading1),
                if (quest.description != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    quest.description!,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: AppSpacing.ms),
                Row(
                  children: [
                    Icon(
                      questTypeIcon(quest.type),
                      size: AppIconSizes.sm,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      questTypeLabel(quest.type),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
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
      ),
    );
  }
}
