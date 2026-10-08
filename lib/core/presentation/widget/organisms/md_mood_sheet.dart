import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../domain/people/enum/mood.dart';
import '../../../utils/app_haptics.dart';
import '../../types/mood_icon.dart';

/// "How are you feeling?" as a short sheet. Choosing a mood applies it
/// straight away and closes the sheet. Below it sits a "connect with
/// someone" row that is not available yet. See CLAUDE.md §54A.
Future<void> showMoodSheet(
  BuildContext context, {
  required Mood? current,
  required ValueChanged<Mood?> onChosen,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (context) => _MoodSheet(
      current: current,
      onChosen: (mood) {
        onChosen(mood);
        Navigator.of(context).pop();
      },
    ),
  );
}

class _MoodSheet extends StatelessWidget {
  const _MoodSheet({required this.current, required this.onChosen});

  final Mood? current;
  final ValueChanged<Mood?> onChosen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
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
            Text('How are you feeling?', style: AppTypography.heading2),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Only you see this, on this phone.',
              style: AppTypography.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final mood in Mood.values)
                  ChoiceChip(
                    avatar: Icon(mood.icon, size: AppIconSizes.md),
                    label: Text(mood.label),
                    selected: mood == current,
                    onSelected: (_) {
                      AppHaptics.selection();
                      onChosen(mood);
                    },
                  ),
              ],
            ),
            if (current != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => onChosen(null),
                  child: const Text('Clear how I feel'),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            const _ComingSoonConnection(),
          ],
        ),
      ),
    );
  }
}

/// Seeing how the people you love are doing needs accounts, which Photo
/// Quest doesn't have yet. Shown so people know it is on the way.
class _ComingSoonConnection extends StatelessWidget {
  const _ComingSoonConnection();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Connect with someone you love. Coming soon.',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.sunken,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            const Icon(Icons.favorite_border_rounded),
            const SizedBox(width: AppSpacing.ms),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Connect with someone', style: AppTypography.label),
                  const SizedBox(height: AppSpacing.xxs),
                  const Text(
                    'See how your partner, family and friends are feeling.',
                    style: AppTypography.bodyMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.filmYellow,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: const Text('Coming soon', style: AppTypography.caption),
            ),
          ],
        ),
      ),
    );
  }
}
