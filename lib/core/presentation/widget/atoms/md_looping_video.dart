import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';
import 'md_local_photo.dart';

/// Plays a saved 360° clip muted, on loop, filling its box — like a living
/// photo. Tap to pause or play. With reduced motion it waits for a tap
/// instead of starting on its own. Shows [posterPath] until the clip is
/// ready, and keeps showing it if the clip can't be read. See CLAUDE.md §42,
/// design system §50.
class MdLoopingVideo extends StatefulWidget {
  const MdLoopingVideo({
    super.key,
    required this.path,
    this.posterPath,
    this.fit = BoxFit.cover,
    this.semanticLabel,
  });

  final String path;
  final String? posterPath;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  State<MdLoopingVideo> createState() => _MdLoopingVideoState();
}

class _MdLoopingVideoState extends State<MdLoopingVideo> {
  VideoPlayerController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void didUpdateWidget(covariant MdLoopingVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _controller?.dispose();
      _controller = null;
      _ready = false;
      _open();
    }
  }

  Future<void> _open() async {
    final file = File(widget.path);
    if (!await file.exists()) return;
    final controller = VideoPlayerController.file(file);
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      if (!mounted || _controller != controller) return;
      if (!AppMotion.reduced(context)) await controller.play();
      if (mounted) setState(() => _ready = true);
    } catch (_) {
      // Unreadable clip: the poster stays, which is the friendly fallback.
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    final controller = _controller;
    if (!_ready || controller == null) return;
    setState(() {
      controller.value.isPlaying ? controller.pause() : controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final playing = controller?.value.isPlaying ?? false;

    return Semantics(
      label: widget.semanticLabel,
      button: _ready,
      onTapHint: playing ? 'pause' : 'play',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: _togglePlay,
        child: Stack(
          fit: StackFit.expand,
          children: [
            MdLocalPhoto(path: widget.posterPath, fit: widget.fit),
            if (_ready && controller != null)
              FittedBox(
                fit: widget.fit,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            if (_ready && !playing)
              const Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.cameraScrim,
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.ms),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.onCamera,
                      size: 36,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
