import 'package:flutter/material.dart';

/// Warm photobooth + nostalgic film palette. See CLAUDE.md §28.
///
/// The six brand colors are the palette; everything below them is a
/// semantic role derived from it. Widgets should reach for the role
/// (`textMuted`, `coralInk`, `paper`) rather than a raw brand color, so
/// contrast stays correct. Contrast pairs are locked in by
/// `test/config/app_colors_contrast_test.dart`.
abstract final class AppColors {
  // Brand palette.
  static const warmCoral = Color(0xFFFF6B5F);
  static const warmCream = Color(0xFFFFF9F3);
  static const softPeach = Color(0xFFFFD9C7);
  static const filmYellow = Color(0xFFFFD166);
  static const warmCharcoal = Color(0xFF252323);
  static const softGreen = Color(0xFFA8C7A1);

  // Text.
  static const textPrimary = warmCharcoal;

  /// Secondary copy. Passes 4.5:1 on cream, paper and peach.
  static const textMuted = Color(0xFF5E5A57);

  /// Text/icons placed *on* Warm Coral. Cream on coral is only ~2.7:1, so
  /// coral surfaces always carry charcoal content (~5.6:1).
  static const onCoral = warmCharcoal;

  /// Coral used as text or a thin icon on light surfaces (links, selected
  /// labels). Raw Warm Coral is too light to read there.
  static const coralInk = Color(0xFFA63828);

  // Surfaces.
  static const background = warmCream;

  /// Photo-print white for cards that sit on the cream background.
  static const paper = Color(0xFFFFFDFA);

  /// Quiet fill for inputs, skeletons and unselected controls.
  static const sunken = Color(0xFFF6EDE4);

  /// Hairline dividers and outlines — used sparingly (CLAUDE.md §30).
  static const line = Color(0xFFEADFD5);

  // States. Never communicate these by color alone (CLAUDE.md §65).
  static const successInk = Color(0xFF3D6B39);
  static const successSurface = Color(0xFFE6EFE3);
  static const error = Color(0xFFB3261E);
  static const errorSurface = Color(0xFFFBE4DF);

  // Photobooth (dark) context.
  static const camera = Color(0xFF0E0D0D);
  static const onCamera = Color(0xFFFFFFFF);
  static const onCameraMuted = Color(0xB3FFFFFF);
  static const cameraScrim = Color(0x8C000000);

  /// Card/photo shadow tint — charcoal, never pure black.
  static const shadow = Color(0x1F252323);
}
