import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/constant/app_constants.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/people/entities/person.dart';
import '../../../../utils/app_haptics.dart';
import '../../../types/display_labels.dart';
import '../../../types/quests/create_quest_draft.dart';
import '../../atoms/people/md_person_avatar.dart';
import '../../atoms/common/md_skeleton_box.dart';
import '../../molecules/quests/md_choice_card.dart';
import '../../molecules/quests/md_quest_step_page.dart';

class MdQuestWhoStep extends StatelessWidget {
  const MdQuestWhoStep({
    super.key,
    required this.draft,
    required this.people,
    required this.onTypeChanged,
    required this.onToggleParticipant,
  });

  final CreateQuestDraft draft;
  final AsyncValue<List<Person>> people;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onToggleParticipant;

  @override
  Widget build(BuildContext context) {
    const limit = AppConstants.defaultGroupQuestParticipantLimit;
    final full = draft.participantIds.length >= limit;

    return MdQuestStepPage(
      question: 'Who should join?',
      children: [
        Row(
          children: [
            for (final (value, label, icon) in questTypes) ...[
              Expanded(
                child: MdChoiceCard(
                  label: label,
                  icon: icon,
                  selected: draft.type == value,
                  onTap: () {
                    AppHaptics.selection();
                    onTypeChanged(value);
                  },
                ),
              ),
              if (value != questTypes.last.$1)
                const SizedBox(width: AppSpacing.sm),
            ],
          ],
        ),
        if (draft.type != 'solo') ...[
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text('Invite your people', style: AppTypography.label),
              ),
              Text(
                '${draft.participantIds.length} of $limit',
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Optional — you can invite people from the quest later, too.',
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.ms),
          people.when(
            loading: () => const MdSkeletonBox(height: 48),
            error: (error, stack) => const SizedBox.shrink(),
            data: (others) {
              if (others.isEmpty) {
                return Text(
                  'Add people in the People tab to invite them here.',
                  style: AppTypography.bodyMuted,
                );
              }
              return Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final person in others)
                    Builder(
                      builder: (context) {
                        final selected = draft.participantIds.contains(
                          person.id,
                        );
                        return FilterChip(
                          avatar: selected
                              ? null
                              : MdPersonAvatar(person: person, radius: 12),
                          label: Text(person.name),
                          selected: selected,
                          onSelected: selected || !full
                              ? (_) {
                                  AppHaptics.selection();
                                  onToggleParticipant(person.id);
                                }
                              : null,
                        );
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
