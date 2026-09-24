import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/memories/entities/photo_look.dart';
import '../../../errors/app_failure.dart';
import '../../view_model/camera/capture_view_model.dart';
import '../molecules/app_widget_preview.dart';
import 'capture_template.dart';
import 'preview_samples.dart';

/// No live camera in the previewer, so the booth shows its dark backdrop.
CaptureState _state(
  CapturePhase phase, {
  int shot = 1,
  CaptureMode mode = CaptureMode.photo,
  PhotoLook look = PhotoLook.natural,
  String? poseIdea,
  int burstFrame = 0,
  double captureProgress = 0,
  double processingProgress = 0,
}) => CaptureState(
  quest: PreviewSamples.anniversary,
  shots: PreviewSamples.shots,
  memoryId: 'm-anniversary',
  participants: [PreviewSamples.me, PreviewSamples.jamie],
  currentIndex: shot,
  phase: phase,
  countdownValue: 2,
  mode: mode,
  look: look,
  poseIdea: poseIdea,
  burstFrame: burstFrame,
  captureProgress: captureProgress,
  processingProgress: processingProgress,
);

Widget _capture(AsyncValue<CaptureState> capture) {
  return AppWidgetPreview(
    child: CaptureTemplate(
      capture: capture,
      onLeave: () {},
      onClose: () {},
      onRetry: () {},
      onCapture: () {},
      onCancelCountdown: () {},
      onSwitchCamera: () {},
      onKeep: () {},
      onRetake: () {},
      onModeChanged: (_) {},
      onLookChanged: (_) {},
      onPoseIdea: () {},
      onHidePoseIdea: () {},
      onHoldStart: () {},
      onHoldEnd: () {},
      onOpenSettings: () {},
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
  name: 'Capture — pose idea, Film look',
  group: 'templates',
  size: previewPhoneSize,
)
Widget captureTemplatePoseIdeaPreview() => _capture(
  AsyncData(
    _state(
      CapturePhase.instruction,
      look: PhotoLook.film,
      poseIdea: 'Forehead to forehead',
    ),
  ),
);

@Preview(
  name: 'Capture — countdown',
  group: 'templates',
  size: previewPhoneSize,
)
Widget captureTemplateCountdownPreview() =>
    _capture(AsyncData(_state(CapturePhase.countdown)));

@Preview(
  name: 'Capture — GIF burst',
  group: 'templates',
  size: previewPhoneSize,
)
Widget captureTemplateGifPreview() => _capture(
  AsyncData(
    _state(CapturePhase.capturing, mode: CaptureMode.gif, burstFrame: 2),
  ),
);

@Preview(
  name: 'Capture — 360° recording',
  group: 'templates',
  size: previewPhoneSize,
)
Widget captureTemplateOrbitPreview() => _capture(
  AsyncData(
    _state(
      CapturePhase.capturing,
      mode: CaptureMode.orbit,
      captureProgress: 0.4,
    ),
  ),
);

@Preview(
  name: 'Capture — making a boomerang',
  group: 'templates',
  size: previewPhoneSize,
)
Widget captureTemplateProcessingPreview() => _capture(
  AsyncData(
    _state(
      CapturePhase.processing,
      mode: CaptureMode.boomerang,
      processingProgress: 0.45,
    ),
  ),
);

@Preview(
  name: 'Capture — holding for a boomerang',
  group: 'templates',
  size: previewPhoneSize,
)
Widget captureTemplateBoomerangHoldPreview() => _capture(
  AsyncData(
    _state(
      CapturePhase.capturing,
      mode: CaptureMode.boomerang,
      captureProgress: 0.6,
    ),
  ),
);

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
