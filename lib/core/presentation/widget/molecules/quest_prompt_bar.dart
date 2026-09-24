import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../atoms/pressable_scale.dart';

/// The app's one primary action, floating above the navigation dock on
/// every tab. Every memory comes from a quest's photobooth, so tapping
/// starts one. Copy follows the product line "Do something together. Take
/// the picture. Keep the memory." (CLAUDE.md §1, §32, §57, design system
/// §58, §63).
///
/// ```text
/// ╭────────────────────────────────────────╮
/// │ (✦)  Start a quest                ((+))│
/// │      Do it together. Keep the memory.  │
/// ╰────────────────────────────────────────╯
/// ```
///
/// To catch the eye without nagging, the "+" sends out a soft ripple a few
/// times when the bar first appears, then rests. Skipped under reduced
/// motion (design system §48-50).
class QuestPromptBar extends StatelessWidget {
  const QuestPromptBar({super.key, required this.onTap});

  static const _title = 'Start a quest';
  static const _subtitle = 'Do it together. Keep the memory.';

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.xl);

    return Semantics(
      button: true,
      label: '$_title. $_subtitle',
      excludeSemantics: true,
      child: PressableScale(
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
            child: InkWell(
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
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: AppIconSizes.lg,
                        color: AppColors.softPeach,
                      ),
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
                    const SizedBox(width: AppSpacing.sm),
                    const _RipplingPlus(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The coral "+" with a charcoal plus (readable on coral, CLAUDE.md §65).
/// A ring swells out of it and fades, a few times, then stops.
class _RipplingPlus extends StatefulWidget {
  const _RipplingPlus();

  @override
  State<_RipplingPlus> createState() => _RipplingPlusState();
}

class _RipplingPlusState extends State<_RipplingPlus>
    with SingleTickerProviderStateMixin {
  static const _radius = 20.0;
  static const _ripples = 3;

  /// Lets the bar settle in before the first ripple.
  static const _delay = Duration(milliseconds: 600);
  static const _ripple = Duration(milliseconds: 1400);

  // One run covers the pause and every ripple, so there are no timers to
  // outlive the widget.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _delay + _ripple * _ripples,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || AppMotion.reduced(context)) return;
    _started = true;
    _controller.forward();
  }

  /// Progress through the current ripple, or null while resting.
  double? get _phase {
    if (!_controller.isAnimating) return null;
    final elapsed = _controller.duration! * _controller.value - _delay;
    if (elapsed.isNegative) return null;
    return (elapsed.inMicroseconds % _ripple.inMicroseconds) /
        _ripple.inMicroseconds;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: _radius * 2,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final phase = _phase;
              final visible = phase != null;
              final t = Curves.easeOut.transform(phase ?? 0);
              return Transform.scale(
                scale: 1 + 0.6 * t,
                child: Container(
                  width: _radius * 2,
                  height: _radius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.warmCoral.withValues(
                        alpha: visible ? 0.7 * (1 - t) : 0,
                      ),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
          const CircleAvatar(
            radius: _radius,
            backgroundColor: AppColors.warmCoral,
            foregroundColor: AppColors.onCoral,
            child: Icon(Icons.add_rounded, size: AppIconSizes.lg),
          ),
        ],
      ),
    );
  }
}
