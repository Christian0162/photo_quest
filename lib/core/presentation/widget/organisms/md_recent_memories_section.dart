import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../types/memories/memory_summary.dart';
import '../atoms/md_skeleton_box.dart';
import '../molecules/md_app_card.dart';
import 'md_memory_card.dart';

/// Horizontal shelf of recent memories on Home, or a gentle nudge when
/// there are none yet. See CLAUDE.md §31, §44.
class MdRecentMemoriesSection extends StatelessWidget {
  const MdRecentMemoriesSection({
    super.key,
    required this.memories,
    required this.onOpen,
  });

  final List<MemorySummary> memories;
  final ValueChanged<MemorySummary> onOpen;

  static const _cardWidth = 168.0;

  static double _shelfHeight(BuildContext context) =>
      MdMemoryCard.heightFor(_cardWidth, MediaQuery.textScalerOf(context));

  /// Placeholder shelf with the same footprint, so nothing jumps on load.
  static Widget skeleton(BuildContext context) {
    return SizedBox(
      height: _shelfHeight(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.ms),
        itemBuilder: (_, _) => const MdSkeletonBox(width: _cardWidth),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        child: MdAppCard(
          color: AppColors.sunken,
          elevated: false,
          child: Row(
            children: [
              const Icon(Icons.photo_album_outlined),
              const SizedBox(width: AppSpacing.ms),
              Expanded(
                child: Text(
                  'Your memories will live here. Ready to make the first one?',
                  style: AppTypography.bodyMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: _shelfHeight(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        clipBehavior: Clip.none,
        itemCount: memories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.ms),
        itemBuilder: (context, index) => SizedBox(
          width: _cardWidth,
          child: MdMemoryCard(
            summary: memories[index],
            onTap: () => onOpen(memories[index]),
          ),
        ),
      ),
    );
  }
}
