import 'package:flutter/material.dart';

import '../../../../config/constant/app_spacing.dart';

/// Fades and lifts [child] in as [animation] runs 0 → 1.
class MdAppearTransition extends AnimatedWidget {
  const MdAppearTransition({
    super.key,
    required Animation<double> animation,
    required this.child,
  }) : super(listenable: animation);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    return Opacity(
      opacity: t.clamp(0, 1),
      child: Transform.translate(
        offset: Offset(0, (1 - t) * AppSpacing.sm),
        child: child,
      ),
    );
  }
}
