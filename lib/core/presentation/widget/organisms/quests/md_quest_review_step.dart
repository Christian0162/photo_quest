import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/people/entities/person.dart';
import '../../../../domain/quests/entities/quest_shot.dart';
import '../../../types/display_labels.dart';
import '../../../types/quests/create_quest_draft.dart';
import '../../molecules/common/md_app_card.dart';
import '../../organisms/quests/md_quest_card.dart';
import '../../organisms/quests/md_quest_shot_list.dart';
import '../../molecules/quests/md_quest_step_page.dart';

class MdQuestReviewStep extends StatelessWidget {
  const MdQuestReviewStep({
    super.key,
    required this.draft,
    required this.people,
  });

  final CreateQuestDraft draft;
  final List<Person> people;

  @override
  Widget build(BuildContext context) {
    final invited = people
        .where((p) => draft.participantIds.contains(p.id))
        .toList();

    return MdQuestStepPage(
      question: 'Looking good?',
      helper: 'You can start it right away once it’s created.',
      children: [
        MdAppCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 7,
                child: MdQuestCoverArt(category: draft.category),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.category.toUpperCase(),
                      style: AppTypography.overline,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(draft.title, style: AppTypography.heading2),
                    if (draft.description.trim().isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(draft.description, style: AppTypography.bodyMuted),
                    ],
                    const SizedBox(height: AppSpacing.ms),
                    Row(
                      children: [
                        Icon(
                          questTypeIcon(draft.type),
                          size: AppIconSizes.sm,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            invited.isEmpty
                                ? questTypeLabel(draft.type)
                                : 'With ${invited.map((p) => p.name).join(', ')}',
                            style: AppTypography.caption,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('The photos', style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        MdQuestShotList(
          shots: [
            for (var i = 0; i < draft.shots.length; i++)
              QuestShot(
                id: '$i',
                questId: '',
                position: i,
                instruction: draft.shots[i].instruction,
                shotType: draft.shots[i].shotType,
              ),
          ],
        ),
      ],
    );
  }
}
