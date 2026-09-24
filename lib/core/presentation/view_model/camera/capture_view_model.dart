import 'dart:async';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:camera/camera.dart' show CameraController, XFile;
import 'package:image/image.dart' as img;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../data/repositories/memory_repository_provider.dart';
import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/repositories/quest_repository_provider.dart';
import '../../../data/repositories/settings_repository_provider.dart';
import '../../../data/services/image/image_processing_service.dart'
    show AnimationResult, ProgressCallback;
import '../../../data/services/service_providers.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../domain/memories/entities/photo_look.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../../domain/quests/entities/quest_shot.dart';
import '../../../domain/quests/pose_ideas.dart';

part 'capture_view_model.g.dart';

enum CapturePhase {
  instruction,
  countdown,

  /// A GIF burst, boomerang or 360° clip is being recorded.
  capturing,

  /// Turning the burst into a GIF / boomerang, or saving the clip.
  processing,
  captured,
  finishing,
  complete,
}

/// How a shot is captured. Chosen in the booth, and remembered from shot to
/// shot until changed.
enum CaptureMode {
  photo('Photo', PhotoKind.photo),

  /// A few flashes, a new pose each time — the classic GIF booth.
  gif('GIF', PhotoKind.gif),

  /// A quick burst played forward and back.
  boomerang('Boomerang', PhotoKind.boomerang),

  /// A short clip filmed while walking around the group.
  orbit('360°', PhotoKind.video);

  const CaptureMode(this.label, this.kind);

  final String label;

  /// The [PhotoKind] this mode produces.
  final String kind;

  /// Looks are baked into photos and animations; clips stay natural.
  bool get supportsLooks => this != orbit;

  /// Boomerang and 360° record while the shutter is held down; photo and
  /// GIF use a countdown.
  bool get isHold => this == boomerang || this == orbit;
}

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
    this.mode = CaptureMode.photo,
    this.look = PhotoLook.natural,
    this.poseIdea,
    this.burstFrame = 0,
    this.captureProgress = 0,
    this.processingProgress = 0,
    this.countdownSeconds = 3,
    this.clipSeconds = 6,
    this.holdTooShort = false,
  });

  /// Photos in a GIF burst.
  static const gifFrames = 4;

  /// Most frames in a boomerang, and the fewest that make a good one.
  static const boomerangMaxFrames = 20;
  static const boomerangMinFrames = 4;

  /// Longest boomerang hold.
  static const boomerangMaxHold = Duration(seconds: 2);

  /// The shortest 360° clip worth keeping.
  static const clipMinimum = Duration(milliseconds: 1500);

  final Quest quest;
  final List<QuestShot> shots;
  final String memoryId;

  /// The confirmed participants doing this quest together, for on-screen
  /// context during capture. See design system §59-60.
  final List<Person> participants;
  final int currentIndex;
  final CapturePhase phase;
  final int countdownValue;

  /// The shot just taken for the current instruction, shown for Keep /
  /// Retake.
  final Photo? lastPhoto;

  /// True right after a capture attempt failed; the UI shows a friendly
  /// message and the person can simply try again. See CLAUDE.md §42.
  final bool captureFailed;

  /// The live camera to preview, or null when it isn't running (e.g. once
  /// the session is wrapping up).
  final CameraController? cameraController;
  final bool canSwitchCamera;

  final CaptureMode mode;

  /// The look shown live and saved into photos. Clips always use natural.
  final PhotoLook look;

  /// A pose suggestion on screen right now, or null. See CLAUDE.md §2.4.
  final String? poseIdea;

  /// GIF photos taken so far in the current burst (1-based while
  /// capturing). Each change fires the flash.
  final int burstFrame;

  /// How far through a held boomerang or 360° clip we are, 0–1.
  final double captureProgress;

  /// How far along making the GIF or boomerang is, 0–1.
  final double processingProgress;

  /// Length of the 3-2-1, from the booth settings.
  final int countdownSeconds;

  /// Longest 360° clip, from the booth settings.
  final int clipSeconds;

  /// True right after the shutter was let go too soon for a boomerang or
  /// clip; the UI asks to hold a little longer. One-shot, like
  /// [captureFailed].
  final bool holdTooShort;

  QuestShot get currentShot => shots[currentIndex];
  bool get isLastShot => currentIndex == shots.length - 1;
  int get shotNumber => currentIndex + 1;
  int get totalShots => shots.length;

  /// The look actually applied in the current [mode].
  PhotoLook get effectiveLook => mode.supportsLooks ? look : PhotoLook.natural;

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
    CaptureMode? mode,
    PhotoLook? look,
    String? poseIdea,
    bool clearPoseIdea = false,
    int? burstFrame,
    double? captureProgress,
    double? processingProgress,
    int? countdownSeconds,
    int? clipSeconds,
    bool holdTooShort = false,
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
      mode: mode ?? this.mode,
      look: look ?? this.look,
      poseIdea: clearPoseIdea ? null : poseIdea ?? this.poseIdea,
      burstFrame: burstFrame ?? this.burstFrame,
      captureProgress: captureProgress ?? this.captureProgress,
      processingProgress: processingProgress ?? this.processingProgress,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      clipSeconds: clipSeconds ?? this.clipSeconds,
      holdTooShort: holdTooShort,
    );
  }
}

