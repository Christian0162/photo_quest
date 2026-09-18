import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../widget/atoms/participant_avatar_stack.dart';
import '../../widget/molecules/empty_state.dart';
import '../../../data/services/service_providers.dart';
import '../../view_model/camera/capture_view_model.dart';

/// The photobooth capture experience: large preview, minimal chrome during
/// countdown, clear shot progress. See CLAUDE.md §34-35, design system
/// §24-32.
class CaptureScreen extends ConsumerWidget {
  const CaptureScreen({super.key, required this.sessionId});

  final String sessionId;

  Future<void> _confirmLeave(BuildContext context) async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Quest?'),
        content: const Text("The photos you've taken so far will be lost."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.warmCoral),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (leave == true && context.mounted) context.pop();
  }

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.warmCoral),
              SizedBox(height: AppSpacing.md),
              Text(
                'Preparing your photobooth…',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: EmptyState(
            icon: Icons.error_outline_rounded,
            title: "Couldn't start the camera",
            message: '$error',
          ),
        ),
        data: (state) => _CaptureBody(
          sessionId: sessionId,
          state: state,
          onClose: () => _confirmLeave(context),
        ),
      ),
    );
  }
}

class _CaptureBody extends ConsumerStatefulWidget {
  const _CaptureBody({
    required this.sessionId,
    required this.state,
    required this.onClose,
  });

  final String sessionId;
  final CaptureState state;
  final VoidCallback onClose;

  @override
  ConsumerState<_CaptureBody> createState() => _CaptureBodyState();
}

class _CaptureBodyState extends ConsumerState<_CaptureBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashController;
  late final Animation<double> _flashOpacity;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    // Flashes bright then fades, rather than a linear 0→1 ramp.
    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 85),
    ]).animate(_flashController);
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CaptureBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Shutter flash the instant a shot lands. See design system §29, §49.
    final justCaptured =
        oldWidget.state.phase == CapturePhase.countdown &&
        widget.state.phase == CapturePhase.captured;
    if (justCaptured) {
      _flashController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = ref.watch(cameraServiceProvider);
    final controller = camera.controller;
    final state = widget.state;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null && controller.value.isInitialized)
          CameraPreview(controller)
        else
          const ColoredBox(color: Colors.black),

        if (state.phase == CapturePhase.countdown)
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Text(
                '${state.countdownValue}',
                key: ValueKey(state.countdownValue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 110,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        if (state.phase == CapturePhase.instruction &&
            state.currentShot.exampleImagePath != null)
          Positioned(
            right: AppSpacing.md,
            top: 96,
            child: _ExampleThumbnail(path: state.currentShot.exampleImagePath!),
          ),

        if (state.phase == CapturePhase.instruction)
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 140,
            child: _InstructionCard(
              instruction: state.currentShot.instruction,
              onReady: () => ref
                  .read(captureViewModelProvider(widget.sessionId).notifier)
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
                  .read(captureViewModelProvider(widget.sessionId).notifier)
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
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onClose,
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (state.participants.isNotEmpty) ...[
                    ParticipantAvatarStack(
                      people: state.participants,
                      radius: 12,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Shot ${state.shotNumber} of ${state.totalShots}',
                          style: AppTypography.bodyMuted.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs / 2),
                        _ProgressDots(
                          total: state.totalShots,
                          current: state.currentIndex,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Shutter flash. See design system §29, §49.
        IgnorePointer(
          child: AnimatedBuilder(
            animation: _flashOpacity,
            builder: (context, _) => Opacity(
              opacity: _flashOpacity.value,
              child: const ColoredBox(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

/// "● ● ○" shot progress, alongside the "Shot X of Y" text. See design
/// system §31.
class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.xs / 2),
            child: Icon(
              Icons.circle,
              size: 6,
              color: i <= current ? AppColors.warmCoral : Colors.white38,
            ),
          ),
      ],
    );
  }
}

class _ExampleThumbnail extends StatelessWidget {
  const _ExampleThumbnail({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    // A subtle example, never stronger than the real camera preview.
    // See design system §26.
    return Opacity(
      opacity: 0.9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Container(
          width: 72,
          height: 96,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white54, width: 2),
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Image.file(File(path), fit: BoxFit.cover),
        ),
      ),
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
          _PressableButton(onPressed: onReady, child: const Text('Ready')),
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
          Text(
            isLastShot ? 'Nice one — that\'s the last one!' : 'Nice one!',
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          _PressableButton(
            onPressed: onContinue,
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

/// A button that scales down on press, so the primary capture-flow action
/// feels physical. See design system §29, §52.
class _PressableButton extends StatefulWidget {
  const _PressableButton({required this.onPressed, required this.child});

  final VoidCallback onPressed;
  final Widget child;

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.warmCoral,
            borderRadius: BorderRadius.circular(26),
          ),
          child: DefaultTextStyle(
            style: AppTypography.button,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
