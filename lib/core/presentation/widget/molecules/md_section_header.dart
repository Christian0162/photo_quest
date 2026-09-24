import 'package:flutter/material.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';

/// A consistent section heading with an optional supporting line and a
/// trailing widget (count, "See all"). Marked as a header for screen
/// readers. See CLAUDE.md §27, design system §13.
class MdSectionHeader extends StatelessWidget {
  const MdSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(title, style: AppTypography.heading3),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(subtitle!, style: AppTypography.bodyMuted),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
