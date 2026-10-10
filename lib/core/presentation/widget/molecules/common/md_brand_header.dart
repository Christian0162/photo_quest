import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import 'md_animated_photoquest_logo.dart';

/// The logo with "Photo Quest" written under it: the same brand mark on the
/// welcome screen and above every account form. Resizes smoothly when
/// [logoSize] or [titleSize] change, as the welcome drawer opens.
class MdBrandHeader extends StatelessWidget {
  const MdBrandHeader({
    super.key,
    this.logoSize = 240,
    this.titleSize = 52,
    this.glow = false,
  });

  final double logoSize;
  final double titleSize;

  /// A soft peach glow behind the logo, so the print sits in warm light.
  final bool glow;

  /// The logo's canvas has empty margin around the prints; trimming its
  /// layout height keeps the title right under them.
  static const _trim = 0.64;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);

    return TweenAnimationBuilder<double>(
      tween: Tween(end: logoSize),
      duration: duration,
      curve: AppMotion.standard,
      builder: (context, size, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (glow)
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: OverflowBox(
                      minWidth: 0,
                      minHeight: 0,
                      maxWidth: size * 1.3,
                      maxHeight: size * 1.3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.softPeach,
                              AppColors.softPeach.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Align(
                heightFactor: _trim,
                child: MdAnimatedPhotoQuestLogo(
                  size: size,
                  loop: true,
                  duration: const Duration(milliseconds: 3200),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Semantics(
            header: true,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: titleSize),
              duration: duration,
              curve: AppMotion.standard,
              builder: (context, fontSize, _) => FittedBox(
                // Scales down rather than wrapping on narrow phones or
                // large text.
                fit: BoxFit.scaleDown,
                child: Text(
                  'Photo Quest',
                  style: AppTypography.hero.copyWith(fontSize: fontSize),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
