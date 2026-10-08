import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Subtle elevation so cards read like photo prints on a table, not
/// floating enterprise panels.
abstract final class AppShadows {
  static const card = [
    BoxShadow(color: AppColors.shadow, blurRadius: 16, offset: Offset(0, 6)),
  ];

  static const print = [
    BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 10)),
  ];

  static const floating = [
    BoxShadow(color: AppColors.shadow, blurRadius: 28, offset: Offset(0, 8)),
  ];
}
