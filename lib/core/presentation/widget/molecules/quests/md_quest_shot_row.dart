import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../types/display_labels.dart';
import '../../../types/quests/draft_shot.dart';
import '../../molecules/common/md_app_card.dart';

/// One shot in the list: its number, instruction and framing, a drag
/// handle, and a remove button (swiping left removes it too).
class MdQuestShotRow extends StatelessWidget {
  const MdQuestShotRow({
    super.key,
    required this.index,
    required this.shot,
    required this.reorderable,
    required this.onRemove,
  });

  final int index;
  final DraftShot shot;
  final bool reorderable;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return MdAppCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          if (reorderable)
            ReorderableDragStartListener(
              index: index,
              child: const Tooltip(
                message: 'Drag to reorder',
                child: SizedBox.square(
                  dimension: AppTouch.minTarget,
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.softPeach,
            child: Text('${index + 1}', style: AppTypography.label),
          ),
          const SizedBox(width: AppSpacing.ms),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shot.instruction, style: AppTypography.body),
                Text(
                  shotTypeLabel(shot.shotType),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove shot ${index + 1}',
            icon: const Icon(Icons.close_rounded, size: AppIconSizes.md),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
