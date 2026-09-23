import 'dart:async';
import 'dart:developer' as developer;

import 'package:camera/camera.dart' show CameraController;
import 'package:image/image.dart' as img;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/services/service_providers.dart';
import '../../../data/repositories/memory_repository_provider.dart';
import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/repositories/quest_repository_provider.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../../domain/quests/entities/quest_shot.dart';

part 'capture_view_model.g.dart';

enum CapturePhase { instruction, countdown, captured, finishing, complete }

class CaptureState {
  const CaptureState({
    required this.quest,
    required this.shots,
    required this.memoryId,
    required this.participants,
    required this.currentIndex,
    required this.phase,
    required this.countdownValue,
    this.lastPhoto,
    this.captureFailed = false,
    this.cameraController,
    this.canSwitchCamera = false,
  });

  final Quest quest;
  final List<QuestShot> shots;
  final String memoryId;

  /// The confirmed participants doing this quest together, for on-screen
  /// context during capture. See design system §59-60.
  final List<Person> participants;
  final int currentIndex;
  final CapturePhase phase;
  final int countdownValue;

  /// The photo just taken for the current shot, shown for Keep / Retake.
  final Photo? lastPhoto;

  /// True right after a capture attempt failed; the UI shows a friendly
  /// message and the person can simply try again. See CLAUDE.md §42.
  final bool captureFailed;

  /// The live camera to preview, or null when it isn't running (e.g. once
  /// the session is wrapping up).
  final CameraController? cameraController;
  final bool canSwitchCamera;

  QuestShot get currentShot => shots[currentIndex];
  bool get isLastShot => currentIndex == shots.length - 1;
  int get shotNumber => currentIndex + 1;
  int get totalShots => shots.length;

  CaptureState copyWith({
    int? currentIndex,
    CapturePhase? phase,
    int? countdownValue,
    Photo? lastPhoto,
    bool clearLastPhoto = false,
    bool captureFailed = false,
    CameraController? cameraController,
    bool clearCamera = false,
    bool? canSwitchCamera,
  }) {
    return CaptureState(
      quest: quest,
      shots: shots,
      memoryId: memoryId,
      participants: participants,
      currentIndex: currentIndex ?? this.currentIndex,
      phase: phase ?? this.phase,
      countdownValue: countdownValue ?? this.countdownValue,
      lastPhoto: clearLastPhoto ? null : lastPhoto ?? this.lastPhoto,
      captureFailed: captureFailed,
      cameraController: clearCamera
          ? null
          : cameraController ?? this.cameraController,
      canSwitchCamera: canSwitchCamera ?? this.canSwitchCamera,
    );
  }
}

/// Drives the photobooth capture flow: instruction -> countdown -> shutter
/// -> next shot, one shot at a time. See CLAUDE.md §34-35.
@riverpod
class CaptureViewModel extends _$CaptureViewModel {
  static const _uuid = Uuid();

  @override
  Future<CaptureState> build(String sessionId) async {
    final memoryRepo = ref.watch(memoryRepositoryProvider);
    final questRepo = ref.watch(questRepositoryProvider);
    final peopleRepo = ref.watch(peopleRepositoryProvider);
    final camera = ref.watch(cameraServiceProvider);

    final session = await memoryRepo.getSession(sessionId);
    if (session == null) {
      throw StateError('Quest session $sessionId was not found.');
    }
    final quest = await questRepo.getQuest(session.questId);
    if (quest == null) {
      throw StateError('Quest ${session.questId} was not found.');
    }
    final shots = await questRepo.getShots(quest.id);
    final memory = await memoryRepo.getMemoryForSession(sessionId);
    if (memory == null) {
      throw StateError('No memory exists yet for session $sessionId.');
    }

    final personIds = await memoryRepo.getPersonIds(memory.id);
    final participants = <Person>[];
    for (final id in personIds) {
      final person = await peopleRepo.getPerson(id);
      if (person != null) participants.add(person);
    }

    if (!camera.isInitialized) {
      await camera.initialize();
    }

    return CaptureState(
      quest: quest,
      shots: shots,
      memoryId: memory.id,
      participants: participants,
      currentIndex: 0,
      phase: CapturePhase.instruction,
      countdownValue: 3,
      cameraController: camera.controller,
      canSwitchCamera: camera.canSwitchCamera,
    );
  }

