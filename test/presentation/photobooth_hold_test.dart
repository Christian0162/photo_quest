import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/data/database/app_database.dart'
    show AppDatabase;
import 'package:photoquest/core/data/database/database_providers.dart';
import 'package:photoquest/core/data/repositories/memory_repository.dart';
import 'package:photoquest/core/data/repositories/settings_repository.dart';
import 'package:photoquest/core/data/repositories/settings_repository_provider.dart';
import 'package:photoquest/core/domain/camera/enum/capture_mode.dart';
import 'package:photoquest/core/domain/camera/enum/capture_phase.dart';
import 'package:photoquest/core/domain/memories/enum/keepsake_frame.dart';
import 'package:photoquest/core/domain/memories/enum/keepsake_layout.dart';
import 'package:photoquest/core/presentation/types/camera/capture_state.dart';
import 'package:photoquest/core/presentation/view_model/camera/capture_view_model.dart';
import 'package:photoquest/core/presentation/widget/molecules/md_app_widget_preview.dart';
import 'package:photoquest/core/presentation/widget/templates/capture_template.dart';
import 'package:photoquest/core/presentation/widget/templates/preview_samples.dart';

CaptureState _booth(
  CapturePhase phase, {
  CaptureMode mode = CaptureMode.boomerang,
  double captureProgress = 0,
  double processingProgress = 0,
}) => CaptureState(
  quest: PreviewSamples.anniversary,
  shots: PreviewSamples.shots,
  memoryId: 'm',
  participants: const [],
  currentIndex: 0,
  phase: phase,
  countdownValue: 3,
  mode: mode,
  captureProgress: captureProgress,
  processingProgress: processingProgress,
);

Widget _template(
  CaptureState state, {
  VoidCallback? onHoldStart,
  VoidCallback? onHoldEnd,
}) {
  return MdAppWidgetPreview(
    child: CaptureTemplate(
      capture: AsyncData(state),
      onLeave: () {},
      onClose: () {},
      onRetry: () {},
      onCapture: () {},
      onCancelCountdown: () {},
      onSwitchCamera: () {},
      onKeep: () {},
      onRetake: () {},
      onModeChanged: (_) {},
      onLookChanged: (_) {},
      onPoseIdea: () {},
      onHidePoseIdea: () {},
      onHoldStart: onHoldStart ?? () {},
      onHoldEnd: onHoldEnd ?? () {},
      onOpenSettings: () {},
    ),
  );
}

class _ReadyBooth extends CaptureViewModel {
  _ReadyBooth(this.mode);

  final CaptureMode mode;

  @override
  Future<CaptureState> build(String sessionId) async =>
      _booth(CapturePhase.instruction, mode: mode);
}

void main() {
  group('press and hold', () {
    testWidgets('boomerang records while the shutter is held', (tester) async {
      var started = 0;
      var ended = 0;
      await tester.pumpWidget(
        _template(
          _booth(CapturePhase.instruction),
          onHoldStart: () => started++,
          onHoldEnd: () => ended++,
        ),
      );

      final shutter = find.bySemanticsLabel(
        'Press and hold to record a Boomerang',
      );
      final hold = await tester.startGesture(tester.getCenter(shutter));
      expect((started, ended), (1, 0));

      await tester.pump(const Duration(milliseconds: 800));
      await hold.up();
      expect((started, ended), (1, 1));
    });

    testWidgets('while holding, the percentage shows', (tester) async {
      await tester.pumpWidget(
        _template(_booth(CapturePhase.capturing, captureProgress: 0.45)),
      );
      expect(find.text('Keep holding… 45%'), findsOneWidget);
      expect(find.text('Let go to finish'), findsOneWidget);
    });

    testWidgets('making the boomerang shows how far along it is', (
      tester,
    ) async {
      await tester.pumpWidget(
        _template(_booth(CapturePhase.processing, processingProgress: 0.6)),
      );
      await tester.pumpAndSettle();
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('Making your boomerang…'), findsOneWidget);
    });

    test('photo and GIF use the countdown, not a hold', () async {
      final container = ProviderContainer(
        overrides: [
          captureViewModelProvider('s')
              .overrideWith(() => _ReadyBooth(CaptureMode.photo)),
        ],
      );
      addTearDown(container.dispose);
      container.listen(captureViewModelProvider('s'), (_, _) {});
      await container.read(captureViewModelProvider('s').future);

      await container.read(captureViewModelProvider('s').notifier).startHold();
      expect(
        container.read(captureViewModelProvider('s')).value!.phase,
        CapturePhase.instruction,
      );
    });
  });

  group('booth settings', () {
    late AppDatabase db;
    late ProviderContainer container;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          captureViewModelProvider('s')
              .overrideWith(() => _ReadyBooth(CaptureMode.photo)),
        ],
      );
    });
    tearDown(() async {
      container.dispose();
      await db.close();
    });

    test('start with a 3-second countdown and 6-second clips', () async {
      final settings = container.read(settingsRepositoryProvider);
      expect(await settings.getCountdownSeconds(), 3);
      expect(await settings.getClipSeconds(), 6);
    });

    test('a new countdown is used right away and remembered', () async {
      container.listen(captureViewModelProvider('s'), (_, _) {});
      await container.read(captureViewModelProvider('s').future);

      await container
          .read(captureViewModelProvider('s').notifier)
          .setCountdownSeconds(10);

      expect(
        container.read(captureViewModelProvider('s')).value!.countdownSeconds,
        10,
      );
      expect(
        await container.read(settingsRepositoryProvider).getCountdownSeconds(),
        10,
      );
    });

    test('an unknown saved value falls back to the default', () async {
      await db.settingsDao.setValue('booth.clip_seconds', '999');
      expect(
        await SettingsRepository(db.settingsDao).getClipSeconds(),
        SettingsRepository.clipChoices.first,
      );
    });
  });

  group('saved keepsake designs', () {
    test('layout, paper and stickers survive a save and reload', () {
      final saved = PreviewSamples.gridKeepsake.toJson();
      final base = PreviewSamples.keepsake.copyWith(
        layout: KeepsakeLayout.strip,
        frame: KeepsakeFrame.cream,
        stickers: const [],
      );

      final restored = base.withSaved(saved);

      expect(restored.layout, KeepsakeLayout.grid);
      expect(restored.frame, KeepsakeFrame.film);
      expect(
        [for (final s in restored.stickers) (s.type, s.x, s.y)],
        [
          for (final s in PreviewSamples.gridKeepsake.stickers)
            (s.type, s.x, s.y),
        ],
      );
    });

    test('an unreadable saved design is ignored, not a crash', () {
      final base = PreviewSamples.keepsake;
      expect(base.withSaved('{not json').layout, base.layout);
    });

    test('the design is stored with the memory', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      final repo = MemoryRepository(db.memoryDao);
      final quest = (await db.questDao.getAllQuests()).first;
      final memory = await repo.createMemory(
        questSessionId: await repo.startQuestSession(quest.id),
        title: quest.title,
        capturedAt: DateTime(2026, 9, 17),
        personIds: const [],
      );

      expect(await repo.getKeepsakeDesign(memory.id), isNull);
      await repo.saveKeepsakeDesign(memory.id, '{"layout":"grid"}');
      expect(await repo.getKeepsakeDesign(memory.id), '{"layout":"grid"}');
    });
  });
}
