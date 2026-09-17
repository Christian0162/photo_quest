import 'dart:async';

import 'package:image/image.dart' as img;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/services/service_providers.dart';
import '../../../data/repositories/memory_repository_provider.dart';
import '../../../data/repositories/quest_repository_provider.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../../domain/quests/entities/quest_shot.dart';

part 'capture_view_model.g.dart';

enum CapturePhase { instruction, countdown, captured, finishing, complete }

class CaptureState {
  const CaptureState({
    required this.quest,
    required this.shots,
    required this.memoryId,
    required this.currentIndex,
    required this.phase,
    required this.countdownValue,
  });

  final Quest quest;
  final List<QuestShot> shots;
  final String memoryId;
  final int currentIndex;
  final CapturePhase phase;
  final int countdownValue;

  QuestShot get currentShot => shots[currentIndex];
  bool get isLastShot => currentIndex == shots.length - 1;
  int get shotNumber => currentIndex + 1;
  int get totalShots => shots.length;

  CaptureState copyWith({
    int? currentIndex,
    CapturePhase? phase,
    int? countdownValue,
  }) {
    return CaptureState(
      quest: quest,
      shots: shots,
      memoryId: memoryId,
      currentIndex: currentIndex ?? this.currentIndex,
      phase: phase ?? this.phase,
      countdownValue: countdownValue ?? this.countdownValue,
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

    if (!camera.isInitialized) {
      await camera.initialize();
    }

    return CaptureState(
      quest: quest,
      shots: shots,
      memoryId: memory.id,
      currentIndex: 0,
      phase: CapturePhase.instruction,
      countdownValue: 3,
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

    final file = await camera.capturePhoto();
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    final photoId = _uuid.v4();

    final originalPath = await storage.saveOriginal(photoId, bytes);
    final thumbnailBytes = await imageProcessing.createThumbnail(bytes);
    final thumbnailPath = await storage.saveThumbnail(photoId, thumbnailBytes);

    await memoryRepo.addPhoto(
      id: photoId,
      memoryId: current.memoryId,
      shotId: current.currentShot.id,
      originalPath: originalPath,
      thumbnailPath: thumbnailPath,
      position: current.currentIndex,
      width: decoded?.width ?? 0,
      height: decoded?.height ?? 0,
    );

    state = AsyncData(current.copyWith(phase: CapturePhase.captured));
  }

  Future<void> continueToNextShot() async {
    final current = state.value;
    if (current == null) return;

    if (current.isLastShot) {
      state = AsyncData(current.copyWith(phase: CapturePhase.finishing));
      await ref.read(memoryRepositoryProvider).completeQuestSession(sessionId);
      await ref.read(cameraServiceProvider).dispose();
      state = AsyncData(current.copyWith(phase: CapturePhase.complete));
      return;
    }

    state = AsyncData(
      current.copyWith(
        currentIndex: current.currentIndex + 1,
        phase: CapturePhase.instruction,
        countdownValue: 3,
      ),
    );
  }
}
