import 'package:flutter/material.dart';
import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../utils/app_haptics.dart';
import '../atoms/local_photo.dart';
import '../molecules/memory_cover_hero.dart';
import '../molecules/shot_media.dart';
import '../atoms/page_dots.dart';

/// Swipeable photos that open on the memory's cover. The thumbnail that was
/// just flown in stays underneath while the full-size original fades in on
/// top, so the album sharpens instead of blinking. Tap to view full screen.
class PhotoAlbum extends StatefulWidget {
  const PhotoAlbum({super.key, 
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
  State<PhotoAlbum> createState() => _PhotoAlbumState();
}

class _PhotoAlbumState extends State<PhotoAlbum> {
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
          PageDots(count: count, current: _page),
        ],
      ],
    );
  }
}
