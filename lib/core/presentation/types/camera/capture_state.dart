import 'package:camera/camera.dart' show CameraController;
import '../../../domain/memories/entities/photo.dart';
import '../../../domain/memories/enum/photo_look.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../../domain/quests/entities/quest_shot.dart';
import '../../../domain/camera/enum/capture_phase.dart';
import '../../../domain/camera/enum/capture_mode.dart';

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
