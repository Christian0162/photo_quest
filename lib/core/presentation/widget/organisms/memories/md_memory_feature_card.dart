import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_shadows.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../utils/date_labels.dart';
import '../../../types/display_labels.dart';
import '../../../types/memories/memory_summary.dart';
import '../../atoms/common/md_sticker.dart';
import '../../atoms/memories/md_open_memory_link.dart';
import '../../atoms/memories/md_sticky_note.dart';
import '../../atoms/people/md_participant_avatar_stack.dart';
import '../../molecules/memories/md_memory_cover_hero.dart';
import '../../molecules/memories/md_photo_fan.dart';

class MdMemoryFeatureCard extends StatelessWidget {
  const MdMemoryFeatureCard({
    super.key,
    required this.summary,
    required this.now,
    required this.onOpen,
    required this.onViewPhoto,
  });

  final MemorySummary summary;

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
    final moment = memoryMoment(memory.capturedAt);

    final card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.base),
        boxShadow: AppShadows.print,
      ),
      child: Material(
        color: AppColors.printWell,
        borderRadius: BorderRadius.circular(AppRadius.base),
        clipBehavior: Clip.antiAlias,
        child: Semantics(
          button: true,
          label: [
            memory.title,
            moment,
            withWhom,
          ].where((s) => s.isNotEmpty).join('. '),
          child: InkWell(
            onTap: onOpen,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.ml,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // A Wrap, so a long "11 months ago" drops below the sticker
                  // instead of squeezing it.
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      MdSticker(
                        label: occasion,
                        icon: occasionIcon,
                        tilt: -0.04,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.history_rounded,
                            size: AppIconSizes.sm,
                            color: AppColors.warmCream,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            relativeDay(memory.capturedAt, now),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.warmCream,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // The prints lie in the tray, like fresh from the booth,
                  // with the memory's note clipped on like a sticky note.
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MdPhotoFan(
                            // Thumbnails keep a long list light; the viewer
                            // opens the full-size shots.
                            paths: [
                              for (final photo in photos) photo.thumbnailPath,
                            ],
                            onOpen: onViewPhoto,
                            front: (print) => MdMemoryCoverHero(
                              memoryId: memory.id,
                              child: print,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _TrayLabel(
                            label: photos.length == 1
                                ? '1 shot'
                                : '${photos.length} shots',
                          ),
                        ],
                      ),
                      Positioned(
                        top: -AppSpacing.md,
                        right: 0,
                        child: MdStickyNote(text: summary.description),
                      ),
                    ],
                  ),
                  if (withWhom.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      withWhom,
                      style: AppTypography.script.copyWith(
                        fontSize: 20,
                        color: AppColors.filmYellow,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    memory.title,
                    style: AppTypography.heading1.copyWith(
                      color: AppColors.warmCream,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    moment,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.warmCream,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.ms),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: MdOpenMemoryLink(onDark: true),
                  ),
                ],
              ),
            ),
          ),
        ),
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
