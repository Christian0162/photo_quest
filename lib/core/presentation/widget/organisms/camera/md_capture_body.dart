import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../domain/camera/enum/capture_mode.dart';
import '../../../../domain/camera/enum/capture_phase.dart';
import '../../../../domain/memories/enum/photo_look.dart';
import '../../../../utils/app_haptics.dart';
import '../../../types/camera/capture_state.dart';
import '../../atoms/camera/md_camera_edge_scrims.dart';
import '../../atoms/camera/md_camera_icon_button.dart';
import '../../atoms/common/md_loading_indicator.dart';
import '../../atoms/people/md_participant_avatar_stack.dart';
import '../../molecules/camera/md_booth_countdown.dart';
import '../../molecules/camera/md_processing_progress.dart';
import '../../molecules/common/md_step_progress.dart';
import '../../atoms/camera/md_cover_camera_preview.dart';
import '../../organisms/camera/md_instruction_controls.dart';
import '../../molecules/camera/md_capturing_controls.dart';
import '../../organisms/camera/md_review_panel.dart';

class MdCaptureBody extends StatefulWidget {
  const MdCaptureBody({
    super.key,
    required this.state,
    required this.onClose,
    required this.onCapture,
    required this.onCancelCountdown,
    required this.onSwitchCamera,
    required this.onKeep,
    required this.onRetake,
    required this.onModeChanged,
    required this.onLookChanged,
    required this.onToggleLooks,
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
  final VoidCallback onToggleLooks;

  /// Shows a pose idea, or the next one.
  final VoidCallback onPoseIdea;
  final VoidCallback onHidePoseIdea;

  /// Boomerang / 360°: the shutter was pressed, and let go.
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  /// Opens the booth settings (countdown, clip length).
  final VoidCallback onOpenSettings;

  @override
  State<MdCaptureBody> createState() => _MdCaptureBodyState();
}

class _MdCaptureBodyState extends State<MdCaptureBody>
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
  void didUpdateWidget(covariant MdCaptureBody oldWidget) {
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
    final controls = MdInstructionControls(
      state: state,
      canSwitchCamera: state.canSwitchCamera,
      onCapture: widget.onCapture,
      onSwitchCamera: widget.onSwitchCamera,
      onModeChanged: widget.onModeChanged,
      onLookChanged: widget.onLookChanged,
      onToggleLooks: widget.onToggleLooks,
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
              ? MdCoverCameraPreview(controller: controller)
              : ColorFiltered(
                  colorFilter: ColorFilter.matrix(state.effectiveLook.matrix),
                  child: MdCoverCameraPreview(controller: controller),
                )
        else
          const ColoredBox(color: AppColors.camera),

        // Legibility scrims behind the top and bottom chrome.
        const MdCameraEdgeScrims(),

        if (phase == CapturePhase.countdown)
          MdBoothCountdown(
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
                  MdCameraIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Leave quest',
                    onPressed: phase == CapturePhase.finishing
                        ? null
                        : widget.onClose,
                  ),
                  const SizedBox(width: AppSpacing.ms),
                  Expanded(
                    child: MdStepProgress(
                      label: 'Shot',
                      current: state.currentIndex,
                      total: state.totalShots,
                      onDark: true,
                    ),
                  ),
                  if (state.participants.isNotEmpty) ...[
                    const SizedBox(width: AppSpacing.ms),
                    MdParticipantAvatarStack(
                      people: state.participants,
                      radius: 14,
                      max: 3,
                      ringColor: AppColors.camera,
                    ),
                  ],
                  const SizedBox(width: AppSpacing.sm),
                  MdCameraIconButton(
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
                    CapturePhase.capturing => MdCapturingControls(state: state),
                    CapturePhase.processing => MdProcessingProgress(
                      progress: state.processingProgress,
                      message: switch (state.mode) {
                        CaptureMode.gif => 'Making your GIF…',
                        CaptureMode.boomerang => 'Making your boomerang…',
                        _ => 'Saving your 360°…',
                      },
                    ),
                    CapturePhase.captured => MdReviewPanel(
                      state: state,
                      onKeep: widget.onKeep,
                      onRetake: widget.onRetake,
                    ),
                    CapturePhase.finishing ||
                    CapturePhase.complete => const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.xxl),
                      child: MdLoadingIndicator(
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
