import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/app.dart';
import 'package:photoquest/config/constant/app_theme.dart';
import 'package:photoquest/core/data/database/app_database.dart'
    show AppDatabase;
import 'package:photoquest/core/data/database/database_providers.dart';
import 'package:photoquest/core/domain/memories/entities/photo.dart';
import 'package:photoquest/core/domain/quests/entities/quest.dart';
import 'package:photoquest/core/domain/quests/entities/quest_shot.dart';
import 'package:photoquest/core/presentation/screen/camera/capture_screen.dart';
import 'package:photoquest/core/presentation/screen/memories/memories_screen.dart';
import 'package:photoquest/core/presentation/screen/people/people_screen.dart';
import 'package:photoquest/core/presentation/view_model/camera/capture_view_model.dart';
import 'package:photoquest/core/presentation/view_model/memories/memory_list_view_model.dart';

Widget _themed(Widget child, {List overrides = const []}) {
  return ProviderScope(
    overrides: [...overrides],
    child: MaterialApp(theme: AppTheme.light, home: child),
  );
}

class _ReviewingCapture extends CaptureViewModel {
  @override
  Future<CaptureState> build(String sessionId) async {
    final now = DateTime(2026, 9, 17);
    return CaptureState(
      quest: Quest(
        id: 'q',
        title: 'Anniversary',
        category: 'For Us',
        createdAt: now,
        updatedAt: now,
      ),
      shots: const [
        QuestShot(
          id: 's1',
          questId: 'q',
          position: 0,
          instruction: 'Stand together and smile',
          shotType: 'group',
        ),
        QuestShot(
          id: 's2',
          questId: 'q',
          position: 1,
          instruction: 'Hold hands',
          shotType: 'close_up',
        ),
      ],
      memoryId: 'm',
      participants: const [],
      currentIndex: 0,
      phase: CapturePhase.captured,
      countdownValue: 3,
      lastPhoto: Photo(
        id: 'p',
        memoryId: 'm',
        originalPath: 'missing.jpg',
        thumbnailPath: 'missing.jpg',
        position: 0,
        capturedAt: now,
        width: 300,
        height: 400,
      ),
    );
  }
}

void main() {
  testWidgets('Home leads with Today\'s Quest', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PhotoQuestApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("TODAY'S QUEST"), findsOneWidget);
    expect(find.text("Let's do it"), findsOneWidget);
    expect(find.bySemanticsLabel('Start a quest'), findsOneWidget);
  });

  testWidgets('empty Memories invites you to start a quest', (tester) async {
    await tester.pumpWidget(
      _themed(
        const MemoriesScreen(),
        overrides: [memoryListProvider.overrideWith((ref) => const [])],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your memories will live here'), findsOneWidget);
    expect(find.text('Start a quest'), findsOneWidget);
  });

  testWidgets('adding a person needs a name, and never offers "You"', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      _themed(
        const PeopleScreen(),
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add someone'));
    await tester.pumpAndSettle();

    final addButton = find.widgetWithText(FilledButton, 'Add');
    expect(tester.widget<FilledButton>(addButton).onPressed, isNull);
    expect(find.widgetWithText(ChoiceChip, 'You'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Sam');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add Sam'));
    await tester.pumpAndSettle();

    expect(find.text('Sam'), findsOneWidget);
  });

  testWidgets('after a shot, Keep and Retake are both offered', (tester) async {
    await tester.pumpWidget(
      _themed(
        const CaptureScreen(sessionId: 's'),
        overrides: [
          captureViewModelProvider('s').overrideWith(_ReviewingCapture.new),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Keep it'), findsOneWidget);
    expect(find.text('Retake'), findsOneWidget);
    expect(find.bySemanticsLabel('Shot 1 of 2'), findsOneWidget);
  });
}
