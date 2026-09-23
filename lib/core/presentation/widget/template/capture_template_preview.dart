import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../errors/app_failure.dart';
import '../../view_model/camera/capture_view_model.dart';
import '../molecules/app_widget_preview.dart';
import 'capture_template.dart';
import 'preview_samples.dart';

/// No live camera in the previewer, so the booth shows its dark backdrop.
CaptureState _state(CapturePhase phase, {int shot = 1}) => CaptureState(
  quest: PreviewSamples.anniversary,
  shots: PreviewSamples.shots,
  memoryId: 'm-anniversary',
  participants: [PreviewSamples.me, PreviewSamples.jamie],
  currentIndex: shot,
  phase: phase,
  countdownValue: 2,
);

Widget _capture(AsyncValue<CaptureState> capture) {
  return AppWidgetPreview(
    child: CaptureTemplate(
      capture: capture,
      onLeave: () {},
      onClose: () {},
      onRetry: () {},
      onCapture: () {},
      onSwitchCamera: () {},
      onKeep: () {},
      onRetake: () {},
    ),
  );
}

@Preview(
  name: 'Capture — instruction',
  group: 'templates',
  size: previewPhoneSize,
)
Widget captureTemplateInstructionPreview() =>
    _capture(AsyncData(_state(CapturePhase.instruction)));

@Preview(
  name: 'Capture — countdown',
  group: 'templates',
  size: previewPhoneSize,
)
Widget captureTemplateCountdownPreview() =>
    _capture(AsyncData(_state(CapturePhase.countdown)));

@Preview(
  name: 'Capture — keep or retake',
  group: 'templates',
  size: previewPhoneSize,
)
Widget captureTemplateCapturedPreview() =>
    _capture(AsyncData(_state(CapturePhase.captured, shot: 3)));

@Preview(
  name: 'Capture — no camera access',
  group: 'templates',
  size: previewPhoneSize,
)
Widget captureTemplatePermissionPreview() =>
    _capture(const AsyncError(CameraPermissionFailure(), StackTrace.empty));
