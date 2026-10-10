import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';

/// A calm inline message above an account form's button: what went wrong
/// (and what to do), or a quiet confirmation. The icon carries the meaning
/// so it never relies on color alone, and screen readers announce it when
/// it appears.
class MdAuthMessage extends StatelessWidget {
  const MdAuthMessage.error(this.message, {super.key}) : isError = true;

  const MdAuthMessage.notice(this.message, {super.key}) : isError = false;

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isError ? AppColors.errorSurface : AppColors.successSurface,
          borderRadius: BorderRadius.circular(AppRadius.base),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.mark_email_read_outlined,
                size: AppIconSizes.md,
                color: isError ? AppColors.error : AppColors.successInk,
              ),
              const SizedBox(width: AppSpacing.ms),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.body.copyWith(
                    color: isError ? AppColors.error : AppColors.successInk,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
