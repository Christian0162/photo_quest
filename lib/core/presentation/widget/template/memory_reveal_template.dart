import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../view_model/camera/memory_reveal_view_model.dart';
import '../atoms/loading_indicator.dart';
import '../atoms/local_photo.dart';
import '../atoms/primary_button.dart';
import '../molecules/empty_state.dart';
import '../organisms/app_scaffold.dart';

/// The payoff after finishing a Quest: the photo strip rises in like a
/// fresh print, with who was there and when. Warm, not a game victory
/// screen. See CLAUDE.md §37, design system §32, §49.
class MemoryRevealTemplate extends StatelessWidget {
  const MemoryRevealTemplate({
    super.key,
    required this.reveal,
    required this.onRetry,
    required this.onKeep,
  });

  final AsyncValue<MemoryRevealResult> reveal;
  final VoidCallback onRetry;
  final ValueChanged<MemoryRevealResult> onKeep;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: reveal.when(
        loading: () =>
            const LoadingIndicator(message: 'Printing your photo strip…'),
        error: (error, stack) => EmptyState.error(
          title: "We couldn't finish your photo strip",
          message: 'Your photos are safe. Please try again.',
          onRetry: onRetry,
        ),
        data: (result) => _Reveal(result: result, onKeep: () => onKeep(result)),
      ),
    );
  }
}

class _Reveal extends StatelessWidget {
  const _Reveal({required this.result, required this.onKeep});

  final MemoryRevealResult result;
  final VoidCallback onKeep;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);
    final names = result.people.map((p) => p.name).join(' · ');

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduced ? Duration.zero : AppMotion.reveal,
      curve: AppMotion.standard,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * AppSpacing.xxl),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          AppSpacing.lg,
          AppSpacing.gutter,
          AppSpacing.md,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: AppIconSizes.md,
                  color: AppColors.coralInk,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text('QUEST COMPLETE', style: AppTypography.overline),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(
                result.people.isEmpty
                    ? 'You made a memory.'
                    : 'You made a memory together.',
                textAlign: TextAlign.center,
                style: AppTypography.display,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: AppShadows.print,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: LocalPhoto(
                      path: result.stripPath,
                      fit: BoxFit.contain,
                      semanticLabel: 'Your photo strip for ${result.title}',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              result.title,
              textAlign: TextAlign.center,
              style: AppTypography.heading2,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              [
                if (names.isNotEmpty) names,
                DateFormat.yMMMMd().format(result.capturedAt),
              ].join('  ·  '),
              textAlign: TextAlign.center,
              style: AppTypography.bodyMuted,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Keep this memory',
              icon: Icons.favorite_rounded,
              onPressed: onKeep,
            ),
          ],
        ),
      ),
    );
  }
}
