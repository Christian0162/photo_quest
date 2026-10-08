import 'package:camera/camera.dart' show CameraController;

import '../../../domain/camera/enum/capture_mode.dart';
import '../../../domain/camera/enum/capture_phase.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../domain/memories/enum/photo_look.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../../domain/quests/entities/quest_shot.dart';

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
    this.showLooks = false,
  });

  static const gifFrames = 4;

  static const boomerangMaxFrames = 16;
  static const boomerangMinFrames = 4;

  static const boomerangMaxHold = Duration(seconds: 2);

  static const clipMinimum = Duration(milliseconds: 1500);

  final Quest quest;
  final List<QuestShot> shots;
  final String memoryId;

  /// The confirmed participants doing this quest together, for on-screen
  /// context during capture.
  final List<Person> participants;
  final int currentIndex;
  final CapturePhase phase;
  final int countdownValue;

  /// The shot just taken for the current instruction, shown for Keep /
  /// Retake.
  final Photo? lastPhoto;

  /// True right after a capture attempt failed; the UI shows a friendly
  /// message and the person can simply try again.
  final bool captureFailed;

  /// The live camera to preview, or null when it isn't running (e.g. once
  /// the session is wrapping up).
  final CameraController? cameraController;
  final bool canSwitchCamera;

  final CaptureMode mode;

  final PhotoLook look;

  final String? poseIdea;

  /// GIF photos taken so far in the current burst (1-based while
  /// capturing). Each change fires the flash.
  final int burstFrame;

  final double captureProgress;

  final double processingProgress;

  final int countdownSeconds;

  final int clipSeconds;

  /// True right after the shutter was let go too soon for a boomerang or
  /// clip; the UI asks to hold a little longer. One-shot, like
  /// [captureFailed].
  final bool holdTooShort;

  final bool showLooks;

  QuestShot get currentShot => shots[currentIndex];
  bool get isLastShot => currentIndex == shots.length - 1;
  int get shotNumber => currentIndex + 1;
  int get totalShots => shots.length;

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
    bool? showLooks,
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
      showLooks: showLooks ?? this.showLooks,
    );
  }
}
