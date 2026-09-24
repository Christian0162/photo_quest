import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/domain/memories/entities/photo.dart';
import 'package:photoquest/core/domain/memories/entities/photo_look.dart';
import 'package:photoquest/core/domain/quests/entities/quest.dart';
import 'package:photoquest/core/domain/quests/entities/quest_shot.dart';
import 'package:photoquest/core/domain/quests/pose_ideas.dart';
import 'package:photoquest/core/presentation/view_model/camera/capture_view_model.dart';
import 'package:photoquest/core/presentation/view_model/memories/keepsake_view_model.dart';

final _now = DateTime(2026, 9, 17);

class _ReadyBooth extends CaptureViewModel {
  _ReadyBooth([this.phase = CapturePhase.instruction]);

  final CapturePhase phase;

  @override
  Future<CaptureState> build(String sessionId) async => CaptureState(
    quest: Quest(
      id: 'q',
      title: 'Anniversary',
      category: 'For Us',
      type: 'pair',
      createdAt: _now,
      updatedAt: _now,
    ),
    shots: const [
      QuestShot(
        id: 's1',
        questId: 'q',
        position: 0,
        instruction: 'Smile',
        shotType: 'group',
      ),
    ],
    memoryId: 'm',
    participants: const [],
    currentIndex: 0,
    phase: phase,
    countdownValue: 3,
  );
}

class _Keepsake extends KeepsakeViewModel {
  @override
  Future<KeepsakeDesign> build(String memoryId) async => KeepsakeDesign(
    memoryId: memoryId,
    title: 'Anniversary',
    capturedAt: _now,
    shots: const [],
  );
}

void main() {
  group('pose ideas', () {
    test('ideas for the capture mode come first', () {
      final ideas = PoseIdeas.forShot(
        questType: 'pair',
        kind: PhotoKind.boomerang,
      );
      expect(ideas.first, contains('Toss'));
      expect(ideas, contains('Forehead to forehead'));
    });

    test('every quest type and kind has ideas', () {
      for (final type in ['solo', 'pair', 'group']) {
        for (final kind in PhotoKind.all) {
          expect(PoseIdeas.forShot(questType: type, kind: kind), isNotEmpty);
        }
      }
    });
  });

  group('photobooth choices', () {
    late ProviderContainer container;
    late CaptureViewModel booth;

    Future<CaptureState> ready([
      CapturePhase phase = CapturePhase.instruction,
    ]) async {
      container = ProviderContainer(
        overrides: [
          captureViewModelProvider('s').overrideWith(() => _ReadyBooth(phase)),
        ],
      );
      addTearDown(container.dispose);
      container.listen(captureViewModelProvider('s'), (_, _) {});
      booth = container.read(captureViewModelProvider('s').notifier);
      return container.read(captureViewModelProvider('s').future);
    }

    CaptureState state() =>
        container.read(captureViewModelProvider('s')).value!;

    test('mode and look can be changed before a shot', () async {
      await ready();
      booth
        ..setMode(CaptureMode.gif)
        ..setLook(PhotoLook.mono);
      expect(state().mode, CaptureMode.gif);
      expect(state().effectiveLook, PhotoLook.mono);
    });

    test('360° clips always stay natural', () async {
      await ready();
      booth
        ..setLook(PhotoLook.golden)
        ..setMode(CaptureMode.orbit);
      expect(state().look, PhotoLook.golden);
      expect(state().effectiveLook, PhotoLook.natural);
    });

    test('nothing changes mid-shot', () async {
      await ready(CapturePhase.captured);
      booth
        ..setMode(CaptureMode.boomerang)
        ..setLook(PhotoLook.dreamy);
      expect(state().mode, CaptureMode.photo);
      expect(state().look, PhotoLook.natural);
    });

    test('"Another idea" moves through the ideas, and can be hidden', () async {
      await ready();
      booth.nextPoseIdea();
      final first = state().poseIdea;
      expect(first, isNotNull);

      booth.nextPoseIdea();
      expect(state().poseIdea, isNot(first));

      booth.hidePoseIdea();
      expect(state().poseIdea, isNull);
    });
  });

  group('keepsake designer', () {
    late ProviderContainer container;
    late KeepsakeViewModel designer;

    setUp(() async {
      container = ProviderContainer(
        overrides: [keepsakeViewModelProvider('m').overrideWith(_Keepsake.new)],
      );
      container.listen(keepsakeViewModelProvider('m'), (_, _) {});
      designer = container.read(keepsakeViewModelProvider('m').notifier);
      await container.read(keepsakeViewModelProvider('m').future);
    });
    tearDown(() => container.dispose());

    KeepsakeDesign design() =>
        container.read(keepsakeViewModelProvider('m')).value!;

    test('layout and paper can be changed', () {
      designer
        ..setLayout(KeepsakeLayout.grid)
        ..setFrame(KeepsakeFrame.film);
      expect(design().layout, KeepsakeLayout.grid);
      expect(design().frame, KeepsakeFrame.film);
    });

    test('a new sticker is added and selected', () {
      designer.addSticker(StickerType.heart);
      expect(design().stickers, hasLength(1));
      expect(design().selectedStickerId, design().stickers.single.id);
    });

    test('stickers stay on the print and within a sensible size', () {
      designer.addSticker(StickerType.star);
      final id = design().stickers.single.id;
      designer.transformSticker(id, x: 1.4, y: -0.3, scale: 9, rotation: 1);

      final sticker = design().stickers.single;
      expect((sticker.x, sticker.y), (1.0, 0.0));
      expect(sticker.scale, 3);
      expect(sticker.rotation, 1);
    });

    test('removing the selected sticker clears the selection', () {
      designer.addSticker(StickerType.sun);
      designer.removeSticker(design().stickers.single.id);
      expect(design().stickers, isEmpty);
      expect(design().selectedStickerId, isNull);
    });

    test('there is a limit, so the print stays about the people', () {
      for (var i = 0; i < KeepsakeDesign.maxStickers + 3; i++) {
        designer.addSticker(StickerType.heart);
      }
      expect(design().stickers, hasLength(KeepsakeDesign.maxStickers));
      expect(design().canAddSticker, isFalse);
    });
  });
}
