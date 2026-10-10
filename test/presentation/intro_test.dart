import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/app.dart';
import 'package:photoquest/core/data/database/app_database.dart'
    show AppDatabase;
import 'package:photoquest/core/data/database/database_providers.dart';
import 'package:photoquest/core/data/repositories/auth_repository_provider.dart';
import 'package:photoquest/core/data/repositories/settings_repository.dart';
import 'package:photoquest/core/presentation/view_model/auth/intro_view_model.dart';

import '../support/fake_auth_repository.dart';

/// Boots the whole app on a phone-sized screen. Motion is reduced so the
/// looping logo lets `pumpAndSettle` finish.
Future<AppDatabase> _pumpApp(
  WidgetTester tester, {
  required bool introSeen,
  bool signedIn = false,
}) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);

  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(signedIn: signedIn),
      ),
      initialIntroSeenProvider.overrideWithValue(introSeen),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const PhotoQuestApp(),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

void main() {
  group('get-started pages', () {
    testWidgets('a new person sees them before the welcome screen', (
      tester,
    ) async {
      await _pumpApp(tester, introSeen: false);

      expect(find.text('Pick a quest'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Create account'), findsNothing);
    });

    testWidgets('Next moves on, and the last page says Get started', (
      tester,
    ) async {
      await _pumpApp(tester, introSeen: false);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Strike the pose'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Keep the memory'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('swiping moves between pages', (tester) async {
      await _pumpApp(tester, introSeen: false);

      await tester.drag(find.text('Pick a quest'), const Offset(-400, 0));
      await tester.pumpAndSettle();

      expect(find.text('Strike the pose'), findsOneWidget);
    });

    testWidgets('Get started goes to welcome and is remembered', (
      tester,
    ) async {
      final db = await _pumpApp(tester, introSeen: false);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Pick a quest'), findsNothing);
      expect(await SettingsRepository(db.settingsDao).getIntroSeen(), isTrue);
    });

    testWidgets('Skip goes straight to welcome', (tester) async {
      await _pumpApp(tester, introSeen: false);

      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Create account'), findsOneWidget);
    });

    testWidgets('someone who has seen them goes straight to welcome', (
      tester,
    ) async {
      await _pumpApp(tester, introSeen: true);

      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Pick a quest'), findsNothing);
    });

    testWidgets('a signed-in person never sees them', (tester) async {
      await _pumpApp(tester, introSeen: false, signedIn: true);

      expect(find.text('Pick a quest'), findsNothing);
      expect(find.text('Create account'), findsNothing);
    });
  });
}
