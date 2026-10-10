import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/camera/enum/capture_mode.dart';
import '../../../../domain/camera/enum/capture_phase.dart';
import '../../../../domain/memories/enum/photo_look.dart';
import '../../../types/camera/capture_state.dart';
import '../../atoms/camera/md_camera_icon_button.dart';
import '../../atoms/camera/md_capture_button.dart';
import '../../atoms/camera/md_hold_shutter_button.dart';
import '../../atoms/common/md_local_photo.dart';
import '../../molecules/camera/md_capture_mode_switch.dart';
import '../../molecules/camera/md_look_picker.dart';
import '../../molecules/quests/md_pose_idea_card.dart';

/// What to do for this shot, the example, a pose idea on request, how to
/// capture it (mode and look), and the shutter. Looks stay tucked away
/// until asked for, so the booth stays simple. Boomerang and 360° use a
/// press-and-hold shutter; while it's held these same controls stay on
/// screen (so the finger is never lost) and show how far along it is.
class MdInstructionControls extends StatelessWidget {
  const MdInstructionControls({
    super.key,
    required this.state,
    required this.canSwitchCamera,
    required this.onCapture,
    required this.onSwitchCamera,
    required this.onModeChanged,
    required this.onLookChanged,
    required this.onToggleLooks,
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
  final VoidCallback onToggleLooks;
  final VoidCallback onPoseIdea;
  final VoidCallback onHidePoseIdea;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  String get _hint {
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

  String get _holdingTitle => state.mode == CaptureMode.boomerang
      ? 'Keep moving!'
      : 'Walk slowly around them';

  @override
  Widget build(BuildContext context) {
    final holding = state.phase == CapturePhase.capturing;
    final shot = state.currentShot;
    final showLooks = state.showLooks;
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
                      onPressed: onPoseIdea,
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
                    child: MdPoseIdeaCard(
                      idea: idea,
                      onAnother: onPoseIdea,
                      onClose: onHidePoseIdea,
                    ),
                  ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (shot.exampleImagePath != null) ...[
                // A subtle example, never stronger than the real people in
                // the preview.
                Container(
                  width: 64,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.base),
                    border: Border.all(color: AppColors.onCamera, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: MdLocalPhoto(
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
            child: MdCaptureModeSwitch<CaptureMode>(
              modes: CaptureMode.values,
              selected: state.mode,
              labelOf: (mode) => mode.label,
              onChanged: onModeChanged,
            ),
          ),
          AnimatedSize(
            duration: duration,
            curve: AppMotion.standard,
            child: showLooks && looksAvailable
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: MdLookPicker(
                      selected: state.look,
                      onChanged: onLookChanged,
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
              MdCameraIconButton(
                icon: showLooks && looksAvailable
                    ? Icons.close_rounded
                    : Icons.auto_fix_high_rounded,
                tooltip: !looksAvailable
                    ? "Looks aren't available for 360° clips"
                    : showLooks
                    ? 'Hide looks'
                    : 'Looks: ${state.look.label}',
                onPressed: looksAvailable ? onToggleLooks : null,
              ),
            if (state.mode.isHold)
              MdHoldShutterButton(
                progress: state.captureProgress,
                recording: holding,
                label: state.mode == CaptureMode.boomerang
                    ? 'Boomerang'
                    : '360° clip',
                onStart: onHoldStart,
                onEnd: onHoldEnd,
              )
            else
              MdCaptureButton(
                onPressed: onCapture,
                semanticLabel: state.mode == CaptureMode.gif
                    ? 'Start the GIF'
                    : 'Take the photo',
              ),
            if (canSwitchCamera && !holding)
              MdCameraIconButton(
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