/// Drives the photobooth capture flow: instruction -> countdown -> shutter
/// (photo, GIF burst, boomerang or 360° clip) -> keep or retake -> next
/// shot. See CLAUDE.md §34-35.
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

    final settings = ref.read(settingsRepositoryProvider);
    final countdownSeconds = await settings.getCountdownSeconds();
    final clipSeconds = await settings.getClipSeconds();

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
      countdownValue: countdownSeconds,
      cameraController: camera.controller,
      canSwitchCamera: camera.canSwitchCamera,
      countdownSeconds: countdownSeconds,
      clipSeconds: clipSeconds,
    );
  }

  /// Bumped by every start/cancel, so a countdown or burst that was
  /// cancelled (or replaced) stops at its next beat instead of carrying on.
  int _run = 0;

  /// Which pose idea is showing, for "Another idea".
  int _poseIndex = 0;

  /// Set when the shutter is let go during a held boomerang or clip.
  bool _holdReleased = false;

  // Choices ---------------------------------------------------------------

  /// Switches between Photo, GIF, Boomerang and 360°. Only between shots.
  void setMode(CaptureMode mode) {
    final current = state.value;
    if (current == null || current.phase != CapturePhase.instruction) return;
    _poseIndex = 0;
    state = AsyncData(
      current.copyWith(
        mode: mode,
        // Keep an open idea relevant to the new mode.
        poseIdea: current.poseIdea == null ? null : _ideas(current, mode)[0],
      ),
    );
  }

  /// Changes the look shown live and saved into the next shots.
  void setLook(PhotoLook look) {
    final current = state.value;
    if (current == null || current.phase != CapturePhase.instruction) return;
    state = AsyncData(current.copyWith(look: look));
  }

  /// Shows a pose idea, or the next one if one is already showing. Solves
  /// "what do we do?" without leaving the booth.
  void nextPoseIdea() {
    final current = state.value;
    if (current == null) return;
    final ideas = _ideas(current, current.mode);
    if (current.poseIdea != null) _poseIndex = (_poseIndex + 1) % ideas.length;
    state = AsyncData(current.copyWith(poseIdea: ideas[_poseIndex]));
  }

  void hidePoseIdea() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(clearPoseIdea: true));
  }

  /// Changes the countdown length and remembers it for next time.
  Future<void> setCountdownSeconds(int seconds) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(countdownSeconds: seconds, countdownValue: seconds),
    );
    await ref.read(settingsRepositoryProvider).setCountdownSeconds(seconds);
  }

  /// Changes the longest 360° clip and remembers it for next time.
  Future<void> setClipSeconds(int seconds) async {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(clipSeconds: seconds));
    await ref.read(settingsRepositoryProvider).setClipSeconds(seconds);
  }

  List<String> _ideas(CaptureState state, CaptureMode mode) =>
      PoseIdeas.forShot(questType: state.quest.type, kind: mode.kind);

  // Capture ---------------------------------------------------------------

  /// Photo and GIF: counts down, then captures.
  Future<void> startCountdown() async {
    final current = state.value;
    if (current == null || current.phase != CapturePhase.instruction) return;
    if (current.mode.isHold) return;

    final run = ++_run;
    for (var i = current.countdownSeconds; i >= 1; i--) {
      state = AsyncData(
        current.copyWith(
          phase: CapturePhase.countdown,
          countdownValue: i,
          clearPoseIdea: true,
        ),
      );
      await Future<void>.delayed(const Duration(seconds: 1));
      // Left the booth, or tapped to cancel, while we were waiting.
      if (!ref.mounted || run != _run) return;
    }

    final ready = state.value!;
    if (ready.mode == CaptureMode.gif) {
      await _captureGif(ready, run);
    } else {
      await _capturePhoto(ready);
    }
  }

  /// Boomerang and 360°: the shutter was pressed and is being held.
  /// Capturing runs until [endHold] or the maximum length. A screen reader
  /// can call this alone; the capture then simply runs to its maximum.
  Future<void> startHold() async {
    final current = state.value;
    if (current == null || current.phase != CapturePhase.instruction) return;
    if (!current.mode.isHold) return;

    _holdReleased = false;
    final run = ++_run;
    final ready = current.copyWith(clearPoseIdea: true);
    if (ready.mode == CaptureMode.boomerang) {
      await _captureBoomerang(ready);
    } else {
      await _captureOrbit(ready, run);
    }
  }

  /// The shutter was let go.
  void endHold() => _holdReleased = true;

  /// "Wait, not ready!" — stops the countdown and goes back to the shot's
  /// instruction without taking anything. See CLAUDE.md §35.
  void cancelCountdown() {
    final current = state.value;
    if (current == null || current.phase != CapturePhase.countdown) return;
    _run++;
    state = AsyncData(
      current.copyWith(
        phase: CapturePhase.instruction,
        countdownValue: current.countdownSeconds,
      ),
    );
  }

  Future<void> _capturePhoto(CaptureState current) async {
    final photoId = _uuid.v4();
    await _saveShot(current, photoId, () async {
      final camera = ref.read(cameraServiceProvider);
      final storage = ref.read(photoStorageServiceProvider);
      final imageProcessing = ref.read(imageProcessingServiceProvider);

      final file = await camera.capturePhoto();
      final raw = await file.readAsBytes();
      final bytes = await imageProcessing.applyLook(raw, current.effectiveLook);
      final size = _sizeOf(bytes);

      return (
        originalPath: await storage.saveOriginal(photoId, bytes),
        thumbnailPath: await storage.saveThumbnail(
          photoId,
          await imageProcessing.createThumbnail(bytes),
        ),
        width: size.$1,
        height: size.$2,
      );
    });
  }

  Future<void> _captureGif(CaptureState current, int run) async {
    final photoId = _uuid.v4();
    await _saveShot(current, photoId, () async {
      final camera = ref.read(cameraServiceProvider);
      final imageProcessing = ref.read(imageProcessingServiceProvider);

      final photos = <Uint8List>[];
      for (var i = 1; i <= CaptureState.gifFrames; i++) {
        state = AsyncData(
          current.copyWith(phase: CapturePhase.capturing, burstFrame: i),
        );
        final file = await camera.capturePhoto();
        photos.add(await file.readAsBytes());
        if (!ref.mounted || run != _run) throw const _Abandoned();
        // A beat to change pose before the next flash.
        if (i < CaptureState.gifFrames) {
          await Future<void>.delayed(const Duration(milliseconds: 700));
        }
      }

      state = AsyncData(current.copyWith(phase: CapturePhase.processing));
      final gif = await imageProcessing.createGif(
        photos,
        look: current.effectiveLook,
        onProgress: _reportProcessing(current),
      );
      return _saveAnimation(photoId, gif);
    });
  }

  /// Updates the processing percentage, if we're still in the booth.
  ProgressCallback _reportProcessing(CaptureState current) {
    return (progress) {
      if (!ref.mounted || state.value?.phase != CapturePhase.processing) {
        return;
      }
      state = AsyncData(
        current.copyWith(
          phase: CapturePhase.processing,
          processingProgress: progress,
        ),
      );
    };
  }

  Future<void> _captureBoomerang(CaptureState current) async {
    final photoId = _uuid.v4();
    await _saveShot(current, photoId, () async {
      final camera = ref.read(cameraServiceProvider);
      final imageProcessing = ref.read(imageProcessingServiceProvider);

      state = AsyncData(
        current.copyWith(phase: CapturePhase.capturing, captureProgress: 0),
      );
      final frames = await camera.captureFrames(
        maxFrames: CaptureState.boomerangMaxFrames,
        maxDuration: CaptureState.boomerangMaxHold,
        shouldStop: () => _holdReleased || !ref.mounted,
        onFrame: (count) {
          if (!ref.mounted) return;
          state = AsyncData(
            current.copyWith(
              phase: CapturePhase.capturing,
              captureProgress: count / CaptureState.boomerangMaxFrames,
            ),
          );
        },
      );
      if (!ref.mounted) throw const _Abandoned();
      if (frames.length < CaptureState.boomerangMinFrames) {
        throw const _TooShort();
      }

      state = AsyncData(
        current.copyWith(
          phase: CapturePhase.processing,
          captureProgress: 1,
          processingProgress: 0,
        ),
      );
      final boomerang = await imageProcessing.createBoomerang(
        frames,
        look: current.effectiveLook,
        onProgress: _reportProcessing(current),
      );
      return _saveAnimation(photoId, boomerang);
    });
  }

  Future<void> _captureOrbit(CaptureState current, int run) async {
    final photoId = _uuid.v4();
    await _saveShot(current, photoId, () async {
      final camera = ref.read(cameraServiceProvider);
      final storage = ref.read(photoStorageServiceProvider);
      final imageProcessing = ref.read(imageProcessingServiceProvider);

      state = AsyncData(
        current.copyWith(phase: CapturePhase.capturing, captureProgress: 0),
      );
      // A still first, for cards and the keepsake.
      final posterFile = await camera.capturePhoto();
      final posterBytes = await posterFile.readAsBytes();
      final size = _sizeOf(posterBytes);

      // Let go while the still was being taken: nothing to film.
      if (_holdReleased) throw const _TooShort();
      await camera.startVideoRecording();
      final started = DateTime.now();
      final maxLength = Duration(seconds: current.clipSeconds);
      const tick = Duration(milliseconds: 100);
      var elapsed = Duration.zero;
      while (elapsed < maxLength && !_holdReleased) {
        await Future<void>.delayed(tick);
        if (!ref.mounted || run != _run) break;
        elapsed = DateTime.now().difference(started);
        state = AsyncData(
          current.copyWith(
            phase: CapturePhase.capturing,
            captureProgress: (elapsed.inMilliseconds / maxLength.inMilliseconds)
                .clamp(0, 1),
          ),
        );
      }
      final XFile clip;
      try {
        clip = await camera.stopVideoRecording();
      } catch (_) {
        // Android can't finish a clip stopped almost as soon as it started;
        // that's a short hold, not a failure.
        if (elapsed < CaptureState.clipMinimum) throw const _TooShort();
        rethrow;
      }
      if (!ref.mounted || run != _run) throw const _Abandoned();
      if (elapsed < CaptureState.clipMinimum) {
        await storage.discardTemporary(clip.path);
        throw const _TooShort();
      }

      state = AsyncData(
        current.copyWith(
          phase: CapturePhase.processing,
          captureProgress: 1,
          processingProgress: 0.5,
        ),
      );
      return (
        originalPath: await storage.saveVideo(photoId, clip.path),
        thumbnailPath: await storage.saveThumbnail(
          photoId,
          await imageProcessing.createThumbnail(posterBytes),
        ),
        width: size.$1,
        height: size.$2,
      );
    });
  }

  Future<_SavedFiles> _saveAnimation(
    String photoId,
    AnimationResult? animation,
  ) async {
    if (animation == null) throw StateError('No frames could be read.');
    final storage = ref.read(photoStorageServiceProvider);
    return (
      originalPath: await storage.saveAnimation(photoId, animation.gif),
      thumbnailPath: await storage.saveThumbnail(photoId, animation.poster),
      width: animation.width,
      height: animation.height,
    );
  }

  /// Runs [capture] for the current shot and records the result, or — on
  /// any failure — cleans up and goes back to the instruction so the shot
  /// can simply be taken again. Never leaves the booth stuck.
  Future<void> _saveShot(
    CaptureState current,
    String photoId,
    Future<_SavedFiles> Function() capture,
  ) async {
    final storage = ref.read(photoStorageServiceProvider);
    try {
      final files = await capture();
      final photo = await ref
          .read(memoryRepositoryProvider)
          .addPhoto(
            id: photoId,
            memoryId: current.memoryId,
            shotId: current.currentShot.id,
            originalPath: files.originalPath,
            thumbnailPath: files.thumbnailPath,
            position: current.currentIndex,
            width: files.width,
            height: files.height,
            kind: current.mode.kind,
          );
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(
          phase: CapturePhase.captured,
          lastPhoto: photo,
          burstFrame: 0,
          captureProgress: 0,
          processingProgress: 0,
        ),
      );
    } on _Abandoned {
      await storage.deletePhoto(photoId);
    } on _TooShort {
      await storage.deletePhoto(photoId);
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(
          phase: CapturePhase.instruction,
          holdTooShort: true,
          captureProgress: 0,
        ),
      );
    } catch (error, stack) {
      developer.log(
        'Capture failed (${current.mode.name})',
        name: 'photoquest.capture',
        error: error,
        stackTrace: stack,
      );
      await storage.deletePhoto(photoId);
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(
          phase: CapturePhase.instruction,
          countdownValue: current.countdownSeconds,
          captureFailed: true,
          burstFrame: 0,
          captureProgress: 0,
          processingProgress: 0,
        ),
      );
    }
  }

  static (int, int) _sizeOf(Uint8List bytes) {
    try {
      final decoded = img.decodeImage(bytes);
      return (decoded?.width ?? 0, decoded?.height ?? 0);
    } catch (_) {
      return (0, 0);
    }
  }

  /// Discards the shot just taken and returns to its instruction. The
  /// quest can't complete without a kept shot for every instruction. See
  /// CLAUDE.md §35, §37.
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
        countdownValue: current.countdownSeconds,
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
        countdownValue: current.countdownSeconds,
        clearLastPhoto: true,
        clearPoseIdea: true,
      ),
    );
  }
}

typedef _SavedFiles = ({
  String originalPath,
  String thumbnailPath,
  int width,
  int height,
});

/// The person left (or cancelled) mid-capture; clean up quietly.
class _Abandoned implements Exception {
  const _Abandoned();
}

/// The shutter was let go before a boomerang or clip was long enough.
class _TooShort implements Exception {
  const _TooShort();
}
