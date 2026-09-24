import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../utils/date_labels.dart';
import '../../types/display_labels.dart';
import '../../types/memories/memory_summary.dart';
import '../atoms/md_icon_fact.dart';
import '../atoms/md_local_photo.dart';
import '../atoms/md_occasion_chip.dart';
import '../atoms/md_open_memory_link.dart';
import '../atoms/md_sticky_note.dart';
import '../molecules/md_app_card.dart';
import '../molecules/md_memory_cover_hero.dart';

/// A memory as a journal entry: when it was and what kind of day, the
/// title, one wide photo with its note pinned to the corner like a sticky
/// note on a photobooth print, and how many shots and people it holds. Tap
/// the photo to see the shots full screen; tap anywhere else to open the
/// memory. See CLAUDE.md §2.4, §36, §38.
///
/// ```text
/// ┌──────────────────────────────┐
/// │ THURSDAY, OCT 12 · 5:18 PM  (♥ Anniversary) │
/// │ Golden Hour by the Docks     │
/// │ ┌──────────────────────────┐ │
/// │ │                  📌┌────┐│ │
/// │ │        photo       │note││ │
/// │ │                     └────┘│ │
/// │ └──────────────────────────┘ │
/// │ ▣ 3 shots  ☺ 2 people  Open memory › │
/// └──────────────────────────────┘
/// ```
class MdMemoryJournalCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final memory = summary.memory;
    final (occasion, occasionIcon) = memoryOccasion(
      memory.title,
      summary.questCategory,
    );
    final shots = summary.photos.isEmpty
        ? (summary.coverPhoto == null ? 0 : 1)
        : summary.photos.length;
    final people = summary.people.length;

    return MdAppCard(
      onTap: onOpen,
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  memoryMoment(memory.capturedAt),
                  style: AppTypography.overline.copyWith(
                    color: AppColors.successInk,
                    letterSpacing: 0.8,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: MdOccasionChip(label: occasion, icon: occasionIcon),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            memory.title,
            style: AppTypography.heading2,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.md),
          _CoverPhoto(
            summary: summary,
            onTap: shots == 0 ? null : () => onViewPhoto(0),
          ),
          const SizedBox(height: AppSpacing.ms),
          // Wraps onto two lines rather than squeezing on small screens.
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.xs,
                children: [
                  MdIconFact(
                    style: AppTypography.caption,
                    icon: Icons.photo_library_outlined,
                    label: shots == 1 ? '1 shot' : '$shots shots',
                  ),
                  if (people > 0)
                    MdIconFact(
                      style: AppTypography.caption,
                      icon: Icons.people_outline_rounded,
                      label: people == 1 ? '1 person' : '$people people',
                    ),
                ],
              ),
              const MdOpenMemoryLink(),
            ],
          ),
        ],
      ),
    );
  }
}

/// The cover, wide, with the memory's note pinned to its top-right corner
/// like a sticky note left on the print. The occasion is already shown in
/// the card's header chip, so the photo itself stays uncluttered.
class _CoverPhoto extends StatelessWidget {
  const _CoverPhoto({required this.summary, required this.onTap});

  final MemorySummary summary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // A white paper border around the shot, like a real photobooth print
    // sitting on the page, not an edge-to-edge app image.
    final print = Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
        boxShadow: AppShadows.print,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: MdMemoryCoverHero(
            memoryId: summary.memory.id,
            child: MdLocalPhoto(path: summary.coverPhoto?.thumbnailPath),
          ),
        ),
      ),
    );

    final photo = Stack(
      clipBehavior: Clip.none,
      children: [
        print,
        Positioned(
          top: -AppSpacing.sm,
          right: AppSpacing.md,
          child: MdStickyNote(text: summary.description),
        ),
      ],
    );

    if (onTap == null) return ExcludeSemantics(child: photo);
    // Its own node, so it's a separate action from the card around it; the
    // note is read here too since it's otherwise a decorative overlay.
    return Semantics(
      container: true,
      button: true,
      label: 'View the photos. ${summary.description}',
      excludeSemantics: true,
      child: GestureDetector(onTap: onTap, child: photo),
    );
  }
}