  Future<void> startCountdown() async {
    final current = state.value;
    if (current == null || current.phase != CapturePhase.instruction) return;

    for (var i = 3; i >= 1; i--) {
      state = AsyncData(
        current.copyWith(phase: CapturePhase.countdown, countdownValue: i),
      );
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    await _capture();
  }

  Future<void> _capture() async {
    final current = state.value;
    if (current == null) return;

    final camera = ref.read(cameraServiceProvider);
    final storage = ref.read(photoStorageServiceProvider);
    final imageProcessing = ref.read(imageProcessingServiceProvider);
    final memoryRepo = ref.read(memoryRepositoryProvider);

    final photoId = _uuid.v4();
    try {
      final file = await camera.capturePhoto();
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);

      final originalPath = await storage.saveOriginal(photoId, bytes);
      final thumbnailBytes = await imageProcessing.createThumbnail(bytes);
      final thumbnailPath = await storage.saveThumbnail(
        photoId,
        thumbnailBytes,
      );

      final photo = await memoryRepo.addPhoto(
        id: photoId,
        memoryId: current.memoryId,
        shotId: current.currentShot.id,
        originalPath: originalPath,
        thumbnailPath: thumbnailPath,
        position: current.currentIndex,
        width: decoded?.width ?? 0,
        height: decoded?.height ?? 0,
      );

      state = AsyncData(
        current.copyWith(phase: CapturePhase.captured, lastPhoto: photo),
      );
    } catch (error, stack) {
      // Never leave the booth stuck mid-countdown: log for developers, go
      // back to the instruction so the shot can simply be taken again.
      developer.log(
        'Photo capture failed',
        name: 'photoquest.capture',
        error: error,
        stackTrace: stack,
      );
      await storage.deletePhoto(photoId);
      state = AsyncData(
        current.copyWith(
          phase: CapturePhase.instruction,
          countdownValue: 3,
          captureFailed: true,
        ),
      );
    }
  }

  /// Discards the photo just taken for this shot and returns to its
  /// instruction. The quest can't complete without a kept photo for every
  /// shot. See CLAUDE.md §35, §37.
  Future<void> retake() async {
    final current = state.value;
    final photo = current?.lastPhoto;
    if (current == null || photo == null) return;
    if (current.phase != CapturePhase.captured) return;

    await ref.read(memoryRepositoryProvider).deletePhoto(photo.id);
    await ref.read(photoStorageServiceProvider).deletePhoto(photo.id);

    state = AsyncData(
      current.copyWith(
        phase: CapturePhase.instruction,
        countdownValue: 3,
        clearLastPhoto: true,
      ),
    );
  }

  /// Flips between front and back cameras between shots.
  Future<void> switchCamera() async {
    final current = state.value;
    if (current == null || current.phase != CapturePhase.instruction) return;
    final camera = ref.read(cameraServiceProvider);
    await camera.switchCamera();
    state = AsyncData(current.copyWith(cameraController: camera.controller));
  }

  Future<void> continueToNextShot() async {
    final current = state.value;
    if (current == null) return;

    if (current.isLastShot) {
      // Drop the preview before the camera is released under it.
      final finishing = current.copyWith(
        phase: CapturePhase.finishing,
        clearCamera: true,
      );
      state = AsyncData(finishing);
      await ref.read(memoryRepositoryProvider).completeQuestSession(sessionId);
      await ref.read(cameraServiceProvider).dispose();
      state = AsyncData(finishing.copyWith(phase: CapturePhase.complete));
      return;
    }

    state = AsyncData(
      current.copyWith(
        currentIndex: current.currentIndex + 1,
        phase: CapturePhase.instruction,
        countdownValue: 3,
        clearLastPhoto: true,
      ),
    );
  }
}
