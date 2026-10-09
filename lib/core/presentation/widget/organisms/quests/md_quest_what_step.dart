import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../utils/app_haptics.dart';
import '../../../types/display_labels.dart';
import '../../../types/quests/create_quest_draft.dart';
import '../../molecules/quests/md_quest_step_page.dart';

const _categorySuggestions = [
  'Birthday',
  'Family',
  'Friends',
  'Date',
  'Adventure',
  'Funny',
  'Memory',
];

class MdQuestWhatStep extends StatelessWidget {
  const MdQuestWhatStep({
    super.key,
    required this.controller,
    required this.draft,
    required this.onTitleChanged,
    required this.onCategoryChanged,
  });

  final TextEditingController controller;
  final CreateQuestDraft draft;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return MdQuestStepPage(
      question: 'What should we do?',
      helper: 'Give it a name you’ll smile at next year.',
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          style: AppTypography.bodyLarge,
          decoration: const InputDecoration(
            hintText: 'Recreate our childhood photo',
          ),
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text("What kind of moment is it?", style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final suggestion in _categorySuggestions)
              ChoiceChip(
                avatar: Icon(
                  questCategoryIcon(suggestion),
                  size: AppIconSizes.sm,
                ),
                label: Text(suggestion),
                showCheckmark: false,
                selected: draft.category == suggestion,
                onSelected: (_) {
                  AppHaptics.selection();
                  onCategoryChanged(suggestion);
                },
              ),
          ],
        ),
      ],
    );
  }
}
