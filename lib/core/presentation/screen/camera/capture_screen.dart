import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../view_model/camera/capture_view_model.dart';
import '../../widget/molecules/confirmation_dialog.dart';
import '../../widget/organisms/app_scaffold.dart';
import '../../widget/organisms/booth_settings_sheet.dart';
import '../../widget/templates/capture_template.dart';
import '../../../domain/camera/enum/capture_phase.dart';

/// The photobooth. Wires [CaptureViewModel], the leave dialog and
/// navigation into [CaptureTemplate]. See CLAUDE.md §34-35.
class CaptureScreen extends ConsumerWidget {
  const CaptureScreen({super.key, required this.sessionId});

  final String sessionId;

  Future<void> _confirmLeave(BuildContext context) async {
    final leave = await showConfirmationDialog(
      context,
      title: 'Leave this quest?',
      message: "The photos you've taken so far won't be kept.",
      confirmLabel: 'Leave',
      cancelLabel: 'Stay',
    );
    if (leave && context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = captureViewModelProvider(sessionId);

    ref.listen(provider, (previous, next) {
      final state = next.value;
      if (state?.phase == CapturePhase.complete) {
        context.pushReplacement(AppRoutes.memoryRevealPath(sessionId));
      }
      if (state?.holdTooShort ?? false) {
        showAppMessage(
          context,
          "Hold the button a little longer — let go when you're done.",
        );
      }
      if (state?.captureFailed ?? false) {
        showAppMessage(
          context,
          "That one didn't save. Let's try the shot again.",
        );
      }
    });

    final viewModel = ref.read(provider.notifier);

    return CaptureTemplate(
      capture: ref.watch(provider),
      onLeave: () => _confirmLeave(context),
      onClose: () => context.pop(),
      onRetry: () => ref.invalidate(provider),
      onCapture: viewModel.startCountdown,
      onCancelCountdown: viewModel.cancelCountdown,
      onSwitchCamera: viewModel.switchCamera,
      onKeep: viewModel.continueToNextShot,
      onRetake: viewModel.retake,
      onModeChanged: viewModel.setMode,
      onLookChanged: viewModel.setLook,
      onPoseIdea: viewModel.nextPoseIdea,
      onHidePoseIdea: viewModel.hidePoseIdea,
      onHoldStart: viewModel.startHold,
      onHoldEnd: viewModel.endHold,
      onOpenSettings: () {
        final current = ref.read(provider).value;
        if (current == null) return;
        showBoothSettingsSheet(
          context,
          countdownSeconds: current.countdownSeconds,
          countdownChoices: SettingsRepository.countdownChoices,
          onCountdownChanged: viewModel.setCountdownSeconds,
          clipSeconds: current.clipSeconds,
          clipChoices: SettingsRepository.clipChoices,
          onClipChanged: viewModel.setClipSeconds,
        );
      },
    );
  }
}
