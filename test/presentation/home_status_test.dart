import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/app.dart';
import 'package:photoquest/config/constant/app_theme.dart';
import 'package:photoquest/core/data/database/app_database.dart'
    show AppDatabase;
import 'package:photoquest/core/data/database/database_providers.dart';
import 'package:photoquest/core/domain/moments/entities/day_moment.dart';
import 'package:photoquest/core/domain/people/enum/mood.dart';
import 'package:photoquest/core/presentation/widget/templates/home_template.dart';
import 'package:photoquest/core/presentation/widget/templates/preview_samples.dart';

HomeTemplate _home({
  Mood? mood,
  List<DayMoment> moments = const [],
  VoidCallback? onOpenMood,
  VoidCallback? onOpenProfile,
  VoidCallback? onAddMoment,
  ValueChanged<DayMoment>? onOpenMoment,
}) {
  return HomeTemplate(
    greeting: 'Good morning',
    now: PreviewSamples.today,
    todayQuest: AsyncData(PreviewSamples.anniversary),
    pendingQuests: const AsyncData([]),
    memories: const AsyncData([]),
    mood: mood,
    avatarId: 'animals/fox',
    moments: AsyncData(moments),
    onRefresh: () async {},
    onOpenMood: onOpenMood ?? () {},
    onOpenProfile: onOpenProfile ?? () {},
    onAddMoment: onAddMoment ?? () {},
    onOpenMoment: onOpenMoment ?? (_) {},
    onOpenQuest: (_) {},
    onOpenMemory: (_) {},
    onSeeAllMemories: () {},
    onBrowseQuests: () {},
    onCreateQuest: () {},
  );
}

Future<void> _pumpApp(WidgetTester tester) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const PhotoQuestApp(),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the top of Home shows how you feel and your profile, not '
      'a settings button', (tester) async {
    var openedMood = false;
    var openedProfile = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: _home(
          mood: Mood.happy,
          onOpenMood: () => openedMood = true,
          onOpenProfile: () => openedProfile = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Feeling happy'), findsOneWidget);
    expect(find.bySemanticsLabel('Your profile'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsNothing);

    await tester.tap(find.text('Feeling happy'));
    await tester.tap(find.bySemanticsLabel('Your profile'));
    expect(openedMood, isTrue);
    expect(openedProfile, isTrue);
  });

  testWidgets('with no mood chosen, the pill invites you to pick one', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: _home()));
    await tester.pumpAndSettle();

    expect(find.text('How are you feeling?'), findsOneWidget);
  });

  testWidgets('Your Day starts with an add tile and lists moments with the '
      'time they have left', (tester) async {
    var added = false;
    DayMoment? opened;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: _home(
          moments: PreviewSamples.dayMoments,
          onAddMoment: () => added = true,
          onOpenMoment: (moment) => opened = moment,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Pinned to the preview's "now": 19h and 23h left.
    expect(find.text('Your Day'), findsWidgets);
    expect(find.text('19h left'), findsOneWidget);
    expect(find.text('23h left'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Add to Your Day'));
    expect(added, isTrue);

    await tester.tap(find.bySemanticsLabel('Open moment, 19h left'));
    expect(opened?.id, 'm-coffee');
  });

  testWidgets('choosing how you feel updates the pill and is remembered', (
    tester,
  ) async {
    await _pumpApp(tester);
    expect(find.text('How are you feeling?'), findsOneWidget);

    await tester.tap(find.text('How are you feeling?'));
    await tester.pumpAndSettle();

    // Seeing how loved ones feel needs accounts, which are not here yet.
    expect(find.text('Coming soon'), findsOneWidget);

    await tester.tap(find.text('Sad'));
    await tester.pumpAndSettle();

    expect(find.text('Feeling sad'), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
  });

  testWidgets('tapping your profile goes straight to Settings, with Log out '
      'there as coming soon', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.bySemanticsLabel('Your profile'));
    await tester.pumpAndSettle();

    expect(find.text('Private by design'), findsOneWidget);
    expect(find.text('Profile settings'), findsOneWidget);
    expect(find.text('Log out'), findsOneWidget);
    expect(find.text('Coming soon'), findsOneWidget);
  });

  testWidgets('Profile settings saves your name and avatar, and Home shows '
      'the avatar', (tester) async {
    await _pumpApp(tester);
    final onHome = find.descendant(
      of: find.bySemanticsLabel('Your profile'),
      matching: find.byType(Image),
    );
    expect(onHome, findsNothing);

    await tester.tap(find.bySemanticsLabel('Your profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile settings'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Maya');
    // Browse a category, then pick from it.
    await tester.tap(find.text('Travel'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Globe avatar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Back on Settings, the name shows under Profile settings.
    expect(find.text('Maya'), findsOneWidget);

    // And on Home, the picked avatar replaces the plain icon.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(onHome, findsOneWidget);
  });
}
