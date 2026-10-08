import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../types/display_labels.dart';
import '../../../types/memories/memory_summary.dart';
import '../../atoms/common/md_local_photo.dart';
import '../../atoms/common/md_sticker.dart';
import '../../atoms/people/md_participant_avatar_stack.dart';
import '../../molecules/common/md_poster_card.dart';
import '../../molecules/memories/md_memory_cover_hero.dart';

/// A Memory as a poster: the picture fills the card and the quest title,
/// date and who was there sit inside it on a charcoal fade. See CLAUDE.md
/// §38, design system §35.
class MdMemoryCard extends StatelessWidget {
  const MdMemoryCard({super.key, required this.summary, required this.onTap});

  final MemorySummary summary;
  final VoidCallback onTap;

  static const _aspectRatio = 4 / 5;

  /// The card's height at [width]. The text sits inside the picture, so it
  /// never depends on the person's text size.
  static double heightFor(double width) => width / _aspectRatio;

  @override
  Widget build(BuildContext context) {
    final memory = summary.memory;
    final date = DateFormat.yMMMd().format(memory.capturedAt);
    final (occasion, occasionIcon) = memoryOccasion(
      memory.title,
      summary.questCategory,
    );
    final withWhom = MdParticipantAvatarStack.describe(summary.people);

    return MdPosterCard(
      onTap: onTap,
      aspectRatio: _aspectRatio,
      radius: AppRadius.xl,
      semanticLabel: [
        memory.title,
        date,
        withWhom,
      ].where((s) => s.isNotEmpty).join(', '),
      background: MdMemoryCoverHero(
        memoryId: memory.id,
        child: MdLocalPhoto(path: summary.coverPhoto?.thumbnailPath),
      ),
      overlay: [
        // The kind of day, matching the memory (Anniversary, Birthday...).
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.sm,
          right: AppSpacing.sm,
          child: Align(
            alignment: Alignment.topLeft,
            child: MdSticker(label: occasion, icon: occasionIcon, tilt: -0.05),
          ),
        ),
        Positioned(
          left: AppSpacing.ms,
          right: AppSpacing.ms,
          bottom: AppSpacing.ms,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      memory.title,
                      style: AppTypography.label.copyWith(
                        color: AppColors.warmCream,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      date,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warmCream,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (summary.people.isNotEmpty)
                MdParticipantAvatarStack(
                  people: summary.people,
                  radius: 11,
                  max: 2,
                  ringColor: AppColors.paper,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
