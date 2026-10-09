import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Subtle elevation so cards read like photo prints on a table, not
/// floating enterprise panels. See CLAUDE.md §27, design system §10.
abstract final class AppShadows {
  /// Resting cards.
  static const card = [
    BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 6)),
  ];

  /// Printed photos and the photo strip — a little more lift.
  static const print = [
    BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 10)),
  ];

  /// Floating chrome such as the bottom navigation bar.
  static const floating = [
    BoxShadow(color: AppColors.shadow, blurRadius: 28, offset: Offset(0, 8)),
  ];
}
