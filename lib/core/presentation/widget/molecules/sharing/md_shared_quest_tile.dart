import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/sharing/entities/shared_quest.dart';
import '../common/md_app_card.dart';

/// A quest a friend invited me to, or that I've joined. An invitation is
/// marked with a word (not only a color) so it stands out.
class MdSharedQuestTile extends StatelessWidget {
  const MdSharedQuestTile({
    super.key,
    required this.quest,
    required this.onTap,
  });

  final SharedQuestSummary quest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final invited = quest.status == ParticipationStatus.invited;
    final subtitle = invited
        ? '${quest.ownerName} invited you'
        : 'With ${quest.ownerName}';

    return MdAppCard(
      onTap: onTap,
      color: invited ? AppColors.softPeach : AppColors.paper,
      elevated: !invited,
      semanticLabel: '${quest.title}. $subtitle.',
      child: Row(
        children: [
          Icon(
            invited
                ? Icons.mark_email_unread_outlined
                : Icons.auto_awesome_outlined,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quest.title,
                  style: AppTypography.heading3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: AppTypography.body),
              ],
            ),
          ),
          if (invited)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Text('Reply', style: AppTypography.label),
            ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
