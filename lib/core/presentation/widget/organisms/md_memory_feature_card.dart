import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../utils/date_labels.dart';
import '../../types/display_labels.dart';
import '../../types/memories/memory_summary.dart';
import '../atoms/md_occasion_chip.dart';
import '../atoms/md_open_memory_link.dart';
import '../atoms/md_participant_avatar_stack.dart';
import '../molecules/md_app_card.dart';
import '../molecules/md_memory_cover_hero.dart';
import '../molecules/md_photo_fan.dart';

/// The first memory of a month, shown like a page taped into a journal:
/// when it was, the prints fanned out in a dark booth tray, who was there,
/// the title, a few words, and its tags. Tap a print to see it full screen;
/// tap anywhere else to open the memory. See CLAUDE.md §36-38, design
/// system §33-35.
///
/// ```text
///            ▭ tape
/// ┌──────────────────────────────┐
/// │ SATURDAY, OCT 14 · 8:42 PM   ⟲ 2 weeks ago │
/// │ ┌──────────────────────────┐ │
/// │ │     ╱▭╲ ┌──┐ ╱▭╲         │ │
/// │ │ ▣ 3 shots                │ │
/// │ └──────────────────────────┘ │
/// │ With Jamie                   │
/// │ Our Anniversary ♥            │
/// │ Back at the little café…     │
/// │ (♥ Anniversary) (For Us)     │
/// │                Open memory › │
/// └──────────────────────────────┘
/// ```
class MdMemoryFeatureCard extends StatelessWidget {
  const MdMemoryFeatureCard({
    super.key,
    required this.summary,
    required this.now,
    required this.onOpen,
    required this.onViewPhoto,
  });

  final MemorySummary summary;

  /// Today, for "2 weeks ago".
  final DateTime now;
  final VoidCallback onOpen;
  final ValueChanged<int> onViewPhoto;

  @override
  Widget build(BuildContext context) {
    final memory = summary.memory;
    final (occasion, occasionIcon) = memoryOccasion(
      memory.title,
      summary.questCategory,
    );
    final photos = summary.photos.isEmpty
        ? [?summary.coverPhoto]
        : summary.photos;
    final withWhom = MdParticipantAvatarStack.describe(summary.people);
    final category = summary.questCategory;

    final card = MdAppCard(
      onTap: onOpen,
      radius: AppRadius.xl,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.ml,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _MomentChip(label: memoryMoment(memory.capturedAt)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.history_rounded,
                size: AppIconSizes.sm,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                relativeDay(memory.capturedAt, now),
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.ms),
          // The prints lie in a dark tray, like fresh from the booth.
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.printWell,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.ms,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MdPhotoFan(
                    // Thumbnails keep a long list light; the viewer opens
                    // the full-size shots.
                    paths: [for (final photo in photos) photo.thumbnailPath],
                    onOpen: onViewPhoto,
                    front: (print) =>
                        MdMemoryCoverHero(memoryId: memory.id, child: print),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TrayLabel(
                    label: photos.length == 1
                        ? '1 shot'
                        : '${photos.length} shots',
                  ),
                ],
              ),
            ),
          ),
          if (withWhom.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              withWhom,
              style: AppTypography.script.copyWith(fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  memory.title,
                  style: AppTypography.heading1,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Icon(
                  occasionIcon,
                  size: AppIconSizes.lg,
                  color: AppColors.coralInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            summary.description,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textMuted),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              MdOccasionChip(label: occasion, icon: occasionIcon),
              if (category != null)
                MdOccasionChip(
                  label: category,
                  icon: questCategoryIcon(category),
                  color: AppColors.sunken,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.ms),
          const Align(
            alignment: Alignment.centerRight,
            child: MdOpenMemoryLink(),
          ),
        ],
      ),
    );

    // A strip of washi tape holds the page in, overlapping the top edge.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.ms),
          child: card,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Transform.rotate(
              angle: -0.04,
              child: Container(
                width: 84,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.tape,
                  borderRadius: BorderRadius.circular(AppSpacing.xxs),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "SATURDAY, OCT 14 · 8:42 PM" on a soft pill.
class _MomentChip extends StatelessWidget {
  const _MomentChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.ms,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.sunken,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(letterSpacing: 0.6),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// A small label in the corner of the dark print tray.
class _TrayLabel extends StatelessWidget {
  const _TrayLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.onCamera.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_camera_rounded,
            size: AppIconSizes.sm,
            color: AppColors.onCamera,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.onCamera),
          ),
        ],
      ),
    );
  }
}
