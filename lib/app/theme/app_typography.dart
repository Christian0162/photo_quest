import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Headings use Outfit, body text uses Inter. See CLAUDE.md §29.
abstract final class AppTypography {
  static const _headingFamily = 'Outfit';
  static const _bodyFamily = 'Inter';

  static const TextStyle heading1 = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.warmCharcoal,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.warmCharcoal,
  );

  static const TextStyle heading3 = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.warmCharcoal,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.warmCharcoal,
  );

  static const TextStyle bodyMuted = TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF6B6866),
  );

  static const TextStyle button = TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.warmCream,
  );
}
