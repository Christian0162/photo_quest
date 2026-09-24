import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/quests/enum/status_tone.dart';
import '../../types/quests/quest_needing_confirmation.dart';
import '../atoms/md_participant_avatar_stack.dart';
import '../atoms/md_status_pill.dart';
import '../molecules/md_app_card.dart';

/// One Quest you created that's still waiting on people to say they're in,
/// shown on Home so a group quest doesn't quietly stall. See design system
/// §13, §22, §60.
class MdPendingQuestCard extends StatelessWidget {
  const MdPendingQuestCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  final QuestNeedingConfirmation entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final waiting = entry.pendingCount == 1
        ? 'Waiting on 1 person'
        : 'Waiting on ${entry.pendingCount} people';

    return MdAppCard(
      color: AppColors.softPeach,
      elevated: false,
      onTap: onTap,
      semanticLabel: '${entry.quest.title}. $waiting',
      child: Row(
        children: [
          MdParticipantAvatarStack(
            people: entry.people,
            radius: 18,
            max: 3,
            ringColor: AppColors.softPeach,
          ),
          const SizedBox(width: AppSpacing.ms),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.quest.title,
                  style: AppTypography.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                MdStatusPill(
                  label: waiting,
                  icon: Icons.hourglass_top_rounded,
                  tone: StatusTone.waiting,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
