import 'package:flutter/material.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../utils/app_haptics.dart';

/// Photobooth settings as a short sheet: how long the countdown is, and
/// how long a 360° clip can run. Choices apply straight away — no Save
/// button. See design system §44.
Future<void> showBoothSettingsSheet(
  BuildContext context, {
  required int countdownSeconds,
  required List<int> countdownChoices,
  required ValueChanged<int> onCountdownChanged,
  required int clipSeconds,
  required List<int> clipChoices,
  required ValueChanged<int> onClipChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => _BoothSettingsSheet(
      countdownSeconds: countdownSeconds,
      countdownChoices: countdownChoices,
      onCountdownChanged: onCountdownChanged,
      clipSeconds: clipSeconds,
      clipChoices: clipChoices,
      onClipChanged: onClipChanged,
    ),
  );
}

class _BoothSettingsSheet extends StatefulWidget {
  const _BoothSettingsSheet({
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
  State<_BoothSettingsSheet> createState() => _BoothSettingsSheetState();
}

class _BoothSettingsSheetState extends State<_BoothSettingsSheet> {
  late int _countdown = widget.countdownSeconds;
  late int _clip = widget.clipSeconds;

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
            _SecondsChoice(
              title: 'Countdown',
              subtitle: 'Time to get ready before a photo or GIF.',
              choices: widget.countdownChoices,
              selected: _countdown,
              onSelected: (seconds) {
                setState(() => _countdown = seconds);
                widget.onCountdownChanged(seconds);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _SecondsChoice(
              title: '360° clip length',
              subtitle: 'The longest a clip records while you hold.',
              choices: widget.clipChoices,
              selected: _clip,
              onSelected: (seconds) {
                setState(() => _clip = seconds);
                widget.onClipChanged(seconds);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondsChoice extends StatelessWidget {
  const _SecondsChoice({
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
