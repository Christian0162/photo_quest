import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'settle.dart';

import 'package:photoquest/app.dart';
import 'package:photoquest/config/constant/app_theme.dart';
import 'package:photoquest/core/data/database/app_database.dart'
    show AppDatabase;
import 'package:photoquest/core/data/database/database_providers.dart';
import 'package:photoquest/core/domain/camera/enum/capture_phase.dart';
import 'package:photoquest/core/domain/memories/entities/photo.dart';
import 'package:photoquest/core/domain/memories/enum/memory_filter.dart';
import 'package:photoquest/core/domain/quests/entities/quest.dart';
import 'package:photoquest/core/domain/quests/entities/quest_shot.dart';
import 'package:photoquest/core/presentation/screen/camera/capture_screen.dart';
import 'package:photoquest/core/presentation/screen/memories/memories_screen.dart';
import 'package:photoquest/core/presentation/screen/people/people_screen.dart';
import 'package:photoquest/core/presentation/screen/quests/quest_selection_screen.dart';
import 'package:photoquest/core/presentation/types/camera/capture_state.dart';
import 'package:photoquest/core/presentation/view_model/camera/capture_view_model.dart';
import 'package:photoquest/core/presentation/view_model/memories/memory_list_view_model.dart';
import 'package:photoquest/core/presentation/widget/templates/memories_template.dart';
import 'package:photoquest/core/presentation/widget/templates/preview_samples.dart';

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
    await tester.settle();

    expect(find.text("TODAY'S QUEST"), findsOneWidget);
    expect(find.text("Let's do it"), findsOneWidget);
    expect(find.bySemanticsLabel('Make a quest'), findsOneWidget);
  });

  testWidgets('the dock stays on every tab and the + opens quest creation', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PhotoQuestApp(),
      ),
    );
    await tester.settle();

    for (final tab in ['People', 'Memories', 'Quests', 'Home']) {
      await tester.tap(find.bySemanticsLabel(tab));
      await tester.settle();
      expect(
        find.bySemanticsLabel('Make a quest').hitTestable(),
        findsOneWidget,
        reason: 'on $tab',
      );
    }

    await tester.tap(find.bySemanticsLabel('Make a quest'));
    await tester.settle();
    expect(find.bySemanticsLabel('Make a quest'), findsNothing);
  });

  testWidgets('the welcome card shows on open, closes with its X, and opens '
      'Quests when tapped', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PhotoQuestApp(),
      ),
    );
    await tester.settle();

    final card = find.bySemanticsLabel(RegExp('^Start a quest'));
    expect(card, findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.settle();
    expect(card, findsNothing);
  });

  testWidgets('tapping the welcome card goes to Quests', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PhotoQuestApp(),
      ),
    );
    await tester.settle();

    // It stays put on its own; only the X closes it.
    await tester.pump(const Duration(minutes: 1));
    expect(find.bySemanticsLabel(RegExp('^Start a quest')), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('^Start a quest')));
    await tester.settle();
    expect(find.byType(QuestSelectionScreen), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^Start a quest')), findsOneWidget);
  });

  testWidgets('sheets open above the dock, so nothing is hidden behind it', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PhotoQuestApp(),
      ),
    );
    await tester.settle();

    await tester.tap(find.bySemanticsLabel('People'));
    await tester.settle();
    await tester.tap(find.byTooltip('Add someone'));
    await tester.settle();

    expect(find.text('Their name'), findsOneWidget);
    expect(find.bySemanticsLabel('Make a quest').hitTestable(), findsNothing);
  });

  testWidgets('the dock tucks away while scrolling down and returns on the '
      'way up', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PhotoQuestApp(),
      ),
    );
    await tester.settle();

    final dock = find.bySemanticsLabel('Make a quest');
    final card = find.bySemanticsLabel(RegExp('^Start a quest'));
    expect(dock.hitTestable(), findsOneWidget);
    final cardTop = tester.getTopLeft(card).dy;

    final page = find.byType(Scrollable).first;
    await tester.drag(page, const Offset(0, -200));
    await tester.settle();
    expect(dock.hitTestable(), findsNothing);
    // The welcome card stays, and drops into the dock's place.
    expect(card.hitTestable(), findsOneWidget);
    expect(tester.getTopLeft(card).dy, greaterThan(cardTop));

    await tester.drag(page, const Offset(0, 100));
    await tester.settle();
    expect(dock.hitTestable(), findsOneWidget);
    expect(tester.getTopLeft(card).dy, cardTop);
  });

  testWidgets('opening the app plays a short reveal, then gets out of the '
      'way; a tap skips it', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PhotoQuestApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    expect(
      find.text('Do something together. Keep the memory.'),
      findsOneWidget,
    );

    // A tap jumps to the outro instead of waiting out the whole reveal.
    await tester.tapAt(const Offset(10, 10));
    await tester.pump(); // the outro starts on this frame
    await tester.pump(const Duration(milliseconds: 420));
    await tester.pump();
    expect(find.text('Do something together. Keep the memory.'), findsNothing);
    expect(find.text("TODAY'S QUEST"), findsOneWidget);
  });

  testWidgets('swiping sideways moves to the next or previous tab, and stops '
      'at the first and last', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PhotoQuestApp(),
      ),
    );
    await tester.settle();

    Future<void> swipe(double dx) async {
      await tester.flingFrom(const Offset(195, 420), Offset(dx, 0), 1500);
      await tester.settle();
    }

    expect(find.text("TODAY'S QUEST"), findsOneWidget);

    // Already on the first tab: swiping right goes nowhere.
    await swipe(300);
    expect(find.text("TODAY'S QUEST"), findsOneWidget);

    // Left goes forward: Quests, Memories, People.
    await swipe(-300);
    expect(find.text('Choose a quest'), findsOneWidget);
    await swipe(-300);
    expect(find.text('YOUR MEMORY BOX'), findsOneWidget);
    await swipe(-300);
    expect(find.text('YOUR CIRCLE'), findsOneWidget);

    // Last tab: swiping left goes nowhere.
    await swipe(-300);
    expect(find.text('YOUR CIRCLE'), findsOneWidget);

    // Right goes back.
    await swipe(300);
    expect(find.text('YOUR MEMORY BOX'), findsOneWidget);
  });

  testWidgets('a small sideways nudge does not change tabs', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PhotoQuestApp(),
      ),
    );
    await tester.settle();

    await tester.drag(find.text("TODAY'S QUEST"), const Offset(-30, 0));
    await tester.settle();

    expect(find.text("TODAY'S QUEST"), findsOneWidget);
  });

  testWidgets('the nav dock fits a small phone at large text on every tab', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const PhotoQuestApp(),
      ),
    );
    await tester.settle();

    for (final tab in ['Memories', 'People', 'Home']) {
      await tester.tap(find.bySemanticsLabel(tab));
      await tester.settle();
      expect(tester.takeException(), isNull, reason: 'on $tab');
    }
  });

  testWidgets('the memory box shows each memory as a journal page, and '
      'every photo can be opened', (tester) async {
    (String, int)? viewed;
    String? opened;
    MemoryFilter? filtered;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MemoriesTemplate(
          box: AsyncData(PreviewSamples.memoryBox()),
          now: PreviewSamples.today,
          onFilterChanged: (filter) => filtered = filter,
          onRetry: () {},
          onStartQuest: () {},
          onOpenMemory: (summary) => opened = summary.memory.title,
          onViewPhoto: (summary, index) =>
              viewed = (summary.memory.title, index),
        ),
      ),
    );
    await tester.settle();

    // The month's first memory is featured: when, how long ago, the words.
    expect(find.text('MONDAY, SEP 14 · 8:42 PM'), findsOneWidget);
    expect(find.text('3 days ago'), findsOneWidget);
    expect(find.text('Anniversary'), findsOneWidget);
    expect(
      find.text(
        'Back at the little café where it all started. Same table, too.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.bySemanticsLabel('View photo 2 of 3').first);
    expect(viewed, ('Our Anniversary', 1));

    // The rest of the month follows as journal entries.
    final page = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Earlier in September'),
      200,
      scrollable: page,
    );
    await tester.scrollUntilVisible(
      find.text('Buddy’s Park Day'),
      200,
      scrollable: page,
    );
    await tester.drag(page, const Offset(0, -200));
    await tester.settle();
    // Only one journal entry in the samples, so one cover to open.
    await tester.tap(
      find.bySemanticsLabel('View the photos. You and Buddy, together.'),
    );
    expect(viewed, ('Buddy’s Park Day', 0));

    await tester.ensureVisible(find.text('Buddy’s Park Day'));
    await tester.settle();
    await tester.tap(find.text('Buddy’s Park Day'));
    expect(opened, 'Buddy’s Park Day');

    await tester.scrollUntilVisible(
      find.text('This day'),
      -300,
      scrollable: page,
    );
    await tester.settle();
    await tester.tap(find.bySemanticsLabel('This day, 1 memory'));
    expect(filtered, MemoryFilter.thisDay);
  });

  testWidgets('memory cards fit a small phone at large text', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MemoriesTemplate(
          box: AsyncData(PreviewSamples.memoryBox()),
          now: PreviewSamples.today,
          onFilterChanged: (_) {},
          onRetry: () {},
          onStartQuest: () {},
          onOpenMemory: (_) {},
          onViewPhoto: (_, _) {},
        ),
      ),
    );
    await tester.settle();

    final page = find.byType(Scrollable).first;
    for (var i = 0; i < 20; i++) {
      await tester.drag(page, const Offset(0, -300));
      await tester.settle();
      expect(tester.takeException(), isNull);
    }
  });

  test('a memory without a note is described by who was there', () {
    final park = PreviewSamples.memories[1];
    expect(park.description, 'You and Buddy, together.');
  });

  testWidgets('empty Memories invites you to start a quest', (tester) async {
    await tester.pumpWidget(
      _themed(
        const MemoriesScreen(),
        overrides: [memoryListProvider.overrideWith((ref) => const [])],
      ),
    );
    await tester.settle();

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
    await tester.settle();

    await tester.tap(find.byTooltip('Add someone'));
    await tester.settle();

    final addButton = find.widgetWithText(FilledButton, 'Add');
    expect(tester.widget<FilledButton>(addButton).onPressed, isNull);
    expect(find.widgetWithText(ChoiceChip, 'You'), findsNothing);

    await tester.enterText(find.byType(TextField), 'Sam');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Add Sam'));
    await tester.settle();

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
    await tester.settle();

    expect(find.text('Keep it'), findsOneWidget);
    expect(find.text('Retake'), findsOneWidget);
    expect(find.bySemanticsLabel('Shot 1 of 2'), findsOneWidget);
  });
}
