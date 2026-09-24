import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/config/constant/app_colors.dart';

/// WCAG 2.x contrast ratio between two opaque colors.
double contrast(Color a, Color b) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color c) =>
      0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
  final la = luminance(a);
  final lb = luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  // Every text role on every surface it is used on must stay readable
  // (4.5:1). See CLAUDE.md §65.
  const textPairs = {
    'primary text on cream': (AppColors.textPrimary, AppColors.background),
    'primary text on paper': (AppColors.textPrimary, AppColors.paper),
    'primary text on peach': (AppColors.textPrimary, AppColors.softPeach),
    'primary text on yellow': (AppColors.textPrimary, AppColors.filmYellow),
    'muted text on cream': (AppColors.textMuted, AppColors.background),
    'muted text on paper': (AppColors.textMuted, AppColors.paper),
    'muted text on peach': (AppColors.textMuted, AppColors.softPeach),
    'muted text on sunken': (AppColors.textMuted, AppColors.sunken),
    'button label on coral': (AppColors.onCoral, AppColors.warmCoral),
    'coral ink on cream': (AppColors.coralInk, AppColors.background),
    'coral ink on peach': (AppColors.coralInk, AppColors.softPeach),
    'success ink on success surface': (
      AppColors.successInk,
      AppColors.successSurface,
    ),
    'error on cream': (AppColors.error, AppColors.background),
    'muted icons on the nav dock': (AppColors.onDockMuted, AppColors.dock),
    'selected tab on cream pill': (AppColors.textPrimary, AppColors.warmCream),
    'cream on charcoal (snackbar)': (
      AppColors.warmCream,
      AppColors.warmCharcoal,
    ),
  };

  for (final MapEntry(key: name, value: (fg, bg)) in textPairs.entries) {
    test('$name meets 4.5:1', () {
      expect(contrast(fg, bg), greaterThanOrEqualTo(4.5));
    });
  }

  test('raw coral is never used for text on cream (too light)', () {
    // Documents why `coralInk` and `onCoral` exist.
    expect(contrast(AppColors.warmCoral, AppColors.background), lessThan(3));
  });
}
