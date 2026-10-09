import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';

/// What a whole screen shows while its data is still being fetched: a
/// little photo tile that softly breathes, and one warm line. Nothing else
/// from the page is drawn yet, but the tab bar stays, since it belongs to
/// the shell. Under reduced motion the tile just sits still.
class MdScreenLoading extends StatefulWidget {
  const MdScreenLoading({super.key, this.message = 'Just a moment…'});

  final String message;

  @override
  State<MdScreenLoading> createState() => _MdScreenLoadingState();
}

class _MdScreenLoadingState extends State<MdScreenLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = AppMotion.reduced(context);
    if (reduced && _started) {
      _controller
        ..stop()
        ..value = 0;
      _started = false;
    } else if (!reduced && !_started) {
      _controller.repeat(reverse: true);
      _started = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: 'Loading. ${widget.message}',
      excludeSemantics: true,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ScaleTransition(
                scale: Tween(begin: 0.92, end: 1.0).animate(
                  CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
                ),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.softPeach,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    size: AppIconSizes.hero,
                    color: AppColors.warmCoral,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
