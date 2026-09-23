import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../view_model/memories/memory_detail_view_model.dart';
import '../atoms/local_photo.dart';
import '../atoms/person_avatar.dart';
import '../atoms/primary_button.dart';
import '../atoms/skeleton_box.dart';
import '../molecules/empty_state.dart';
import '../molecules/section_header.dart';
import '../organisms/app_scaffold.dart';

/// Opening a memory should feel like opening a photo album: the photos
/// dominate, then the quest, the date, who was there, the printed strip,
/// and "Do this again". See CLAUDE.md §39, design system §33-34.
class MemoryDetailTemplate extends StatelessWidget {
  const MemoryDetailTemplate({
    super.key,
    required this.detail,
    required this.onRetry,
    required this.onShare,
    required this.onDoAgain,
  });

  final AsyncValue<MemoryDetail> detail;
  final VoidCallback onRetry;

  /// Shares the photo strip; receives the share button's on-screen area so
  /// the share sheet can anchor to it on tablets.
  final ValueChanged<Rect?> onShare;
  final ValueChanged<String> onDoAgain;

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
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: SkeletonBox(radius: AppRadius.photo),
              ),
              SizedBox(height: AppSpacing.lg),
              SkeletonBox(height: 32),
            ],
          ),
        ),
        error: (error, stack) => EmptyState.error(
          title: "We couldn't open this memory",
          onRetry: onRetry,
        ),
        data: (data) {
          final memory = data.memory;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              0,
              AppSpacing.gutter,
              AppSpacing.xl,
            ),
            children: [
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
                _PhotoAlbum(photos: data.photos, title: memory.title),
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
                const SectionHeader(
                  title: 'Your photo strip',
                  subtitle: 'Straight from the booth.',
                ),
                const SizedBox(height: AppSpacing.md),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 420),
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        boxShadow: AppShadows.print,
                      ),
                      child: LocalPhoto(
                        path: data.stripPath,
                        fit: BoxFit.contain,
                        semanticLabel: 'Photo strip for ${memory.title}',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Swipeable photos with a "2 / 4" position marker.
class _PhotoAlbum extends StatefulWidget {
  const _PhotoAlbum({required this.photos, required this.title});

  final List<Photo> photos;
  final String title;

  @override
  State<_PhotoAlbum> createState() => _PhotoAlbumState();
}

class _PhotoAlbumState extends State<_PhotoAlbum> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final count = widget.photos.length;

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.photo),
          boxShadow: AppShadows.print,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.photo),
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                itemCount: count,
                onPageChanged: (page) => setState(() => _page = page),
                itemBuilder: (context, index) => LocalPhoto(
                  path: widget.photos[index].originalPath,
                  semanticLabel:
                      'Photo ${index + 1} of $count from ${widget.title}',
                ),
              ),
              if (count > 1)
                Positioned(
                  right: AppSpacing.ms,
                  bottom: AppSpacing.ms,
                  child: ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cameraScrim,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        '${_page + 1} / $count',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onCamera,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
