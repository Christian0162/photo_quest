import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../atoms/common/md_round_icon_button.dart';

/// Today's date as a small kicker, the greeting, and the invitation —
/// with "memory" inked in coral so the one thing the app is for stands out.
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
              Text(
                DateFormat('EEEE · MMMM d').format(today).toUpperCase(),
                style: AppTypography.overline,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(greeting, style: AppTypography.bodyMuted),
              const SizedBox(height: AppSpacing.xs),
              Semantics(
                header: true,
                label: "Let's make a memory.",
                excludeSemantics: true,
                child: Text.rich(
                  TextSpan(
                    text: "Let's make a ",
                    children: [
                      TextSpan(
                        text: 'memory.',
                        style: AppTypography.display.copyWith(
                          color: AppColors.coralInk,
                        ),
                      ),
                    ],
                  ),
                  style: AppTypography.display,
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
