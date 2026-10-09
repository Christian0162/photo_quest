import 'package:flutter/material.dart';

import '../../../../../config/constant/app_typography.dart';
import '../../molecules/quests/md_quest_step_page.dart';

class MdQuestIdeaStep extends StatelessWidget {
  const MdQuestIdeaStep({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return MdQuestStepPage(
      question: "What's the idea?",
      helper:
          'Describe what you’ll do together in real life. Keep it short '
          'and fun — this part is optional.',
      children: [
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: 6,
          textCapitalization: TextCapitalization.sentences,
          style: AppTypography.bodyLarge,
          decoration: const InputDecoration(
            hintText:
                'Find an old childhood photo and recreate the pose together.',
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
