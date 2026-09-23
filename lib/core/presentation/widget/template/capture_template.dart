import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../errors/app_failure.dart';
import '../../view_model/camera/capture_view_model.dart';
import '../atoms/camera_icon_button.dart';
import '../atoms/capture_button.dart';
import '../atoms/loading_indicator.dart';
import '../atoms/local_photo.dart';
import '../atoms/participant_avatar_stack.dart';
import '../atoms/primary_button.dart';
import '../molecules/empty_state.dart';
import '../molecules/step_progress.dart';
import '../organisms/app_scaffold.dart';

/// The photobooth: the live camera dominates, with just enough guidance —
/// shot progress, the instruction and example, a countdown, then Keep or
/// Retake. See CLAUDE.md §34-35, design system §24-31.
class CaptureTemplate extends StatelessWidget {
  const CaptureTemplate({
    super.key,
    required this.capture,
    required this.onLeave,
    required this.onClose,
    required this.onRetry,
    required this.onCapture,
    required this.onSwitchCamera,
    required this.onKeep,
    required this.onRetake,
  });

  final AsyncValue<CaptureState> capture;

  /// Asks before leaving mid-quest — the close button and system back.
  final VoidCallback onLeave;

  /// Leaves straight away, when the booth never started.
  final VoidCallback onClose;
  final VoidCallback onRetry;
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;
  final VoidCallback onKeep;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.camera,
      safeArea: false,
      onBackBlocked: onLeave,
      body: capture.when(
        loading: () => const LoadingIndicator(
          message: 'Preparing your photobooth…',
          color: AppColors.onCamera,
        ),
        error: (error, stack) => SafeArea(
          child: Stack(
            children: [
              EmptyState.error(
                title: error is CameraPermissionFailure
                    ? 'Camera access needed'
                    : "The photobooth didn't start",
                message: error is AppFailure
                    ? error.message
                    : 'Something went wrong. Please try again.',
                onDark: true,
                onRetry: onRetry,
              ),
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.sm,
                child: CameraIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Close',
                  onPressed: onClose,
                ),
              ),
            ],
          ),
        ),
        data: (state) => _CaptureBody(
          state: state,
          onClose: onLeave,
          onCapture: onCapture,
          onSwitchCamera: onSwitchCamera,
          onKeep: onKeep,
          onRetake: onRetake,
        ),
      ),
    );
  }
}

class _CaptureBody extends StatefulWidget {
  const _CaptureBody({
    required this.state,
    required this.onClose,
    required this.onCapture,
    required this.onSwitchCamera,
    required this.onKeep,
    required this.onRetake,
  });

  final CaptureState state;
  final VoidCallback onClose;
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;
  final VoidCallback onKeep;
  final VoidCallback onRetake;

  @override
  State<_CaptureBody> createState() => _CaptureBodyState();
}

class _CaptureBodyState extends State<_CaptureBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _flashController;
  late final Animation<double> _flashOpacity;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
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
    // Shutter flash the instant a shot lands. Kept under reduced motion —
    // it's essential feedback, not decoration. See design system §29, §50.
    final justCaptured =
        oldWidget.state.phase == CapturePhase.countdown &&
        widget.state.phase == CapturePhase.captured;
    if (justCaptured) _flashController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final controller = state.cameraController;
    final phase = state.phase;
    final switchDuration = AppMotion.of(context, AppMotion.short);

    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null && controller.value.isInitialized)
          _CoverPreview(controller: controller)
        else
          const ColoredBox(color: AppColors.camera),

        // Legibility scrims behind the top and bottom chrome.
        const _EdgeScrims(),

        if (phase == CapturePhase.countdown)
          Center(
            child: AnimatedSwitcher(
              duration: switchDuration,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: Tween(begin: 1.4, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Text(
                '${state.countdownValue}',
                key: ValueKey(state.countdownValue),
                style: AppTypography.countdown,
                semanticsLabel: '${state.countdownValue}',
              ),
            ),
          ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.ms,
                AppSpacing.sm,
                AppSpacing.ms,
                0,
              ),
              child: Row(
                children: [
                  CameraIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Leave quest',
                    onPressed: phase == CapturePhase.finishing
                        ? null
                        : widget.onClose,
                  ),
                  const SizedBox(width: AppSpacing.ms),
                  Expanded(
                    child: StepProgress(
                      label: 'Shot',
                      current: state.currentIndex,
                      total: state.totalShots,
                      onDark: true,
                    ),
                  ),
                  if (state.participants.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.ms),
                    ParticipantAvatarStack(
                      people: state.participants,
                      radius: 14,
                      max: 3,
                      ringColor: AppColors.camera,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.gutter,
                0,
                AppSpacing.gutter,
                AppSpacing.lg,
              ),
              child: AnimatedSwitcher(
                duration: switchDuration,
                child: KeyedSubtree(
                  key: ValueKey(phase),
                  child: switch (phase) {
                    CapturePhase.instruction => _InstructionControls(
                      state: state,
                      canSwitchCamera: state.canSwitchCamera,
                      onCapture: widget.onCapture,
                      onSwitchCamera: widget.onSwitchCamera,
                    ),
                    CapturePhase.countdown => const SizedBox.shrink(),
                    CapturePhase.captured => _ReviewPanel(
                      state: state,
                      onKeep: widget.onKeep,
                      onRetake: widget.onRetake,
                    ),
                    CapturePhase.finishing ||
                    CapturePhase.complete => const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.xxl),
                      child: LoadingIndicator(
                        message: 'Wrapping up your memory…',
                        color: AppColors.onCamera,
                      ),
                    ),
                  },
                ),
              ),
            ),
          ),
        ),

        IgnorePointer(
          child: FadeTransition(
            opacity: _flashOpacity,
            child: const ColoredBox(color: AppColors.onCamera),
          ),
        ),
      ],
    );
  }
}

