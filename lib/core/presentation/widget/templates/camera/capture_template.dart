import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../domain/camera/enum/capture_mode.dart';
import '../../../../domain/memories/enum/photo_look.dart';
import '../../../../errors/app_failure.dart';
import '../../../types/camera/capture_state.dart';
import '../../atoms/camera/md_camera_icon_button.dart';
import '../../atoms/common/md_loading_indicator.dart';
import '../../molecules/common/md_empty_state.dart';
import '../../organisms/common/md_app_scaffold.dart';
import '../../organisms/camera/md_capture_body.dart';

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
    required this.onToggleLooks,
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
  Widget build(BuildContext context) {
    return MdAppScaffold(
      backgroundColor: AppColors.camera,
      safeArea: false,
      onBackBlocked: onLeave,
      body: capture.when(
        loading: () => const MdLoadingIndicator(
          message: 'Preparing your photobooth…',
          color: AppColors.onCamera,
        ),
        error: (error, stack) => SafeArea(
          child: Stack(
            children: [
              MdEmptyState.error(
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
                child: MdCameraIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Close',
                  onPressed: onClose,
                ),
              ),
            ],
          ),
        ),
        data: (state) => MdCaptureBody(
          state: state,
          onClose: onLeave,
          onCapture: onCapture,
          onCancelCountdown: onCancelCountdown,
          onSwitchCamera: onSwitchCamera,
          onKeep: onKeep,
          onRetake: onRetake,
          onModeChanged: onModeChanged,
          onLookChanged: onLookChanged,
          onToggleLooks: onToggleLooks,
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
