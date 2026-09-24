
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../errors/app_failure.dart';
import '../../../utils/app_haptics.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../domain/memories/enum/photo_look.dart';
import '../atoms/camera_icon_button.dart';
import '../atoms/capture_button.dart';
import '../atoms/loading_indicator.dart';
import '../atoms/local_photo.dart';
import '../atoms/participant_avatar_stack.dart';
import '../atoms/primary_button.dart';
import '../molecules/capture_mode_switch.dart';
import '../molecules/empty_state.dart';
import '../molecules/look_picker.dart';
import '../molecules/pose_idea_card.dart';
import '../molecules/shot_media.dart';
import '../molecules/step_progress.dart';
import '../organisms/app_scaffold.dart';
import '../../../domain/camera/enum/capture_phase.dart';
import '../../../domain/camera/enum/capture_mode.dart';
import '../../types/camera/capture_state.dart';
import '../atoms/hold_shutter_button.dart';
import '../atoms/print_pop_in.dart';
import '../atoms/camera_edge_scrims.dart';
import '../molecules/booth_countdown.dart';
import '../molecules/processing_progress.dart';

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
    required this.onCancelCountdown,
    required this.onSwitchCamera,
    required this.onKeep,
    required this.onRetake,
    required this.onModeChanged,
    required this.onLookChanged,
    required this.onPoseIdea,
    required this.onHidePoseIdea,
    required this.onHoldStart,
    required this.onHoldEnd,
    required this.onOpenSettings,
  });

  final AsyncValue<CaptureState> capture;

  /// Asks before leaving mid-quest — the close button and system back.
  final VoidCallback onLeave;

  /// Leaves straight away, when the booth never started.
  final VoidCallback onClose;
  final VoidCallback onRetry;
  final VoidCallback onCapture;

  /// "Not ready yet" — tapping during the 3-2-1 stops it.
  final VoidCallback onCancelCountdown;
  final VoidCallback onSwitchCamera;
  final VoidCallback onKeep;
  final VoidCallback onRetake;
  final ValueChanged<CaptureMode> onModeChanged;
  final ValueChanged<PhotoLook> onLookChanged;

  /// Shows a pose idea, or the next one.
  final VoidCallback onPoseIdea;
  final VoidCallback onHidePoseIdea;

  /// Boomerang / 360°: the shutter was pressed, and let go.
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  /// Opens the booth settings (countdown, clip length).
  final VoidCallback onOpenSettings;

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
          onCancelCountdown: onCancelCountdown,
          onSwitchCamera: onSwitchCamera,
          onKeep: onKeep,
          onRetake: onRetake,
          onModeChanged: onModeChanged,
          onLookChanged: onLookChanged,
          onPoseIdea: onPoseIdea,
          onHidePoseIdea: onHidePoseIdea,
          onHoldStart: onHoldStart,
          onHoldEnd: onHoldEnd,
          onOpenSettings: onOpenSettings,
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
    required this.onCancelCountdown,
    required this.onSwitchCamera,
    required this.onKeep,
    required this.onRetake,
    required this.onModeChanged,
    required this.onLookChanged,
    required this.onPoseIdea,
    required this.onHidePoseIdea,
    required this.onHoldStart,
    required this.onHoldEnd,
    required this.onOpenSettings,
  });

  final CaptureState state;
  final VoidCallback onClose;
  final VoidCallback onCapture;
  final VoidCallback onCancelCountdown;
  final VoidCallback onSwitchCamera;
  final VoidCallback onKeep;
  final VoidCallback onRetake;
  final ValueChanged<CaptureMode> onModeChanged;
  final ValueChanged<PhotoLook> onLookChanged;

  /// Shows a pose idea, or the next one.
  final VoidCallback onPoseIdea;
  final VoidCallback onHidePoseIdea;

  /// Boomerang / 360°: the shutter was pressed, and let go.
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  /// Opens the booth settings (countdown, clip length).
  final VoidCallback onOpenSettings;

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
    final old = oldWidget.state;
    final now = widget.state;
    final justCaptured =
        old.phase == CapturePhase.countdown &&
        now.phase == CapturePhase.captured;
    // Each photo of a GIF burst gets its own flash.
    final burstFlash =
        now.phase == CapturePhase.capturing &&
        now.mode == CaptureMode.gif &&
        now.burstFrame != old.burstFrame;
    if ((justCaptured && old.mode == CaptureMode.photo) || burstFlash) {
      _flashController.forward(from: 0);
      AppHaptics.shutter();
    } else if (justCaptured) {
      AppHaptics.shutter();
    } else if (now.phase == CapturePhase.countdown &&
        (old.phase != CapturePhase.countdown ||
            old.countdownValue != now.countdownValue)) {
      AppHaptics.tick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final controller = state.cameraController;
    final phase = state.phase;
    final switchDuration = AppMotion.of(context, AppMotion.short);
    final holdCapturing = phase == CapturePhase.capturing && state.mode.isHold;
    final controls = _InstructionControls(
      state: state,
      canSwitchCamera: state.canSwitchCamera,
      onCapture: widget.onCapture,
      onSwitchCamera: widget.onSwitchCamera,
      onModeChanged: widget.onModeChanged,
      onLookChanged: widget.onLookChanged,
      onPoseIdea: widget.onPoseIdea,
      onHidePoseIdea: widget.onHidePoseIdea,
      onHoldStart: widget.onHoldStart,
      onHoldEnd: widget.onHoldEnd,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null && controller.value.isInitialized)
          // The live look — the same numbers the saved photo gets.
          state.effectiveLook.isNatural
              ? _CoverPreview(controller: controller)
              : ColorFiltered(
                  colorFilter: ColorFilter.matrix(state.effectiveLook.matrix),
                  child: _CoverPreview(controller: controller),
                )
        else
          const ColoredBox(color: AppColors.camera),

        // Legibility scrims behind the top and bottom chrome.
        const CameraEdgeScrims(),

        if (phase == CapturePhase.countdown)
          BoothCountdown(
            value: state.countdownValue,
            instruction: state.currentShot.instruction,
            onCancel: widget.onCancelCountdown,
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
                  const SizedBox(width: AppSpacing.sm),
                  CameraIconButton(
                    icon: Icons.tune_rounded,
                    tooltip: 'Booth settings',
                    onPressed: phase == CapturePhase.instruction
                        ? widget.onOpenSettings
                        : null,
                  ),
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
                  // A held boomerang/360° keeps the instruction controls
                  // (and the finger on the shutter) in place.
                  key: ValueKey(
                    holdCapturing ? CapturePhase.instruction : phase,
                  ),
                  child: switch (phase) {
                    CapturePhase.instruction => controls,
                    CapturePhase.capturing when holdCapturing => controls,
                    CapturePhase.countdown => const SizedBox.shrink(),
                    CapturePhase.capturing => _CapturingControls(state: state),
                    CapturePhase.processing => ProcessingProgress(
                      progress: state.processingProgress,
                      message: switch (state.mode) {
                        CaptureMode.gif => 'Making your GIF…',
                        CaptureMode.boomerang => 'Making your boomerang…',
                        _ => 'Saving your 360°…',
                      },
                    ),
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

/// What to do for this shot, the example, a pose idea on request, how to
/// capture it (mode and look), and the shutter. Looks stay tucked away
/// until asked for, so the booth stays simple. Boomerang and 360° use a
/// press-and-hold shutter; while it's held these same controls stay on
/// screen (so the finger is never lost) and show how far along it is. See
/// CLAUDE.md §34-35, design system §24-27, §65.
class _InstructionControls extends StatefulWidget {
  const _InstructionControls({
    required this.state,
    required this.canSwitchCamera,
    required this.onCapture,
    required this.onSwitchCamera,
    required this.onModeChanged,
    required this.onLookChanged,
    required this.onPoseIdea,
    required this.onHidePoseIdea,
    required this.onHoldStart,
    required this.onHoldEnd,
  });

  final CaptureState state;
  final bool canSwitchCamera;
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;
  final ValueChanged<CaptureMode> onModeChanged;
  final ValueChanged<PhotoLook> onLookChanged;
  final VoidCallback onPoseIdea;
  final VoidCallback onHidePoseIdea;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  @override
  State<_InstructionControls> createState() => _InstructionControlsState();
}

class _InstructionControlsState extends State<_InstructionControls> {
  bool _showLooks = false;

  String get _hint {
    final state = widget.state;
    return switch (state.mode) {
      CaptureMode.photo =>
        'Tap for a ${state.countdownSeconds}-second countdown',
      CaptureMode.gif =>
        '${CaptureState.gifFrames} flashes — strike a new pose each time',
      CaptureMode.boomerang => 'Press and hold — keep moving, let go to finish',
      CaptureMode.orbit =>
        'Press and hold while you walk around them '
            '(up to ${state.clipSeconds} seconds)',
    };
  }

  String get _holdingTitle => widget.state.mode == CaptureMode.boomerang
      ? 'Keep moving!'
      : 'Walk slowly around them';

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final holding = state.phase == CapturePhase.capturing;
    final shot = state.currentShot;
    final looksAvailable = state.mode.supportsLooks;
    final idea = state.poseIdea;
    final duration = AppMotion.of(context, AppMotion.short);
    final percent = (state.captureProgress * 100).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!holding) ...[
          AnimatedSize(
            duration: duration,
            curve: AppMotion.standard,
            alignment: Alignment.bottomCenter,
            child: idea == null
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: widget.onPoseIdea,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.filmYellow,
                        minimumSize: const Size(0, AppTouch.minTarget),
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                      ),
                      icon: const Icon(
                        Icons.tips_and_updates_rounded,
                        size: AppIconSizes.md,
                      ),
                      label: const Text('Need an idea?'),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.ms),
                    child: PoseIdeaCard(
                      idea: idea,
                      onAnother: widget.onPoseIdea,
                      onClose: widget.onHidePoseIdea,
                    ),
                  ),
          ),
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
          const SizedBox(height: AppSpacing.ms),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: CaptureModeSwitch<CaptureMode>(
              modes: CaptureMode.values,
              selected: state.mode,
              labelOf: (mode) => mode.label,
              onChanged: widget.onModeChanged,
            ),
          ),
          AnimatedSize(
            duration: duration,
            curve: AppMotion.standard,
            child: _showLooks && looksAvailable
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: LookPicker(
                      selected: state.look,
                      onChanged: widget.onLookChanged,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ] else ...[
          Semantics(
            liveRegion: true,
            child: Text(
              _holdingTitle,
              textAlign: TextAlign.center,
              style: AppTypography.heading1.copyWith(color: AppColors.onCamera),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Keep holding… $percent%',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(color: AppColors.onCameraMuted),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (holding)
              const SizedBox.square(dimension: AppTouch.minTarget)
            else
              CameraIconButton(
                icon: _showLooks && looksAvailable
                    ? Icons.close_rounded
                    : Icons.auto_fix_high_rounded,
                tooltip: !looksAvailable
                    ? "Looks aren't available for 360° clips"
                    : _showLooks
                    ? 'Hide looks'
                    : 'Looks: ${state.look.label}',
                onPressed: looksAvailable
                    ? () => setState(() => _showLooks = !_showLooks)
                    : null,
              ),
            if (state.mode.isHold)
              HoldShutterButton(
                progress: state.captureProgress,
                recording: holding,
                label: state.mode == CaptureMode.boomerang
                    ? 'Boomerang'
                    : '360° clip',
                onStart: widget.onHoldStart,
                onEnd: widget.onHoldEnd,
              )
            else
              CaptureButton(
                onPressed: widget.onCapture,
                semanticLabel: state.mode == CaptureMode.gif
                    ? 'Start the GIF'
                    : 'Take the photo',
              ),
            if (widget.canSwitchCamera && !holding)
              CameraIconButton(
                icon: Icons.cameraswitch_rounded,
                tooltip: 'Flip camera',
                onPressed: widget.onSwitchCamera,
              )
            else
              const SizedBox.square(dimension: AppTouch.minTarget),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          holding
              ? 'Let go to finish'
              : looksAvailable && !state.look.isNatural
              ? '$_hint · ${state.look.label} look'
              : _hint,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: AppColors.onCameraMuted),
        ),
      ],
    );
  }
}

/// While a GIF burst is being taken: which photo we're on.
class _CapturingControls extends StatelessWidget {
  const _CapturingControls({required this.state});

  final CaptureState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            '${state.burstFrame} of ${CaptureState.gifFrames}',
            textAlign: TextAlign.center,
            style: AppTypography.heading1.copyWith(color: AppColors.onCamera),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          state.burstFrame < CaptureState.gifFrames
              ? 'New pose!'
              : 'Last one — hold it!',
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(color: AppColors.onCameraMuted),
        ),
        const SizedBox(height: AppSpacing.xxl),
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
          PrintPopIn(
            child: Container(
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
                  child: photo.kind == PhotoKind.photo
                      ? LocalPhoto(
                          path: photo.thumbnailPath,
                          semanticLabel: 'The photo you just took',
                        )
                      : ShotMedia(
                          photo: photo,
                          semanticLabel: 'What you just captured',
                        ),
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

