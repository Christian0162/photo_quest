import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/day_moment_repository_provider.dart';
import '../../../data/repositories/service_providers.dart';
import '../../../errors/app_failure.dart';
import '../homes/day_moments_view_model.dart';

part 'moment_capture_view_model.g.dart';

/// What the "Your Day" camera shows: the live preview, or the photo just
/// taken waiting for a caption.
class MomentCaptureState {
  const MomentCaptureState({
    this.controller,
    this.canSwitchCamera = false,
    this.photo,
    this.isTaking = false,
    this.isSaving = false,
    this.failed = false,
  });

  final CameraController? controller;
  final bool canSwitchCamera;

  /// The photo just taken, until it is added or retaken.
  final Uint8List? photo;
  final bool isTaking;
  final bool isSaving;

  /// The last photo or save didn't work; the screen says so once.
  final bool failed;

  bool get isReviewing => photo != null;

  MomentCaptureState copyWith({
    CameraController? controller,
    Uint8List? photo,
    bool clearPhoto = false,
    bool? isTaking,
    bool? isSaving,
    bool? failed,
  }) {
    return MomentCaptureState(
      controller: controller ?? this.controller,
      canSwitchCamera: canSwitchCamera,
      photo: clearPhoto ? null : photo ?? this.photo,
      isTaking: isTaking ?? this.isTaking,
      isSaving: isSaving ?? this.isSaving,
      failed: failed ?? this.failed,
    );
  }
}

/// Takes one quick photo for "Your Day" and keeps it for 24 hours. See
/// CLAUDE.md §35, §47.
@riverpod
class MomentCapture extends _$MomentCapture {
  @override
  Future<MomentCaptureState> build() async {
    final camera = ref.watch(cameraServiceProvider);
    await camera.initialize();
    return MomentCaptureState(
      controller: camera.controller,
      canSwitchCamera: camera.canSwitchCamera,
    );
  }

  Future<void> takePhoto() async {
    final current = state.value;
    if (current == null || current.isTaking || current.isReviewing) return;
    state = AsyncData(current.copyWith(isTaking: true, failed: false));
    try {
      final file = await ref.read(cameraServiceProvider).capturePhoto();
      final bytes = await file.readAsBytes();
      state = AsyncData(current.copyWith(photo: bytes, isTaking: false));
    } on AppFailure {
      state = AsyncData(current.copyWith(isTaking: false, failed: true));
    } on Exception {
      state = AsyncData(current.copyWith(isTaking: false, failed: true));
    }
  }

  void retake() {
    final current = state.value;
    if (current == null || current.isSaving) return;
    state = AsyncData(current.copyWith(clearPhoto: true, failed: false));
  }

  Future<void> switchCamera() async {
    final current = state.value;
    if (current == null || current.isTaking || current.isReviewing) return;
    final camera = ref.read(cameraServiceProvider);
    try {
      await camera.switchCamera();
      state = AsyncData(current.copyWith(controller: camera.controller));
    } on AppFailure {
      state = AsyncData(current.copyWith(failed: true));
    }
  }

  /// Adds the photo to "Your Day". Returns whether it was saved.
  Future<bool> addToYourDay(String caption) async {
    final current = state.value;
    final photo = current?.photo;
    if (current == null || photo == null || current.isSaving) return false;
    state = AsyncData(current.copyWith(isSaving: true, failed: false));
    try {
      await ref
          .read(dayMomentRepositoryProvider)
          .addMoment(photoBytes: photo, caption: caption);
      ref.invalidate(dayMomentListProvider);
      return true;
    } on Exception {
      state = AsyncData(current.copyWith(isSaving: false, failed: true));
      return false;
    }
  }
}
