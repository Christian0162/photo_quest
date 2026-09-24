import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';

import '../../../../config/constant/app_camera_constants.dart';
import '../../../errors/app_failure.dart';
import 'camera_frame.dart';
import '../../../domain/camera/enum/camera_frame_format.dart';

/// Owns camera hardware behavior. Knows how to operate the camera; knows
/// nothing about Quests or Memories. See CLAUDE.md §17, §46.
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _activeCameraIndex = 0;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get canSwitchCamera => _cameras.length > 1;
  bool get isRecordingVideo => _controller?.value.isRecordingVideo ?? false;

  Future<void> initialize() async {
    try {
      _cameras = await availableCameras();
    } on CameraException catch (e) {
      throw _toFailure(e);
    }
    if (_cameras.isEmpty) {
      throw const CameraFailure("No camera is available on this device.");
    }
    await _startController(_cameras[_activeCameraIndex]);
  }

  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;
    _activeCameraIndex = (_activeCameraIndex + 1) % _cameras.length;
    await _startController(_cameras[_activeCameraIndex]);
  }

  Future<void> setFlash(FlashMode mode) async {
    final controller = _controller;
    if (controller == null) return;
    await controller.setFlashMode(mode);
  }

  Future<XFile> capturePhoto() async {
    return _guard((controller) => controller.takePicture());
  }

  /// Starts recording a silent clip (no microphone needed).
  Future<void> startVideoRecording() async {
    await _guard((controller) async {
      await controller.prepareForVideoRecording();
      await controller.startVideoRecording();
    });
  }

  /// Stops the clip started by [startVideoRecording] and returns its
  /// temporary file.
  Future<XFile> stopVideoRecording() async {
    return _guard((controller) => controller.stopVideoRecording());
  }

  /// Grabs up to [maxFrames] frames from the live stream, at most one per
  /// [spacing] — a quick burst for a boomerang, much faster than taking
  /// photos one by one. Stops early when [shouldStop] says so (e.g. the
  /// shutter was let go) or after [maxDuration]. [onFrame] hears the count
  /// after each frame.
  Future<List<CameraFrame>> captureFrames({
    int maxFrames = AppCameraConstants.burstMaxFrames,
    Duration spacing = AppCameraConstants.burstFrameSpacing,
    Duration maxDuration = AppCameraConstants.burstMaxDuration,
    bool Function()? shouldStop,
    void Function(int count)? onFrame,
  }) async {
    return _guard((controller) async {
      final rotation = controller.description.sensorOrientation;
      final frames = <CameraFrame>[];
      final done = Completer<void>();
      DateTime? last;

      void finish() {
        if (!done.isCompleted) done.complete();
      }

      await controller.startImageStream((image) {
        if (done.isCompleted) return;
        if (shouldStop?.call() ?? false) return finish();
        final now = DateTime.now();
        if (last != null && now.difference(last!) < spacing) return;
        last = now;
        final frame = _copyFrame(image, rotation);
        if (frame != null) {
          frames.add(frame);
          onFrame?.call(frames.length);
        }
        if (frames.length >= maxFrames) finish();
      });

      // Also notice a release between frames.
      final watcher = Stream<void>.periodic(
        AppCameraConstants.burstReleasePollInterval,
      )
          .listen((_) {
            if (shouldStop?.call() ?? false) finish();
          });
      await done.future.timeout(maxDuration, onTimeout: () {});
      await watcher.cancel();
      await controller.stopImageStream();
      return frames;
    });
  }

  static CameraFrame? _copyFrame(CameraImage image, int rotation) {
    final format = switch (image.format.group) {
      ImageFormatGroup.yuv420 => CameraFrameFormat.yuv420,
      ImageFormatGroup.bgra8888 => CameraFrameFormat.bgra8888,
      _ => null,
    };
    if (format == null) return null;
    return CameraFrame(
      width: image.width,
      height: image.height,
      format: format,
      rotationDegrees: rotation,
      planes: [
        for (final plane in image.planes)
          CameraFramePlane(
            // The plugin reuses these buffers for the next frame.
            bytes: Uint8List.fromList(plane.bytes),
            bytesPerRow: plane.bytesPerRow,
            bytesPerPixel: plane.bytesPerPixel,
          ),
      ],
    );
  }

  /// Runs [action] on a ready controller, turning plugin errors into
  /// friendly [AppFailure]s.
  Future<T> _guard<T>(Future<T> Function(CameraController) action) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const CameraFailure();
    }
    try {
      return await action(controller);
    } on CameraException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<void> _startController(CameraDescription description) async {
    await _controller?.dispose();
    _controller = null;
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await controller.initialize();
    } on CameraException catch (e) {
      await controller.dispose();
      throw _toFailure(e);
    }
    _controller = controller;
  }

  static AppFailure _toFailure(CameraException e) {
    return e.code.startsWith('CameraAccess')
        ? const CameraPermissionFailure()
        : const CameraFailure();
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
