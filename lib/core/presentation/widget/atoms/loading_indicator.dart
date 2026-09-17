import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';

/// Localized loading indicator. Never a full-screen spinner for something
/// that can show a skeleton instead. See CLAUDE.md §42.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.size = 24});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.warmCoral,
        ),
      ),
    );
  }
}
