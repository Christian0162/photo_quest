import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../molecules/camera/md_seconds_choice.dart';

/// Photobooth settings as a short sheet body: how long the countdown is, and
/// how long a 360° clip can run. Choices apply straight away — no Save
/// button.
class MdBoothSettingsSheet extends StatelessWidget {
  const MdBoothSettingsSheet({
    super.key,
    required this.countdownSeconds,
    required this.countdownChoices,
    required this.onCountdownChanged,
    required this.clipSeconds,
    required this.clipChoices,
    required this.onClipChanged,
  });

  final int countdownSeconds;
  final List<int> countdownChoices;
  final ValueChanged<int> onCountdownChanged;
  final int clipSeconds;
  final List<int> clipChoices;
  final ValueChanged<int> onClipChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Photobooth settings', style: AppTypography.heading2),
            const SizedBox(height: AppSpacing.lg),
            MdSecondsChoice(
              title: 'Countdown',
              subtitle: 'Time to get ready before a photo or GIF.',
              choices: countdownChoices,
              selected: countdownSeconds,
              onSelected: onCountdownChanged,
            ),
            const SizedBox(height: AppSpacing.lg),
            MdSecondsChoice(
              title: '360° clip length',
              subtitle: 'The longest a clip records while you hold.',
              choices: clipChoices,
              selected: clipSeconds,
              onSelected: onClipChanged,
            ),
          ],
        ),
      ),
    );
  }
}
