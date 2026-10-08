import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../atoms/md_pressable_scale.dart';

/// The welcome nudge shown when the app opens: one line inviting people to
/// start a quest. Tapping it takes you to the quests; the close icon on the
/// right dismisses it. Copy follows the product line "Do something together.
/// Take the picture. Keep the memory." (CLAUDE.md §1, §57, design system
/// §63).
///
/// ```text
/// ╭────────────────────────────────────────╮
/// │ (✦)  Start a quest                  (✕)│
/// │      Do it together. Keep the memory.  │
/// ╰────────────────────────────────────────╯
/// ```
class MdQuestPromptBar extends StatelessWidget {
  const MdQuestPromptBar({
    super.key,
    required this.onTap,
    required this.onClose,
  });

  static const _title = 'Start a quest';
  static const _subtitle = 'Do it together. Keep the memory.';

  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.xl);

    return MdPressableScale(
      enabled: true,
      scale: 0.98,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: AppShadows.floating,
        ),
        child: Material(
          color: AppColors.dock,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: '$_title. $_subtitle',
                  excludeSemantics: true,
                  // No ink: the card's own press-scale is the feedback.
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.ms),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.onCamera.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const _TwinklingSparkle(),
                          ),
                          const SizedBox(width: AppSpacing.ms),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _title,
                                  style: AppTypography.heading3.copyWith(
                                    color: AppColors.warmCream,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  _subtitle,
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.onDockMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose,
                tooltip: 'Close',
                icon: const Icon(Icons.close_rounded),
                iconSize: AppIconSizes.md,
                color: AppColors.onDockMuted,
                style: IconButton.styleFrom(
                  overlayColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
          ),
        ),
      ),
    );
  }
}

/// The sparkle in the card's badge. It twinkles: swells, brightens and
/// turns a little, then settles, pausing between twinkles for as long as the
/// card is on screen. Skipped under reduced motion (design system §48-50).
class _TwinklingSparkle extends StatefulWidget {
  const _TwinklingSparkle();

  @override
  State<_TwinklingSparkle> createState() => _TwinklingSparkleState();
}

class _TwinklingSparkleState extends State<_TwinklingSparkle>
    with SingleTickerProviderStateMixin {
  static const _twinkle = Duration(milliseconds: 900);
  static const _pause = Duration(milliseconds: 900);

  // One run is a single twinkle plus its pause, repeated until the widget is
  // disposed (the card closing), so there are no timers to outlive it.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _twinkle + _pause,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || AppMotion.reduced(context)) return;
    _started = true;
    _controller.repeat();
  }

  /// 0 while resting, rising to 1 and back to 0 through each twinkle.
  double get _glow {
    final into = (_controller.duration! * _controller.value).inMicroseconds;
    if (into >= _twinkle.inMicroseconds) return 0;
    return math.sin(math.pi * into / _twinkle.inMicroseconds);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final glow = Curves.easeInOut.transform(_glow);
          return Opacity(
            opacity: 0.65 + 0.35 * glow,
            child: Transform.rotate(
              angle: 0.35 * glow,
              child: Transform.scale(scale: 1 + 0.25 * glow, child: child),
            ),
          );
        },
        child: const Icon(
          Icons.auto_awesome_rounded,
          size: AppIconSizes.lg,
          color: AppColors.softPeach,
        ),
      ),
    );
  }
}
