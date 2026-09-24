import 'package:flutter/material.dart';
import '../../../../config/constant/app_motion.dart';

/// Cross-fades between loading and loaded content with a gentle size
/// settle, so the page doesn't jump when data arrives. Children need
/// distinct keys per state.
class SmoothSwitch extends StatelessWidget {
  const SmoothSwitch({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);
    return AnimatedSize(
      duration: duration,
      curve: AppMotion.standard,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: duration,
        switchInCurve: AppMotion.standard,
        switchOutCurve: AppMotion.standard,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, ?current],
        ),
        child: child,
      ),
    );
  }
}