/// Fills the screen with the preview (cropping the edges) instead of
/// letterboxing it, so the booth feels immersive.
class _CoverPreview extends StatelessWidget {
  const _CoverPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final previewSize = controller.value.previewSize;
    if (previewSize == null) return CameraPreview(controller);

    // The plugin reports a landscape size; the booth is portrait.
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewSize.height,
          height: previewSize.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _EdgeScrims extends StatelessWidget {
  const _EdgeScrims();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Column(
        children: [
          _Scrim(height: 160, begin: Alignment.topCenter),
          Spacer(),
          _Scrim(height: 280, begin: Alignment.bottomCenter),
        ],
      ),
    );
  }
}

class _Scrim extends StatelessWidget {
  const _Scrim({required this.height, required this.begin});

  final double height;
  final Alignment begin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: -begin,
          colors: const [AppColors.cameraScrim, Colors.transparent],
        ),
      ),
    );
  }
}

/// What to do for this shot, the example, and the shutter.
class _InstructionControls extends StatelessWidget {
  const _InstructionControls({
    required this.state,
    required this.canSwitchCamera,
    required this.onCapture,
    required this.onSwitchCamera,
  });

  final CaptureState state;
  final bool canSwitchCamera;
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    final shot = state.currentShot;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (shot.exampleImagePath != null) ...[
              // A subtle example, never stronger than the real people in
              // the preview. See design system §26.
              Container(
                width: 64,
                height: 84,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: AppColors.onCamera, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: LocalPhoto(
                  path: shot.exampleImagePath,
                  semanticLabel: 'Example of this shot',
                ),
              ),
              const SizedBox(width: AppSpacing.ms),
            ],
            Expanded(
              child: Semantics(
                liveRegion: true,
                child: Text(
                  shot.instruction,
                  style: AppTypography.heading1.copyWith(
                    color: AppColors.onCamera,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox.square(dimension: AppTouch.minTarget),
            CaptureButton(onPressed: onCapture),
            if (canSwitchCamera)
              CameraIconButton(
                icon: Icons.cameraswitch_rounded,
                tooltip: 'Flip camera',
                onPressed: onSwitchCamera,
              )
            else
              const SizedBox.square(dimension: AppTouch.minTarget),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Tap to start a 3-second countdown',
          style: AppTypography.caption.copyWith(color: AppColors.onCameraMuted),
        ),
      ],
    );
  }
}

/// Keep / Retake for the photo just taken. Keep is primary; Retake stays
/// one tap away. See CLAUDE.md §35, design system §30.
class _ReviewPanel extends StatelessWidget {
  const _ReviewPanel({
    required this.state,
    required this.onKeep,
    required this.onRetake,
  });

  final CaptureState state;
  final VoidCallback onKeep;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    final photo = state.lastPhoto;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (photo != null)
          Container(
            height: MediaQuery.sizeOf(context).height * 0.34,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.print,
            ),
            child: AspectRatio(
              aspectRatio: photo.width > 0 && photo.height > 0
                  ? photo.width / photo.height
                  : 3 / 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: LocalPhoto(
                  path: photo.thumbnailPath,
                  semanticLabel: 'The photo you just took',
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        Semantics(
          liveRegion: true,
          child: Text(
            state.isLastShot ? "Nice one — that's the last shot!" : 'Nice one!',
            style: AppTypography.heading2.copyWith(color: AppColors.onCamera),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: state.isLastShot ? 'Keep it & finish' : 'Keep it',
          icon: Icons.check_rounded,
          onPressed: onKeep,
        ),
        const SizedBox(height: AppSpacing.sm),
        SecondaryButton(
          label: 'Retake',
          icon: Icons.replay_rounded,
          onDark: true,
          onPressed: onRetake,
        ),
      ],
    );
  }
}
