import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/empty_states/empty_state.dart';
import '../../../../data/services/service_providers.dart';
import '../view_models/capture_view_model.dart';

/// The photobooth capture experience: large preview, minimal chrome during
/// countdown, clear shot progress. See CLAUDE.md §34-35.
class CaptureScreen extends ConsumerWidget {
  const CaptureScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capture = ref.watch(captureViewModelProvider(sessionId));

    ref.listen(captureViewModelProvider(sessionId), (previous, next) {
      final phase = next.value?.phase;
      if (phase == CapturePhase.complete) {
        context.pushReplacement('/capture/$sessionId/reveal');
      }
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: capture.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.warmCoral),
        ),
        error: (error, stack) => Center(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: "Couldn't start the camera",
            message: '$error',
          ),
        ),
        data: (state) => _CaptureBody(sessionId: sessionId, state: state),
      ),
    );
  }
}

class _CaptureBody extends ConsumerWidget {
  const _CaptureBody({required this.sessionId, required this.state});

  final String sessionId;
  final CaptureState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camera = ref.watch(cameraServiceProvider);
    final controller = camera.controller;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null && controller.value.isInitialized)
          CameraPreview(controller)
        else
          const ColoredBox(color: Colors.black),

        if (state.phase == CapturePhase.countdown)
          Center(
            child: Text(
              '${state.countdownValue}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 96,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        if (state.phase == CapturePhase.instruction)
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 140,
            child: _InstructionCard(
              instruction: state.currentShot.instruction,
              onReady: () => ref
                  .read(captureViewModelProvider(sessionId).notifier)
                  .startCountdown(),
            ),
          ),

        if (state.phase == CapturePhase.captured)
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 140,
            child: _CapturedCard(
              isLastShot: state.isLastShot,
              onContinue: () => ref
                  .read(captureViewModelProvider(sessionId).notifier)
                  .continueToNextShot(),
            ),
          ),

        if (state.phase == CapturePhase.finishing)
          const Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 140,
            child: _FinishingCard(),
          ),

        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          right: AppSpacing.md,
          child: SafeArea(
            child: Text(
              'Shot ${state.shotNumber} of ${state.totalShots}',
              style: AppTypography.body.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({required this.instruction, required this.onReady});

  final String instruction;
  final VoidCallback onReady;

  @override
  Widget build(BuildContext context) {
    return _CaptureOverlayCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            instruction,
            textAlign: TextAlign.center,
            style: AppTypography.heading3,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: onReady,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warmCoral,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: const Text('Ready'),
          ),
        ],
      ),
    );
  }
}

class _CapturedCard extends StatelessWidget {
  const _CapturedCard({required this.isLastShot, required this.onContinue});

  final bool isLastShot;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _CaptureOverlayCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.softGreen,
            size: 32,
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: onContinue,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warmCoral,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
            ),
            child: Text(isLastShot ? 'Finish' : 'Next Shot'),
          ),
        ],
      ),
    );
  }
}

class _FinishingCard extends StatelessWidget {
  const _FinishingCard();

  @override
  Widget build(BuildContext context) {
    return const _CaptureOverlayCard(
      child: Text('Wrapping up your memory…', style: AppTypography.body),
    );
  }
}

class _CaptureOverlayCard extends StatelessWidget {
  const _CaptureOverlayCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warmCream,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: child,
    );
  }
}
