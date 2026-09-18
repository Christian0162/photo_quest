import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../view_model/quests/quests_needing_confirmation_view_model.dart';
import '../atoms/participant_avatar_stack.dart';
import '../molecules/app_card.dart';

/// One Quest you created that's still waiting on confirmations, shown in
/// Home's "Needs everyone's OK" section. See design system §13, §60.
class PendingQuestCard extends StatelessWidget {
  const PendingQuestCard({super.key, required this.entry, required this.onTap});

  final QuestNeedingConfirmation entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.softPeach,
      onTap: onTap,
      child: Row(
        children: [
          ParticipantAvatarStack(people: entry.people, radius: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.quest.title,
                  style: AppTypography.body,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  entry.pendingCount == 1
                      ? 'Waiting on 1 person'
                      : 'Waiting on ${entry.pendingCount} people',
                  style: AppTypography.bodyMuted,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.warmCharcoal,
          ),
        ],
      ),
    );
  }
}
