import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_shadows.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../atoms/common/md_pressable_scale.dart';

/// The shared "poster" card: the picture fills the whole card and everything
/// else (stickers, title, buttons) sits inside it, on a charcoal fade so the
/// words stay readable on any photo. Tapping anywhere opens it; controls
/// placed in [overlay] (a button, a link) win over the card's own tap.
class MdPosterCard extends StatelessWidget {
  const MdPosterCard({
    super.key,
    required this.background,
    this.overlay = const [],
    this.onTap,
    this.semanticLabel,
    this.aspectRatio = 4 / 5,
    this.radius = AppRadius.base,
    this.scrimStart = 0.35,
  });

  final Widget background;

  final List<Widget> overlay;
  final VoidCallback? onTap;

  final String? semanticLabel;
  final double aspectRatio;
  final double radius;

  final double scrimStart;

  static const inset = AppSpacing.md;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: AppShadows.print,
      ),
      child: Material(
        color: AppColors.warmCharcoal,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                background,
                // Ignored by touches, so a swipeable [background] still gets them.
                IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(0, scrimStart * 2 - 1),
                        end: Alignment.bottomCenter,
                        colors: const [
                          AppColors.posterScrimClear,
                          AppColors.posterScrimDeep,
                        ],
                      ),
                    ),
                  ),
                ),
                ...overlay,
              ],
            ),
          ),
        ),
      ),
    );

    if (semanticLabel != null) {
      card = Semantics(
        button: onTap != null,
        label: semanticLabel,
        excludeSemantics: true,
        child: card,
      );
    }

    return MdPressableScale(enabled: onTap != null, scale: 0.98, child: card);
  }
}
