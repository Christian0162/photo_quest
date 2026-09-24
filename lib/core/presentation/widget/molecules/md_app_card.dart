import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../atoms/md_pressable_scale.dart';

/// Shared rounded surface for memory/quest/person cards — a photo print on
/// the cream table. Tappable cards get press feedback and a button role.
/// See CLAUDE.md §27, §30, design system §10.
class MdAppCard extends StatelessWidget {
  const MdAppCard({
    super.key,
    required this.child,
    this.onTap,
    this.color = AppColors.paper,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.radius = AppRadius.lg,
    this.elevated = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool elevated;

  /// Replaces the card's inner semantics with one clear label when tapped
  /// as a whole (e.g. "Family Day, September 17").
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: elevated ? AppShadows.card : null,
      ),
      child: Material(
        color: color,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
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
