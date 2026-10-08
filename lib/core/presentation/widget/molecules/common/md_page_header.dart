import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../atoms/common/md_sticker.dart';

/// The top of a tab page: a small kicker, the page title and one muted
/// line, with an optional action on the right.
///
/// ```text
/// (Your memory box)
/// Memories                    (+)
/// Just for you and the people who were there.
/// ```
class MdPageHeader extends StatelessWidget {
  const MdPageHeader({
    super.key,
    required this.overline,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String overline;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: MdSticker(
            label: overline,
            delay: const Duration(milliseconds: 200),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          header: true,
          child: Text(
            title,
            style: AppTypography.display.copyWith(
              fontSize: 44,
              letterSpacing: -1.2,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: AppTypography.bodyMuted),
      ],
    );
    if (trailing == null) return text;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: text),
        const SizedBox(width: AppSpacing.sm),
        trailing!,
      ],
    );
  }
}
