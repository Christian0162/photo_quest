import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../utils/app_haptics.dart';

/// A titled row of choice chips for a number of seconds; applies on tap.
class MdSecondsChoice extends StatelessWidget {
  const MdSecondsChoice({
    super.key,
    required this.title,
    required this.subtitle,
    required this.choices,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final String subtitle;
  final List<int> choices;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.label),
        const SizedBox(height: AppSpacing.xxs),
        Text(subtitle, style: AppTypography.bodyMuted),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final seconds in choices)
              ChoiceChip(
                label: Text('$seconds seconds'),
                selected: seconds == selected,
                onSelected: (_) {
                  AppHaptics.selection();
                  onSelected(seconds);
                },
              ),
          ],
        ),
      ],
    );
  }
}
