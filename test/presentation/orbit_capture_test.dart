import 'dart:typed_data';

import 'package:camera/camera.dart' show XFile;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:photoquest/core/data/repositories/service_providers.dart';
import 'package:photoquest/core/data/services/camera/camera_service.dart';
import 'package:photoquest/core/data/services/storage/photo_storage_service.dart';
import 'package:photoquest/core/domain/camera/enum/capture_mode.dart';
import 'package:photoquest/core/domain/camera/enum/capture_phase.dart';
import 'package:photoquest/core/errors/app_failure.dart';
import 'package:photoquest/core/presentation/types/camera/capture_state.dart';
import 'package:photoquest/core/presentation/view_model/camera/capture_view_model.dart';
import 'package:photoquest/core/presentation/widget/templates/preview_samples.dart';

/// A camera whose clip can't be finished when it's stopped right away —
/// what Android does with an empty recording.
class _QuickStopCamera extends CameraService {
  bool recording = false;

  @override
  Future<XFile> capturePhoto() async => XFile.fromData(
    Uint8List.fromList(img.encodeJpg(img.Image(width: 4, height: 4))),
  );

  @override
  Future<void> startVideoRecording() async => recording = true;

  @override
  Future<XFile> stopVideoRecording() async {
    recording = false;
    throw const CameraFailure();
  }
}

class _NoFiles extends PhotoStorageService {
  @override
  Future<void> deletePhoto(String photoId) async {}

  @override
  Future<void> discardTemporary(String path) async {}
}

class _OrbitBooth extends CaptureViewModel {
  @override
  Future<CaptureState> build(String sessionId) async => CaptureState(
    quest: PreviewSamples.anniversary,
    shots: PreviewSamples.shots,
    memoryId: 'm',
    participants: const [],
    currentIndex: 0,
    phase: CapturePhase.instruction,
    countdownValue: 3,
    mode: CaptureMode.orbit,
  );
}

void main() {
  test(
    'letting go of a 360° right away asks to hold longer, not "failed"',
    () async {
      final camera = _QuickStopCamera();
      final container = ProviderContainer(
        overrides: [
          cameraServiceProvider.overrideWithValue(camera),
          photoStorageServiceProvider.overrideWithValue(_NoFiles()),
          captureViewModelProvider('s').overrideWith(_OrbitBooth.new),
        ],
      );
      addTearDown(container.dispose);
      container.listen(captureViewModelProvider('s'), (_, _) {});
      await container.read(captureViewModelProvider('s').future);
      final booth = container.read(captureViewModelProvider('s').notifier);

      final capture = booth.startHold();
      booth.endHold(); // A tap, not a hold.
      await capture;

      final state = container.read(captureViewModelProvider('s')).value!;
      expect(state.phase, CapturePhase.instruction);
      expect(state.holdTooShort, isTrue);
      expect(state.captureFailed, isFalse);
      expect(camera.recording, isFalse);
    },
  );
}
