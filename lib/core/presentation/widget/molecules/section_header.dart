import 'package:flutter/material.dart';

import '../../../../config/constant/app_typography.dart';

/// A consistent "Section Title  ·  optional trailing" heading, used above
/// Home/Quest sections instead of ad hoc Text+Row pairs. See CLAUDE.md
/// §27, design system §13.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTypography.heading3),
        ?trailing,
      ],
    );
  }
}
