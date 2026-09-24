import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../atoms/md_primary_button.dart';

/// Warm, encouraging empty state — never a bare "No data found." The
/// [MdEmptyState.error] variant says what happened and offers a retry, never
/// a raw exception. See CLAUDE.md §42, §44, design system §40-42.
class MdEmptyState extends StatelessWidget {
  const MdEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onDark = false,
  });

  /// A friendly failure with an optional "Try again" action.
  MdEmptyState.error({
    Key? key,
    required String title,
    String message = 'Something went wrong. Please try again.',
    VoidCallback? onRetry,
    bool onDark = false,
  }) : this(
         key: key,
         icon: Icons.cloud_off_rounded,
         title: title,
         message: message,
         onDark: onDark,
         action: onRetry == null
             ? null
             : MdSecondaryButton(
                 label: 'Try again',
                 icon: Icons.refresh_rounded,
                 expand: false,
                 onDark: onDark,
                 onPressed: onRetry,
               ),
       );

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final titleColor = onDark ? AppColors.onCamera : AppColors.textPrimary;
    final bodyColor = onDark ? AppColors.onCameraMuted : AppColors.textMuted;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: onDark ? AppColors.cameraScrim : AppColors.softPeach,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: AppIconSizes.xl, color: titleColor),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.heading2.copyWith(color: titleColor),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: bodyColor),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
