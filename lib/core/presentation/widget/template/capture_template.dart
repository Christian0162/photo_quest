import 'dart:math' as math;

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
import '../../../domain/memories/entities/photo_look.dart';
import '../../view_model/camera/capture_view_model.dart';
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
        const _EdgeScrims(),

        if (phase == CapturePhase.countdown)
          _Countdown(
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
                    CapturePhase.processing => _ProcessingProgress(
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

/// The 3-2-1: a big number inside a ring that drains each second, with the
/// shot's instruction kept underneath so nobody forgets what to do. Tapping
/// anywhere cancels. See CLAUDE.md §34-35, design system §28.
class _Countdown extends StatelessWidget {
  const _Countdown({
    required this.value,
    required this.instruction,
    required this.onCancel,
  });

  final int value;
  final String instruction;
  final VoidCallback onCancel;

  static const _size = 200.0;

  @override
  Widget build(BuildContext context) {
    final reduced = AppMotion.reduced(context);

    return Semantics(
      button: true,
      label: '$value. Tap to stop the countdown',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onCancel,
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              SizedBox.square(
                dimension: _size,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Keyed per beat so the ring restarts each second.
                    TweenAnimationBuilder<double>(
                      key: ValueKey(value),
                      tween: Tween(begin: 1, end: reduced ? 1 : 0),
                      duration: const Duration(seconds: 1),
                      builder: (context, t, _) => CustomPaint(
                        size: const Size.square(_size),
                        painter: _RingPainter(progress: t),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: AppMotion.of(context, AppMotion.short),
                      transitionBuilder: (child, animation) => ScaleTransition(
                        scale: Tween(begin: 1.4, end: 1.0).animate(animation),
                        child: FadeTransition(opacity: animation, child: child),
                      ),
                      child: Text(
                        '$value',
                        key: ValueKey(value),
                        style: AppTypography.countdown,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.gutter,
                ),
                child: Text(
                  instruction,
                  textAlign: TextAlign.center,
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.onCamera,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              Text(
                'Not ready? Tap anywhere to stop',
                style: AppTypography.caption.copyWith(
                  color: AppColors.onCameraMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  /// 1 = full ring, 0 = empty.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 6.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = AppColors.onCameraMuted.withValues(alpha: 0.35),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = AppColors.warmCoral,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress;
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
              _HoldShutter(
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

/// The press-and-hold shutter for boomerangs and 360° clips: capturing
/// starts the moment it's pressed and finishes when it's let go (or the
/// ring fills). The ring shows how far along it is. Screen readers get a
/// plain tap that records hands-free to the full length. See design system
/// §29, §52-53.
class _HoldShutter extends StatelessWidget {
  const _HoldShutter({
    required this.progress,
    required this.recording,
    required this.label,
    required this.onStart,
    required this.onEnd,
  });

  final double progress;
  final bool recording;
  final String label;
  final VoidCallback onStart;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    const size = AppTouch.captureButton;

    return Semantics(
      button: true,
      label: recording
          ? 'Recording $label, ${(progress * 100).round()} percent'
          : 'Press and hold to record a $label',
      onTap: recording ? null : onStart,
      excludeSemantics: true,
      child: Listener(
        onPointerDown: (_) {
          if (recording) return;
          AppHaptics.shutter();
          onStart();
        },
        onPointerUp: (_) => onEnd(),
        onPointerCancel: (_) => onEnd(),
        child: AnimatedScale(
          scale: recording ? 1.12 : 1,
          duration: AppMotion.of(context, AppMotion.short),
          curve: AppMotion.standard,
          child: SizedBox.square(
            dimension: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(size),
                  painter: _RingPainter(progress: recording ? progress : 0),
                ),
                AnimatedContainer(
                  duration: AppMotion.of(context, AppMotion.short),
                  width: recording ? size * 0.36 : size * 0.72,
                  height: recording ? size * 0.36 : size * 0.72,
                  decoration: BoxDecoration(
                    color: AppColors.warmCoral,
                    borderRadius: BorderRadius.circular(
                      recording ? AppRadius.sm / 2 : size,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Making the GIF or boomerang: a ring filling up with the percentage in
/// the middle, so it's clear how long to wait.
class _ProcessingProgress extends StatelessWidget {
  const _ProcessingProgress({required this.progress, required this.message});

  final double progress;
  final String message;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    const size = AppTouch.captureButton;

    return Semantics(
      liveRegion: true,
      label: '$message $percent percent',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: progress),
                    duration: AppMotion.of(context, AppMotion.short),
                    builder: (context, value, _) => CustomPaint(
                      size: const Size.square(size),
                      painter: _RingPainter(progress: value),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.onCamera,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(color: AppColors.onCamera),
            ),
          ],
        ),
      ),
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
          _PrintPopIn(
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

/// The just-taken photo pops out like a fresh print and settles at a small
/// tilt — a physical, photobooth moment. Static under reduced motion. See
/// design system §29-30, §49.
class _PrintPopIn extends StatelessWidget {
  const _PrintPopIn({required this.child});

  final Widget child;

  static const _restingTilt = -0.02;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.reveal,
      curve: AppMotion.emphasized,
      builder: (context, t, child) => Transform.rotate(
        angle: _restingTilt + (1 - t) * 0.08,
        child: Transform.scale(scale: 0.8 + 0.2 * t, child: child),
      ),
      child: child,
    );
  }
}
