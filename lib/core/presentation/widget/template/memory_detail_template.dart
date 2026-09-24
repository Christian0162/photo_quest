import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../utils/app_haptics.dart';
import '../../view_model/memories/keepsake_view_model.dart';
import '../../view_model/memories/memory_detail_view_model.dart';
import '../atoms/fade_slide_in.dart';
import '../atoms/local_photo.dart';
import '../atoms/person_avatar.dart';
import '../atoms/primary_button.dart';
import '../atoms/skeleton_box.dart';
import '../molecules/empty_state.dart';
import '../molecules/memory_cover_hero.dart';
import '../molecules/section_header.dart';
import '../molecules/shot_media.dart';
import '../organisms/app_scaffold.dart';
import '../organisms/keepsake_canvas.dart';

/// Opening a memory should feel like opening a photo album: the photos
/// dominate, then the quest, the date, who was there, the printed strip,
/// and "Do this again". See CLAUDE.md §39, design system §33-34.
class MemoryDetailTemplate extends StatelessWidget {
  const MemoryDetailTemplate({
    super.key,
    required this.memoryId,
    required this.detail,
    this.coverPath,
    required this.onOpenPhoto,
    required this.onRetry,
    required this.onShare,
    required this.onDoAgain,
    required this.onDecorate,
    required this.onDownloadStrip,
    this.keepsake,
  });

  final String memoryId;
  final AsyncValue<MemoryDetail> detail;

  /// The cover from the card that was tapped: shown (and flown in) right
  /// away while the rest of the memory loads.
  final String? coverPath;

  /// Opens the photo at an index full screen.
  final void Function(MemoryDetail detail, int index) onOpenPhoto;
  final VoidCallback onRetry;

  /// Shares the photo strip; receives the share button's on-screen area so
  /// the share sheet can anchor to it on tablets.
  final ValueChanged<Rect?> onShare;
  final ValueChanged<String> onDoAgain;

  /// Opens the keepsake designer for this memory's print.
  final VoidCallback onDecorate;

  /// Saves the printed keepsake to the phone's photos.
  final VoidCallback onDownloadStrip;

  /// The keepsake design, played live: GIFs, boomerangs and 360° clips move
  /// inside the print. The kept print image shows instead until it loads,
  /// and whenever there's no saved design to redraw it from.
  final KeepsakeDesign? keepsake;

  @override
  Widget build(BuildContext context) {
    final data = detail.value;
    final questId = data?.questId;

    return AppScaffold(
      showAppBar: true,
      actions: [
        if (data?.stripPath != null)
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Share photo strip',
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () {
                final box = context.findRenderObject() as RenderBox?;
                onShare(
                  box == null
                      ? null
                      : box.localToGlobal(Offset.zero) & box.size,
                );
              },
            ),
          ),
      ],
      bottomAction: questId == null
          ? null
          : PrimaryButton(
              label: 'Do this again',
              icon: Icons.replay_rounded,
              onPressed: () => onDoAgain(questId),
            ),
      body: detail.when(
        loading: () => Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            0,
            AppSpacing.gutter,
            AppSpacing.gutter,
          ),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: coverPath == null
                    ? const SkeletonBox(radius: AppRadius.photo)
                    : MemoryCoverHero(
                        memoryId: memoryId,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.photo),
                          child: LocalPhoto(path: coverPath),
                        ),
                      ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const SkeletonBox(height: 32),
            ],
          ),
        ),
        error: (error, stack) => EmptyState.error(
          title: "We couldn't open this memory",
          onRetry: onRetry,
        ),
        data: (data) {
          final memory = data.memory;
          // Redraw the print live only from a saved design, so it always
          // matches the layout that was chosen (strip, grid or polaroid).
          final design = keepsake;
          final liveKeepsake =
              design != null && (design.isSaved || data.stripPath == null)
              ? design
              : null;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              0,
              AppSpacing.gutter,
              AppSpacing.xl,
            ),
            children: FadeSlideIn.staggered([
              if (data.photos.isEmpty)
                const AspectRatio(
                  aspectRatio: 4 / 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadius.photo),
                    ),
                    child: PhotoPlaceholder(),
                  ),
                )
              else
                _PhotoAlbum(
                  memoryId: memory.id,
                  photos: data.photos,
                  coverPhotoId: memory.coverPhotoId,
                  coverPath: coverPath,
                  title: memory.title,
                  onOpen: (index) => onOpenPhoto(data, index),
                ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                DateFormat.yMMMMEEEEd().format(memory.capturedAt).toUpperCase(),
                style: AppTypography.overline,
              ),
              const SizedBox(height: AppSpacing.xs),
              Semantics(
                header: true,
                child: Text(memory.title, style: AppTypography.heading1),
              ),
              if (memory.note != null) ...[
                const SizedBox(height: AppSpacing.ms),
                Text(memory.note!, style: AppTypography.bodyLarge),
              ],
              if (data.people.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(title: 'Who was there'),
                const SizedBox(height: AppSpacing.ms),
                Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.md,
                  children: [
                    for (final person in data.people)
                      SizedBox(
                        width: 72,
                        child: Column(
                          children: [
                            PersonAvatar(person: person, radius: 28),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              person.name,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
              if (data.stripPath != null) ...[
                const SizedBox(height: AppSpacing.xl),
                SectionHeader(
                  title: 'Your photo strip',
                  subtitle: 'Straight from the booth.',
                  trailing: TextButton.icon(
                    onPressed: onDecorate,
                    icon: const Icon(
                      Icons.auto_awesome_rounded,
                      size: AppIconSizes.md,
                    ),
                    label: const Text('Decorate'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 520),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        boxShadow: AppShadows.print,
                      ),
                      child: liveKeepsake == null
                          ? LocalPhoto(
                              path: data.stripPath,
                              fit: BoxFit.contain,
                              semanticLabel: 'Photo strip for ${memory.title}',
                            )
                          : Semantics(
                              image: true,
                              label: 'Photo strip for ${memory.title}',
                              child: KeepsakeCanvas(
                                design: liveKeepsake,
                                live: true,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: SecondaryButton(
                    label: 'Save to photos',
                    icon: Icons.download_rounded,
                    expand: false,
                    onPressed: onDownloadStrip,
                  ),
                ),
              ],
            ]),
          );
        },
      ),
    );
  }
}

