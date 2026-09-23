import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../types/display_labels.dart';
import '../atoms/local_photo.dart';
import '../atoms/primary_button.dart';
import '../molecules/app_card.dart';
import 'quest_card.dart';

/// Home's hero: one inviting Quest for today with a prominent example image
/// and a single "Start" action. See CLAUDE.md §31, design system §14.
class TodayQuestCard extends StatelessWidget {
  const TodayQuestCard({super.key, required this.quest, required this.onStart});

  final Quest quest;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.ms),
      radius: AppRadius.photo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: quest.coverImagePath != null
                  ? LocalPhoto(path: quest.coverImagePath)
                  : QuestCoverArt(category: quest.category),
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
                PrimaryButton(
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
