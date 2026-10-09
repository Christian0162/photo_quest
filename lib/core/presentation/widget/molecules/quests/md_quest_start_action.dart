import 'package:flutter/material.dart';

import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/quests/enum/status_tone.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/common/md_status_pill.dart';

/// The pinned "Let's start", with a line on what happens next.
class MdQuestStartAction extends StatelessWidget {
  const MdQuestStartAction({
    super.key,
    required this.hint,
    required this.everyoneIn,
    required this.canStart,
    required this.starting,
    required this.onStart,
  });

  final String? hint;
  final bool everyoneIn;
  final bool canStart;
  final bool starting;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: AppMotion.of(context, AppMotion.short),
          child: everyoneIn
              ? MdStatusPill(
                  key: const ValueKey('everyone-in'),
                  label: hint ?? "Everyone's in",
                  icon: Icons.celebration_rounded,
                  tone: StatusTone.positive,
                )
              : Text(
                  hint ??
                      "Next up: the photobooth. We'll ask to use your camera.",
                  key: ValueKey(hint),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMuted,
                ),
        ),
        const SizedBox(height: AppSpacing.ms),
        MdPrimaryButton(
          label: starting ? 'Getting ready…' : "Let's start",
          icon: Icons.photo_camera_rounded,
          loading: starting,
          onPressed: canStart ? onStart : null,
        ),
      ],
    );
  }
}