/// Swipeable photos that open on the memory's cover. The thumbnail that was
/// just flown in stays underneath while the full-size original fades in on
/// top, so the album sharpens instead of blinking. Tap to view full screen.
class _PhotoAlbum extends StatefulWidget {
  const _PhotoAlbum({
    required this.memoryId,
    required this.photos,
    required this.coverPhotoId,
    required this.coverPath,
    required this.title,
    required this.onOpen,
  });

  final String memoryId;
  final List<Photo> photos;
  final String? coverPhotoId;

  /// The thumbnail from the tapped card, if any.
  final String? coverPath;
  final String title;
  final ValueChanged<int> onOpen;

  @override
  State<_PhotoAlbum> createState() => _PhotoAlbumState();
}

class _PhotoAlbumState extends State<_PhotoAlbum> {
  late final int _coverIndex = () {
    final index = widget.photos.indexWhere((p) => p.id == widget.coverPhotoId);
    return index < 0 ? 0 : index;
  }();
  late final _controller = PageController(initialPage: _coverIndex);
  late int _page = _coverIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.photos.length;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.photo),
              boxShadow: AppShadows.print,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: count,
                  onPageChanged: (page) {
                    AppHaptics.selection();
                    setState(() => _page = page);
                  },
                  itemBuilder: (context, index) {
                    final photo = widget.photos[index];
                    // Photos, GIFs and boomerangs play here; 360° clips loop.
                    Widget image = ShotMedia(
                      photo: photo,
                      semanticLabel:
                          'Shot ${index + 1} of $count from ${widget.title}',
                    );
                    if (index == _coverIndex) {
                      image = MemoryCoverHero(
                        memoryId: widget.memoryId,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            LocalPhoto(
                              path: widget.coverPath ?? photo.thumbnailPath,
                            ),
                            image,
                          ],
                        ),
                      );
                    }
                    return Semantics(
                      button: true,
                      onTapHint: 'view full screen',
                      child: GestureDetector(
                        onTap: () => widget.onOpen(index),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.photo),
                          child: image,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: AppSpacing.ms,
                  right: AppSpacing.ms,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: const BoxDecoration(
                        color: AppColors.cameraScrim,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.open_in_full_rounded,
                        size: AppIconSizes.sm,
                        color: AppColors.onCamera,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: AppSpacing.ms),
          _PageDots(count: count, current: _page),
        ],
      ],
    );
  }
}

/// "● ○ ○" — where you are in the album. The current dot stretches into a
/// pill, so position doesn't rely on color alone.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Photo ${current + 1} of $count',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: AppMotion.of(context, AppMotion.short),
              curve: AppMotion.standard,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
              width: i == current ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == current ? AppColors.warmCharcoal : AppColors.line,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
        ],
      ),
    );
  }
}
