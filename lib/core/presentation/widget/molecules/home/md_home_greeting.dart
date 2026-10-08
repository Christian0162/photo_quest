import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../atoms/common/md_round_icon_button.dart';
import '../../atoms/common/md_sticker.dart';

/// Today's date as a tilted sticker, the greeting, and the invitation set
/// big enough to read from across a table.
class MdHomeGreeting extends StatelessWidget {
  const MdHomeGreeting({
    super.key,
    required this.greeting,
    required this.today,
    required this.onOpenSettings,
  });

  final String greeting;
  final DateTime today;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: MdSticker(
                  label: DateFormat('EEEE, MMM d').format(today),
                  icon: Icons.wb_sunny_rounded,
                  delay: const Duration(milliseconds: 250),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                greeting,
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Semantics(
                header: true,
                child: Text(
                  "Let's make a memory.",
                  style: AppTypography.display.copyWith(
                    fontSize: 44,
                    height: 1.02,
                    letterSpacing: -1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        MdRoundIconButton(
          icon: Icons.settings_outlined,
          tooltip: 'Settings',
          onPressed: onOpenSettings,
        ),
      ],
    );
  }
}
