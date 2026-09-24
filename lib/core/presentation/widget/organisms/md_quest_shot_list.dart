import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/quests/entities/quest_shot.dart';
import '../../types/display_labels.dart';
import '../atoms/md_local_photo.dart';
import '../molecules/md_app_card.dart';

/// The numbered photos a Quest asks for, so everyone knows what pictures
/// they're about to take. See CLAUDE.md §33, design system §16.
class MdQuestShotList extends StatelessWidget {
  const MdQuestShotList({super.key, required this.shots});

  final List<QuestShot> shots;

  @override
  Widget build(BuildContext context) {
    return MdAppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (var i = 0; i < shots.length; i++) ...[
            if (i > 0) const Divider(indent: 68),
            _ShotRow(number: i + 1, shot: shots[i]),
          ],
        ],
      ),
    );
  }
}

class _ShotRow extends StatelessWidget {
  const _ShotRow({required this.number, required this.shot});

  final int number;
  final QuestShot shot;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.ms,
          vertical: AppSpacing.ms,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.softPeach,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: AppTypography.heading3,
                semanticsLabel: 'Shot $number',
              ),
            ),
            const SizedBox(width: AppSpacing.ms),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shot.instruction, style: AppTypography.body),
                  const SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Icon(
                        shotTypeIcon(shot.shotType),
                        size: AppIconSizes.sm,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        shotTypeLabel(shot.shotType),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (shot.exampleImagePath != null) ...[
              const SizedBox(width: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  width: 48,
                  height: 64,
                  child: MdLocalPhoto(
                    path: shot.exampleImagePath,
                    semanticLabel: 'Example photo',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
