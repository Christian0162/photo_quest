import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../utils/date_labels.dart';
import '../../../types/display_labels.dart';
import '../../../types/memories/memory_summary.dart';
import '../../atoms/common/md_local_photo.dart';
import '../../atoms/common/md_sticker.dart';
import '../../atoms/memories/md_open_memory_link.dart';
import '../../molecules/common/md_poster_card.dart';
import '../../molecules/memories/md_memory_cover_hero.dart';

/// A memory as a poster: the cover photo fills the card, with the kind of
/// day as a sticker, the title and its note, and a button to see the shots
/// full screen, all inside the picture. Tap anywhere else to open the
/// memory.
class MdMemoryJournalCard extends StatefulWidget {
  const MdMemoryJournalCard({
    super.key,
    required this.summary,
    required this.onOpen,
    required this.onViewPhoto,
  });

  final MemorySummary summary;
  final VoidCallback onOpen;
  final ValueChanged<int> onViewPhoto;

  @override
  State<MdMemoryJournalCard> createState() => _MdMemoryJournalCardState();
}

class _MdMemoryJournalCardState extends State<MdMemoryJournalCard> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;
    final onOpen = widget.onOpen;
    final memory = summary.memory;
    final (occasion, occasionIcon) = memoryOccasion(
      memory.title,
      summary.questCategory,
    );
    final shots = summary.photos.isEmpty
        ? (summary.coverPhoto == null ? 0 : 1)
        : summary.photos.length;
    final people = summary.people.length;
    final facts = [
      shots == 1 ? '1 shot' : '$shots shots',
      if (people > 0) people == 1 ? '1 person' : '$people people',
    ].join(' · ');
    final moment = memoryMoment(memory.capturedAt);

    return MdPosterCard(
      onTap: onOpen,
      aspectRatio: 4 / 4.4,
      radius: AppRadius.xl,
      background: _SwipeablePhotos(
        summary: summary,
        onPageChanged: (page) => setState(() => _page = page),
      ),
      overlay: [
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          right: AppSpacing.md,
          child: Align(
            alignment: Alignment.topLeft,
            child: MdSticker(label: occasion, icon: occasionIcon, tilt: -0.04),
          ),
        ),
        if (shots > 1)
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: _PageDots(count: shots, current: _page),
          ),
        Positioned(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                moment,
                style: AppTypography.overline.copyWith(
                  color: AppColors.filmYellow,
                  letterSpacing: 0.8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                memory.title,
                style: AppTypography.heading2.copyWith(
                  color: AppColors.warmCream,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                summary.description,
                style: AppTypography.body.copyWith(color: AppColors.warmCream),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.ms),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (shots > 0)
                    _ViewShotsButton(
                      label: facts,
                      description: summary.description,
                      onTap: () => widget.onViewPhoto(_page),
                    )
                  else
                    Text(
                      facts,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warmCream,
                      ),
                    ),
                  const MdOpenMemoryLink(onDark: true),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A frosted pill that opens the shots full screen, separate from the card's
/// own tap.
class _ViewShotsButton extends StatelessWidget {
  const _ViewShotsButton({
    required this.label,
    required this.description,
    required this.onTap,
  });

  final String label;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      label: 'View the photos. $description',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.onCamera.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.ms,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    size: AppIconSizes.sm,
                    color: AppColors.onCamera,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onCamera,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The memory's photos as pages you swipe through; the first one flies into
/// the memory when opened. A memory with one photo is just that photo.
class _SwipeablePhotos extends StatelessWidget {
  const _SwipeablePhotos({required this.summary, required this.onPageChanged});

  final MemorySummary summary;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final photos = summary.photos;
    Widget cover() => MdMemoryCoverHero(
      memoryId: summary.memory.id,
      child: MdLocalPhoto(path: summary.coverPhoto?.thumbnailPath),
    );
    if (photos.length < 2) return cover();

    return PageView.builder(
      itemCount: photos.length,
      onPageChanged: onPageChanged,
      itemBuilder: (_, index) => index == 0
          ? cover()
          : MdLocalPhoto(path: photos[index].thumbnailPath),
    );
  }
}

/// Little dots showing which photo is in view; the current one is longer.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.warmCharcoal.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < count; i++)
                AnimatedContainer(
                  duration: AppMotion.of(context, AppMotion.short),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: i == current ? 14 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == current
                        ? AppColors.onCamera
                        : AppColors.onCamera.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
