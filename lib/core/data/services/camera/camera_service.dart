import 'package:camera/camera.dart';

import '../../../errors/app_failure.dart';

/// Owns camera hardware behavior. Knows how to operate the camera; knows
/// nothing about Quests or Memories. See CLAUDE.md §17, §46.
class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _activeCameraIndex = 0;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize() async {
    _cameras = await availableCameras();
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
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw const CameraFailure();
    }
    return controller.takePicture();
  }

  Future<void> _startController(CameraDescription description) async {
    await _controller?.dispose();
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await controller.initialize();
    } on CameraException {
      throw const CameraFailure();
    }
    _controller = controller;
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}
