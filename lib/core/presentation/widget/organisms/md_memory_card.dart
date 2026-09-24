import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../types/memories/memory_summary.dart';
import '../atoms/md_local_photo.dart';
import '../atoms/md_participant_avatar_stack.dart';
import '../molecules/md_app_card.dart';
import '../molecules/md_memory_cover_hero.dart';

/// A Memory as a printed photo: the picture dominates, with a white print
/// border, the quest title, date, and who was there underneath. See
/// CLAUDE.md §38, design system §35.
class MdMemoryCard extends StatelessWidget {
  const MdMemoryCard({super.key, required this.summary, required this.onTap});

  final MemorySummary summary;
  final VoidCallback onTap;

  /// The card's natural height at [width], including title/date lines that
  /// grow with the person's text size. Lets grids and shelves size rows
  /// without clipping.
  static double heightFor(double width, TextScaler textScaler) {
    const inset = AppSpacing.sm;
    final photoHeight = (width - inset * 2) * 5 / 4;
    return photoHeight + inset * 2 + AppSpacing.ms + textScaler.scale(36);
  }

  @override
  Widget build(BuildContext context) {
    final memory = summary.memory;
    final date = DateFormat.yMMMd().format(memory.capturedAt);
    final withWhom = MdParticipantAvatarStack.describe(summary.people);

    return MdAppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      semanticLabel: [
        memory.title,
        date,
        withWhom,
      ].where((s) => s.isNotEmpty).join(', '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          MdMemoryCoverHero(
            memoryId: memory.id,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: MdLocalPhoto(path: summary.coverPhoto?.thumbnailPath),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xs,
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory.title,
                        style: AppTypography.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // One line, so the card never outgrows [heightFor].
                      Text(
                        date,
                        style: AppTypography.caption,
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
      ),
    );
  }
}
