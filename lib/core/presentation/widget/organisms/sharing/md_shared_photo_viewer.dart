import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/sharing/entities/shared_memory.dart';
import '../../atoms/common/md_round_icon_button.dart';
import '../../atoms/sharing/md_network_photo.dart';
import '../../atoms/sharing/md_network_video.dart';

/// Opens a shared memory's photos full screen at [initialIndex]: swipe
/// between them, pinch to zoom, tap a clip to pause it.
Future<void> showSharedPhotoViewer(
  BuildContext context, {
  required List<SharedPhoto> photos,
  required int initialIndex,
  required String title,
}) {
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (context) => MdSharedPhotoViewer(
        photos: photos,
        initialIndex: initialIndex,
        title: title,
      ),
    ),
  );
}

class MdSharedPhotoViewer extends StatefulWidget {
  const MdSharedPhotoViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.title,
  });

  final List<SharedPhoto> photos;
  final int initialIndex;
  final String title;

  @override
  State<MdSharedPhotoViewer> createState() => _MdSharedPhotoViewerState();
}

class _MdSharedPhotoViewerState extends State<MdSharedPhotoViewer> {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.photos;

    return Scaffold(
      backgroundColor: AppColors.camera,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pages,
            itemCount: photos.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) {
              final photo = photos[index];
              return photo.isVideo
                  ? MdNetworkVideo(
                      key: ValueKey(photo.id),
                      url: photo.url,
                      posterUrl: photo.thumbnailUrl,
                      mirrored: photo.mirrored,
                    )
                  : InteractiveViewer(
                      child: MdNetworkPhoto(
                        url: photo.url,
                        fit: BoxFit.contain,
                        semanticLabel:
                            '${widget.title}, photo ${index + 1} of '
                            '${photos.length}',
                      ),
                    );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  MdRoundIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (photos.length > 1)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.cameraScrim,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Text(
                          '${_index + 1} of ${photos.length}',
                          style: AppTypography.label.copyWith(
                            color: AppColors.onCamera,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
