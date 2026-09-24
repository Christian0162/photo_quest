import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Headings use Outfit, body text uses Inter — both bundled in
/// `assets/fonts`. Sizes follow design system §7; the OS text scale is
/// applied on top automatically. See CLAUDE.md §29.
abstract final class AppTypography {
  static const headingFamily = 'Outfit';
  static const bodyFamily = 'Inter';

  /// Handwriting — only for captions written on photobooth prints.
  static const scriptFamily = 'Caveat';

  /// Hero moments: greeting, "Quest complete".
  static const TextStyle display = TextStyle(
    fontFamily: headingFamily,
    fontSize: 36,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// Screen titles.
  static const TextStyle heading1 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 28,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.textPrimary,
  );

  /// Card heroes, step questions.
  static const TextStyle heading2 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Section headers, card titles.
  static const TextStyle heading3 = TextStyle(
    fontFamily: headingFamily,
    fontSize: 18,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 17,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  /// Supporting copy under a heading or on a card.
  static const TextStyle bodyMuted = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  /// Compact emphasized labels: chips, nav, status pills.
  static const TextStyle label = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 14,
    height: 1.3,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  /// Small uppercase kicker above a hero title ("TODAY'S QUEST").
  static const TextStyle overline = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.coralInk,
  );

  static const TextStyle button = TextStyle(
    fontFamily: bodyFamily,
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: AppColors.onCoral,
  );

  /// A handwritten note on a photobooth print ("Better together").
  static const TextStyle script = TextStyle(
    fontFamily: scriptFamily,
    fontSize: 22,
    height: 1.05,
    fontWeight: FontWeight.w600,
    color: AppColors.inkBrown,
  );

  /// Handwritten journal headings in the memory box ("October", "Earlier
  /// in October").
  static const TextStyle journal = TextStyle(
    fontFamily: scriptFamily,
    fontSize: 26,
    height: 1.1,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// The 3-2-1 photobooth countdown.
  static const TextStyle countdown = TextStyle(
    fontFamily: headingFamily,
    fontSize: 132,
    height: 1,
    fontWeight: FontWeight.w700,
    color: AppColors.onCamera,
    shadows: [Shadow(color: Color(0x66000000), blurRadius: 24)],
  );
}
