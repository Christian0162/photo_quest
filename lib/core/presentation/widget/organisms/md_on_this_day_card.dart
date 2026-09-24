import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../types/memories/memory_summary.dart';
import '../atoms/md_local_photo.dart';
import '../molecules/md_app_card.dart';

/// "1 year ago today" — resurfaces a memory from this date so the app
/// feels like a time capsule, and nudges "do it again". See CLAUDE.md §21,
/// §68.
class MdOnThisDayCard extends StatelessWidget {
  const MdOnThisDayCard({
    super.key,
    required this.summary,
    required this.today,
    required this.onTap,
  });

  final MemorySummary summary;
  final DateTime today;
  final VoidCallback onTap;

  String get _ago {
    final years = today.year - summary.memory.capturedAt.year;
    return years == 1 ? '1 year ago today' : '$years years ago today';
  }

  @override
  Widget build(BuildContext context) {
    return MdAppCard(
      color: AppColors.filmYellow,
      elevated: false,
      padding: const EdgeInsets.all(AppSpacing.ms),
      onTap: onTap,
      semanticLabel: '$_ago: ${summary.memory.title}. Open this memory',
      child: Row(
        children: [
          // No hero here: the same memory may also be on the Recent
          // shelf, and one screen can't fly two copies.
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox.square(
              dimension: 84,
              child: MdLocalPhoto(path: summary.coverPhoto?.thumbnailPath),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded, size: AppIconSizes.sm),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        _ago.toUpperCase(),
                        style: AppTypography.overline.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  summary.memory.title,
                  style: AppTypography.heading3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                // An icon, not "→": the bundled Latin font subset has no
                // arrow glyph.
                Row(
                  children: [
                    Text('Relive it', style: AppTypography.label),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: AppIconSizes.sm,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
