import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/sharing/entities/shared_memory.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/sharing/md_network_photo.dart';
import '../../molecules/common/md_empty_state.dart';
import '../../organisms/common/md_app_scaffold.dart';

/// A memory a friend shared, opened: their photos first, then who shared it
/// and when. View only.
class SharedMemoryTemplate extends StatelessWidget {
  const SharedMemoryTemplate({
    super.key,
    required this.detail,
    required this.onOpenPhoto,
    required this.onLeave,
    required this.onRetry,
    required this.onAddPhotos,
    required this.addingPhotos,
  });

  final AsyncValue<SharedMemoryDetail> detail;
  final void Function(SharedMemoryDetail detail, int index) onOpenPhoto;
  final VoidCallback onLeave;
  final VoidCallback onRetry;

  final VoidCallback onAddPhotos;

  final bool addingPhotos;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      showAppBar: true,
      body: detail.when(
        loading: () => const SizedBox.shrink(),
        error: (error, stack) => MdEmptyState.error(
          title: "We couldn't open this memory",
          message:
              'It may no longer be shared with you, or you may be offline.',
          onRetry: onRetry,
        ),
        data: (memory) {
          final date = DateFormat.yMMMMd().format(memory.capturedAt);
          final avatar = memory.ownerAvatarUrl;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              0,
              AppSpacing.gutter,
              AppSpacing.xxl,
            ),
            children: [
              Semantics(
                header: true,
                child: Text(memory.title, style: AppTypography.display),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  ExcludeSemantics(
                    child: CircleAvatar(
                      radius: AppIconSizes.md,
                      backgroundColor: AppColors.softPeach,
                      foregroundImage: avatar == null
                          ? null
                          : NetworkImage(avatar),
                      child: Text(
                        memory.ownerName.characters.first.toUpperCase(),
                        style: AppTypography.label,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.ms),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shared by ${memory.ownerName}',
                          style: AppTypography.body,
                        ),
                        Text(date, style: AppTypography.bodyMuted),
                      ],
                    ),
                  ),
                ],
              ),
              if (memory.note != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(memory.note!, style: AppTypography.bodyLarge),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (memory.photos.isEmpty)
                Text(
                  'There are no photos in this memory yet.',
                  style: AppTypography.bodyMuted,
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: memory.photos.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 4 / 5,
                  ),
                  itemBuilder: (context, index) => _PhotoTile(
                    photo: memory.photos[index],
                    label:
                        '${memory.title}, photo ${index + 1} of '
                        '${memory.photos.length}',
                    onTap: () => onOpenPhoto(memory, index),
                  ),
                ),
              if (memory.canAddPhotos) ...[
                const SizedBox(height: AppSpacing.lg),
                MdPrimaryButton(
                  label: 'Add your photos',
                  icon: Icons.add_photo_alternate_outlined,
                  loading: addingPhotos,
                  onPressed: addingPhotos ? null : onAddPhotos,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              MdSecondaryButton(
                label: 'Remove from my list',
                icon: Icons.visibility_off_outlined,
                onPressed: onLeave,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.photo,
    required this.label,
    required this.onTap,
  });

  final SharedPhoto photo;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: [
        label,
        if (photo.isVideo) 'clip',
        if (photo.addedByName != null) 'added by ${photo.addedByName}',
      ].join(', '),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              MdNetworkPhoto(url: photo.previewUrl),
              if (photo.addedByName != null)
                Positioned(
                  left: AppSpacing.sm,
                  bottom: AppSpacing.sm,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.cameraScrim,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.ms,
                        vertical: AppSpacing.xs,
                      ),
                      child: Text(
                        'Added by ${photo.addedByName}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onCamera,
                        ),
                      ),
                    ),
                  ),
                ),
              if (photo.isVideo)
                const Center(
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    size: AppIconSizes.hero,
                    color: AppColors.onCamera,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
