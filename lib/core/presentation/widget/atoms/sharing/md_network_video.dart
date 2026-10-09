import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import 'md_network_photo.dart';

/// Plays a 360 clip a friend shared, muted and on a loop, like a living
/// photo. Tap to pause or play. Shows [posterUrl] until the clip is ready, and
/// keeps showing it if the clip can't load. With reduced motion it waits for a
/// tap instead of starting by itself. With [mirrored] it is flipped
/// left-right, as it is on the phone that made it.
class MdNetworkVideo extends StatefulWidget {
  const MdNetworkVideo({
    super.key,
    required this.url,
    this.posterUrl,
    this.mirrored = false,
    this.fit = BoxFit.contain,
  });

  final String url;
  final String? posterUrl;
  final bool mirrored;
  final BoxFit fit;

  @override
  State<MdNetworkVideo> createState() => _MdNetworkVideoState();
}

class _MdNetworkVideoState extends State<MdNetworkVideo> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _open(autoplay: !AppMotion.reduced(context));
  }

  Future<void> _open({required bool autoplay}) async {
    final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setVolume(0);
      await controller.setLooping(true);
      if (autoplay) await controller.play();
      if (mounted) setState(() => _ready = true);
    } on Object {
      // The poster keeps showing; a clip that won't load is not an error.
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _toggle() {
    final controller = _controller;
    if (controller == null || !_ready) return;
    controller.value.isPlaying ? controller.pause() : controller.play();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final poster = widget.posterUrl;

    Widget content;
    if (_ready && controller != null) {
      content = FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );
      if (widget.mirrored) {
        content = Transform.flip(flipX: true, child: content);
      }
    } else {
      content = poster == null
          ? const ColoredBox(color: AppColors.sunken)
          : MdNetworkPhoto(url: poster, fit: widget.fit);
    }

    final playing = controller?.value.isPlaying ?? false;
    return Semantics(
      button: true,
      label: playing ? 'Pause clip' : 'Play clip',
      child: GestureDetector(
        onTap: _toggle,
        child: Stack(
          fit: StackFit.expand,
          children: [
            content,
            if (_ready && !playing)
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
    );
  }
}
