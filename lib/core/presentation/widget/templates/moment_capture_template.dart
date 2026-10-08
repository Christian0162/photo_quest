import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_constants.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../errors/app_failure.dart';
import '../../view_model/camera/moment_capture_view_model.dart';
import '../atoms/md_camera_cover_preview.dart';
import '../atoms/md_camera_icon_button.dart';
import '../atoms/md_capture_button.dart';
import '../atoms/md_loading_indicator.dart';
import '../atoms/md_primary_button.dart';
import '../molecules/md_empty_state.dart';
import '../organisms/md_app_scaffold.dart';

/// One quick photo for "Your Day": the live camera with a shutter, then the
/// photo with a few optional words and "Add to Your Day". See CLAUDE.md §34,
/// §54A.
class MomentCaptureTemplate extends StatelessWidget {
  const MomentCaptureTemplate({
    super.key,
    required this.capture,
    required this.onClose,
    required this.onRetry,
    required this.onTakePhoto,
    required this.onSwitchCamera,
    required this.onRetake,
    required this.onAdd,
  });

  final AsyncValue<MomentCaptureState> capture;
  final VoidCallback onClose;
  final VoidCallback onRetry;
  final VoidCallback onTakePhoto;
  final VoidCallback onSwitchCamera;
  final VoidCallback onRetake;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      backgroundColor: AppColors.camera,
      safeArea: false,
      body: capture.when(
        loading: () => const MdLoadingIndicator(
          message: 'Getting the camera ready…',
          color: AppColors.onCamera,
        ),
        error: (error, stack) => SafeArea(
          child: Stack(
            children: [
              MdEmptyState.error(
                title: error is CameraPermissionFailure
                    ? 'Camera access needed'
                    : "The camera didn't start",
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
        data: (state) => state.isReviewing
            ? _Review(
                state: state,
                onClose: onClose,
                onRetake: onRetake,
                onAdd: onAdd,
              )
            : _Viewfinder(
                state: state,
                onClose: onClose,
                onTakePhoto: onTakePhoto,
                onSwitchCamera: onSwitchCamera,
              ),
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({
    required this.state,
    required this.onClose,
    required this.onTakePhoto,
    required this.onSwitchCamera,
  });

  final MomentCaptureState state;
  final VoidCallback onClose;
  final VoidCallback onTakePhoto;
  final VoidCallback onSwitchCamera;

  @override
  Widget build(BuildContext context) {
    final controller = state.controller;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (controller != null && controller.value.isInitialized)
          MdCameraCoverPreview(controller: controller)
        else
          const ColoredBox(color: AppColors.camera),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                Row(
                  children: [
                    MdCameraIconButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Close',
                      onPressed: onClose,
                    ),
                    const Spacer(),
                    if (state.canSwitchCamera)
                      MdCameraIconButton(
                        icon: Icons.cameraswitch_rounded,
                        tooltip: 'Flip the camera',
                        onPressed: state.isTaking ? null : onSwitchCamera,
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  'A moment from your day',
                  style: AppTypography.label.copyWith(
                    color: AppColors.onCamera,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                MdCaptureButton(onPressed: state.isTaking ? null : onTakePhoto),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Review extends StatefulWidget {
  const _Review({
    required this.state,
    required this.onClose,
    required this.onRetake,
    required this.onAdd,
  });

  final MomentCaptureState state;
  final VoidCallback onClose;
  final VoidCallback onRetake;
  final ValueChanged<String> onAdd;

  @override
  State<_Review> createState() => _ReviewState();
}

class _ReviewState extends State<_Review> {
  final _caption = TextEditingController();

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.state.photo!;
    final saving = widget.state.isSaving;

    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                photo,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                semanticLabel: 'The photo you just took',
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: MdCameraIconButton(
                      icon: Icons.close_rounded,
                      tooltip: 'Close',
                      onPressed: saving ? null : widget.onClose,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.md,
            AppSpacing.gutter,
            AppSpacing.md + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _caption,
                enabled: !saving,
                maxLength: AppConstants.dayMomentCaptionLimit,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Add a few words (optional)',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              MdPrimaryButton(
                label: 'Add to Your Day',
                icon: Icons.check_rounded,
                loading: saving,
                onPressed: () => widget.onAdd(_caption.text),
              ),
              const SizedBox(height: AppSpacing.sm),
              MdSecondaryButton(
                label: 'Retake',
                icon: Icons.replay_rounded,
                onPressed: saving ? null : widget.onRetake,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
