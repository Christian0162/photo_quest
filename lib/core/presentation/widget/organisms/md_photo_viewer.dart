import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../atoms/camera_icon_button.dart';
import '../../../domain/memories/entities/photo.dart';
import '../molecules/shot_media.dart';

/// Opens [photos] full screen on black: swipe between shots, pinch or
/// double-tap to zoom, swipe down or tap close to go back. GIFs play and
/// 360° clips loop. With [onShare], the shot on screen can be shared as it
/// was captured. See design system §33 ("the photo should dominate").
Future<void> showPhotoViewer(
  BuildContext context, {
  required List<Photo> photos,
  required int initialIndex,
  required String title,
  void Function(Photo photo, Rect? origin)? onShare,
  ValueChanged<Photo>? onDownload,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: AppColors.camera,
      transitionDuration: AppMotion.of(context, AppMotion.medium),
      reverseTransitionDuration: AppMotion.of(context, AppMotion.short),
      pageBuilder: (context, _, _) => _PhotoViewer(
        photos: photos,
        initialIndex: initialIndex,
        title: title,
        onShare: onShare,
        onDownload: onDownload,
      ),
      transitionsBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({
    required this.photos,
    required this.initialIndex,
    required this.title,
    required this.onShare,
    required this.onDownload,
  });

  final List<Photo> photos;
  final int initialIndex;
  final String title;
  final void Function(Photo photo, Rect? origin)? onShare;
  final ValueChanged<Photo>? onDownload;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final _pageController = PageController(initialPage: widget.initialIndex);
  late int _page = widget.initialIndex;
  final _zoom = TransformationController();
  double _dragOffset = 0;

  bool get _zoomed => _zoom.value.getMaxScaleOnAxis() > 1.01;

  @override
  void dispose() {
    _pageController.dispose();
    _zoom.dispose();
    super.dispose();
  }

  void _toggleZoom(TapDownDetails details) {
    if (_zoomed) {
      _zoom.value = Matrix4.identity();
    } else {
      const scale = 2.5;
      final p = details.localPosition;
      _zoom.value = Matrix4.identity()
        ..translateByDouble(-p.dx * (scale - 1), -p.dy * (scale - 1), 0, 1)
        ..scaleByDouble(scale, scale, 1, 1);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.photos.length;
    final fade = (1 - _dragOffset.abs() / 400).clamp(0.3, 1.0);

    return Scaffold(
      backgroundColor: AppColors.camera.withValues(alpha: fade),
      body: Stack(
        children: [
          // Swipe down to dismiss (only when not zoomed in).
          GestureDetector(
            onVerticalDragUpdate: _zoomed
                ? null
                : (d) => setState(() => _dragOffset += d.delta.dy),
            onVerticalDragEnd: _zoomed
                ? null
                : (d) {
                    if (_dragOffset.abs() > 120 ||
                        d.velocity.pixelsPerSecond.dy.abs() > 800) {
                      Navigator.of(context).pop();
                    } else {
                      setState(() => _dragOffset = 0);
                    }
                  },
            child: Transform.translate(
              offset: Offset(0, _dragOffset),
              child: PageView.builder(
                controller: _pageController,
                physics: _zoomed
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                itemCount: count,
                onPageChanged: (page) {
                  _zoom.value = Matrix4.identity();
                  setState(() => _page = page);
                },
                itemBuilder: (context, index) => GestureDetector(
                  onDoubleTapDown: _toggleZoom,
                  onDoubleTap: () {},
                  child: InteractiveViewer(
                    transformationController: index == _page ? _zoom : null,
                    minScale: 1,
                    maxScale: 4,
                    onInteractionEnd: (_) => setState(() {}),
                    child: Center(
                      child: ShotMedia(
                        photo: widget.photos[index],
                        fit: BoxFit.contain,
                        semanticLabel:
                            'Shot ${index + 1} of $count from ${widget.title}',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  CameraIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  if (count > 1)
                    Text(
                      '${_page + 1} of $count',
                      style: AppTypography.label.copyWith(
                        color: AppColors.onCamera,
                      ),
                    ),
                  const SizedBox(width: AppSpacing.md),
                  if (widget.onDownload != null) ...[
                    CameraIconButton(
                      icon: Icons.download_rounded,
                      tooltip: 'Save to photos',
                      onPressed: () => widget.onDownload!(widget.photos[_page]),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  if (widget.onShare != null)
                    Builder(
                      builder: (context) => CameraIconButton(
                        icon: Icons.ios_share_rounded,
                        tooltip: 'Share this shot',
                        onPressed: () {
                          final box = context.findRenderObject() as RenderBox?;
                          widget.onShare!(
                            widget.photos[_page],
                            box == null
                                ? null
                                : box.localToGlobal(Offset.zero) & box.size,
                          );
                        },
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
