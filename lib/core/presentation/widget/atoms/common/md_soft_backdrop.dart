import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';

/// The pre-account pages' backdrop: button-coral washed into a soft pink at
/// the top, fading to the cream page at the bottom.
class MdSoftBackdrop extends StatelessWidget {
  const MdSoftBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.warmCoral.withValues(alpha: 0.24),
              AppColors.warmCoral.withValues(alpha: 0.10),
              AppColors.background,
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
      ),
    );
  }
}
