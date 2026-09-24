import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../types/display_labels.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import '../atoms/local_photo.dart';
import '../atoms/occasion_chip.dart';
import '../atoms/open_memory_link.dart';
import '../molecules/app_card.dart';
import '../molecules/memory_cover_hero.dart';

/// A memory as a journal entry: when it was and what kind of day, the
/// title, one wide photo with its note written across the bottom, and how
/// many shots and people it holds. Tap the photo to see the shots full
/// screen; tap anywhere else to open the memory. See CLAUDE.md §38.
///
/// ```text
/// ┌──────────────────────────────┐
/// │ THURSDAY, OCT 12 · 5:18 PM  (♥ Anniversary) │
/// │ Golden Hour by the Docks     │
/// │ ┌──────────────────────────┐ │
/// │ │          photo           │ │
/// │ │ Warm chai & a breeze   ♥ │ │
/// │ └──────────────────────────┘ │
/// │ ▣ 3 shots  ☺ 2 people  Open memory › │
/// └──────────────────────────────┘
/// ```
class MemoryJournalCard extends StatelessWidget {
  const MemoryJournalCard({
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

    return AppCard(
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
                child: OccasionChip(label: occasion, icon: occasionIcon),
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
          const SizedBox(height: AppSpacing.ms),
          _CoverPhoto(
            summary: summary,
            occasionIcon: occasionIcon,
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
                  _Fact(
                    icon: Icons.photo_library_outlined,
                    label: shots == 1 ? '1 shot' : '$shots shots',
                  ),
                  if (people > 0)
                    _Fact(
                      icon: Icons.people_outline_rounded,
                      label: people == 1 ? '1 person' : '$people people',
                    ),
                ],
              ),
              const OpenMemoryLink(),
            ],
          ),
        ],
      ),
    );
  }
}

/// The cover, wide, with the memory's words written across a soft shade at
/// the bottom and its occasion icon in the corner.
class _CoverPhoto extends StatelessWidget {
  const _CoverPhoto({
    required this.summary,
    required this.occasionIcon,
    required this.onTap,
  });

  final MemorySummary summary;
  final IconData occasionIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final photo = ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MemoryCoverHero(
              memoryId: summary.memory.id,
              child: LocalPhoto(path: summary.coverPhoto?.thumbnailPath),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.cameraScrim],
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.ms,
              right: AppSpacing.ms,
              bottom: AppSpacing.sm,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      summary.description,
                      style: AppTypography.script.copyWith(
                        color: AppColors.onCamera,
                        fontSize: 20,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    occasionIcon,
                    size: AppIconSizes.md,
                    color: AppColors.onCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return ExcludeSemantics(child: photo);
    // Its own node, so it's a separate action from the card around it.
    return Semantics(
      container: true,
      button: true,
      label: 'View the photos',
      excludeSemantics: true,
      child: GestureDetector(onTap: onTap, child: photo),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppIconSizes.sm, color: AppColors.textMuted),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTypography.caption),
      ],
    );
  }
}
