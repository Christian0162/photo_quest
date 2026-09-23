import 'package:flutter/material.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';

/// Localized loading indicator, optionally with a short human message.
/// Prefer a [SkeletonBox] layout when the shape of the content is known.
/// See CLAUDE.md §43.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.size = AppIconSizes.lg,
    this.message,
    this.color,
  });

  final double size;
  final String? message;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: size,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
          ),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMuted.copyWith(color: color),
            ),
          ],
        ],
      ),
    );
  }
}
