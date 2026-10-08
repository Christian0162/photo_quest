import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_shadows.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../atoms/common/md_pressable_scale.dart';

class MdQuestPromptBar extends StatelessWidget {
  const MdQuestPromptBar({super.key, required this.onTap});

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
      child: MdPressableScale(
        enabled: true,
        scale: 0.98,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            // A charcoal lip under the coral, like the primary button.
            boxShadow: const [
              BoxShadow(color: AppColors.warmCharcoal, offset: Offset(0, 4)),
              ...AppShadows.floating,
            ],
          ),
          child: Material(
            color: AppColors.warmCoral,
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
                        color: AppColors.paper.withValues(alpha: 0.55),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: AppIconSizes.lg,
                        color: AppColors.onCoral,
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
                              color: AppColors.onCoral,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            _subtitle,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.onCoral,
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

/// The charcoal "+" with a cream plus, sitting on the coral bar.
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
                      color: AppColors.warmCharcoal.withValues(
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
            backgroundColor: AppColors.warmCharcoal,
            foregroundColor: AppColors.warmCream,
            child: Icon(Icons.add_rounded, size: AppIconSizes.lg),
          ),
        ],
      ),
    );
  }
}
