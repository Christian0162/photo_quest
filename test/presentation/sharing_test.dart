import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/app.dart';
import 'package:photoquest/config/constant/app_theme.dart';
import 'package:photoquest/core/data/database/app_database.dart'
    show AppDatabase;
import 'package:photoquest/core/data/database/database_providers.dart';
import 'package:photoquest/core/data/repositories/auth_repository_provider.dart';
import 'package:photoquest/core/data/repositories/backup_providers.dart';
import 'package:photoquest/core/data/repositories/cloud_memory_repository_provider.dart';
import 'package:photoquest/core/data/repositories/memory_repository_provider.dart';
import 'package:photoquest/core/data/repositories/settings_repository_provider.dart';
import 'package:photoquest/core/data/repositories/service_providers.dart';
import 'package:photoquest/core/domain/sharing/entities/shared_memory.dart';
import 'package:photoquest/core/domain/sharing/entities/shared_quest.dart';
import 'package:photoquest/core/domain/sharing/invite_code.dart';
import 'package:photoquest/core/errors/app_failure.dart';
import 'package:photoquest/core/presentation/screen/sharing/invite_friend_sheet.dart';
import 'package:photoquest/core/presentation/view_model/settings/backup_view_model.dart';

import '../support/fake_auth_repository.dart';
import '../support/fake_cloud_memory_repository.dart';

final _sharedBeach = SharedMemorySummary(
  id: 'm1',
  title: 'Beach day',
  capturedAt: DateTime(2026, 9, 20),
  ownerName: 'Sam',
);

final _beachDetail = SharedMemoryDetail(
  id: 'm1',
  title: 'Beach day',
  note: 'Sunny all afternoon',
  capturedAt: DateTime(2026, 9, 20),
  ownerName: 'Sam',
  photos: const [
    SharedPhoto(
      id: 'p1',
      position: 0,
      kind: 'photo',
      url: 'http://fake.test/p1.jpg',
    ),
    SharedPhoto(
      id: 'p2',
      position: 1,
      kind: 'video',
      url: 'http://fake.test/p2.mp4',
      thumbnailUrl: 'http://fake.test/p2.jpg',
    ),
  ],
);

Future<ProviderContainer> _pumpApp(
  WidgetTester tester,
  FakeCloudMemoryRepository cloud, {
  FakeCloudQuestRepository? quests,
  FakeConnectivityService? connectivity,
  FakePhotoPickerService? picker,
}) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);

  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(db),
      authRepositoryProvider.overrideWithValue(
        FakeAuthRepository(signedIn: true),
      ),
      cloudMemoryRepositoryProvider.overrideWithValue(cloud),
      cloudQuestRepositoryProvider.overrideWithValue(
        quests ?? FakeCloudQuestRepository(),
      ),
      connectivityServiceProvider.overrideWithValue(
        connectivity ?? FakeConnectivityService(),
      ),
      photoPickerServiceProvider.overrideWithValue(
        picker ?? FakePhotoPickerService(),
      ),
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
  return container;
}

Future<void> _openShared(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Memories'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Shared with you'));
  await tester.pumpAndSettle();
}

Future<void> _enterCode(WidgetTester tester, String code) async {
  await tester.enterText(find.widgetWithText(TextField, 'Invite code'), code);
  await tester.pump();
}

/// Pumps just the invite sheet, opened from a button.
Future<void> _pumpSheet(
  WidgetTester tester,
  FakeCloudMemoryRepository cloud, {
  FakeSharingService? sharing,
}) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cloudMemoryRepositoryProvider.overrideWithValue(cloud),
        sharingServiceProvider.overrideWithValue(
          sharing ?? FakeSharingService(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => showInviteFriendSheet(context, 'memory-1'),
                child: const Text('Open sheet'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open sheet'));
  await tester.pumpAndSettle();
}

/// Pumps just the quest invite sheet, opened from a button.
Future<void> _pumpQuestSheet(
  WidgetTester tester,
  FakeCloudQuestRepository quests,
) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        cloudQuestRepositoryProvider.overrideWithValue(quests),
        sharingServiceProvider.overrideWithValue(FakeSharingService()),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => showInviteToQuestSheet(context, 'quest-1'),
                child: const Text('Open sheet'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open sheet'));
  await tester.pumpAndSettle();
}

final _dateNight = SharedQuestSummary(
  id: 'q1',
  title: 'Date night',
  description: 'Dinner and a photo',
  ownerName: 'Sam',
  status: ParticipationStatus.invited,
);

SharedQuestDetail _questDetail({
  ParticipationStatus status = ParticipationStatus.invited,
  List<SharedMemorySummary> memories = const [],
}) => SharedQuestDetail(
  id: 'q1',
  title: 'Date night',
  description: 'Dinner and a photo',
  ownerName: 'Sam',
  status: status,
  shots: const ['Cheers!', 'Cheek to cheek'],
  participants: [
    ShareViewer(
      id: 'f1',
      name: 'Bo',
      sharedAt: DateTime(2026, 10, 1),
      status: 'Joined',
    ),
  ],
  memories: memories,
);

void main() {
  group('InviteCode', () {
    test('is forgiving about spaces, dashes and case', () {
      expect(InviteCode.normalize(' abcde-fghjk '), 'ABCDEFGHJK');
      expect(InviteCode.validate('abcde-fghjk'), isNull);
    });

    test('asks for a full code', () {
      expect(InviteCode.validate(''), isNotNull);
      expect(InviteCode.validate('ABC'), contains('10'));
    });

    test('is shown with a dash in the middle', () {
      expect(InviteCode.format('abcdefghjk'), 'ABCDE-FGHJK');
      expect(InviteCode.format('short'), 'short');
    });
  });

  group('entering a code', () {
    testWidgets('Memories leads to Shared with you, and an empty state', (
      tester,
    ) async {
      await _pumpApp(tester, FakeCloudMemoryRepository());
      await _openShared(tester);

      expect(find.text('Nothing shared with you yet'), findsOneWidget);
      expect(find.text('Enter a code'), findsOneWidget);
    });

    testWidgets('lists what friends shared and opens it', (tester) async {
      final cloud = FakeCloudMemoryRepository()
        ..shared = [_sharedBeach]
        ..details['m1'] = _beachDetail;
      await _pumpApp(tester, cloud);
      await _openShared(tester);

      expect(find.text('Beach day'), findsOneWidget);
      expect(find.text('From Sam'), findsOneWidget);

      await tester.tap(find.text('Beach day'));
      await tester.pumpAndSettle();

      expect(find.text('Shared by Sam'), findsOneWidget);
      expect(find.text('Sunny all afternoon'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Beach day, photo 2 of 2, clip')),
        findsOneWidget,
      );
    });

    testWidgets('an incomplete code is caught before asking the server', (
      tester,
    ) async {
      final cloud = FakeCloudMemoryRepository();
      await _pumpApp(tester, cloud);
      await _openShared(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Enter a code'));
      await tester.pumpAndSettle();

      await _enterCode(tester, 'ABC');
      await tester.tap(find.widgetWithText(FilledButton, 'See the memory'));
      await tester.pumpAndSettle();

      expect(find.text('A code has 10 letters and numbers.'), findsOneWidget);
      expect(cloud.calls.where((c) => c.startsWith('redeem')), isEmpty);
    });

    testWidgets('a wrong code says so kindly', (tester) async {
      final cloud = FakeCloudMemoryRepository();
      await _pumpApp(tester, cloud);
      await _openShared(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Enter a code'));
      await tester.pumpAndSettle();

      await _enterCode(tester, 'zzzzz-zzzzz');
      await tester.tap(find.widgetWithText(FilledButton, 'See the memory'));
      await tester.pumpAndSettle();

      expect(find.textContaining("That code didn't work"), findsOneWidget);
      expect(find.text('Got a code?'), findsOneWidget);
    });

    testWidgets('a right code, typed loosely, opens the memory', (
      tester,
    ) async {
      final cloud = FakeCloudMemoryRepository()
        ..validCodes['ABCDEFGHJK'] = const InviteTarget(InviteKind.memory, 'm1')
        ..details['m1'] = _beachDetail;
      await _pumpApp(tester, cloud);
      await _openShared(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Enter a code'));
      await tester.pumpAndSettle();

      await _enterCode(tester, 'abcde-fghjk');
      await tester.tap(find.widgetWithText(FilledButton, 'See the memory'));
      await tester.pumpAndSettle();

      expect(cloud.calls, contains('redeem:ABCDEFGHJK'));
      expect(find.text('Shared by Sam'), findsOneWidget);
    });

    testWidgets('guessing too much asks the person to wait', (tester) async {
      final cloud = FakeCloudMemoryRepository();
      await _pumpApp(tester, cloud);
      await _openShared(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Enter a code'));
      await tester.pumpAndSettle();

      cloud.failNext = const SharingFailure(
        SharingFailureKind.tooManyTries,
        'Too many tries for now. Please wait a little and try again.',
      );
      await _enterCode(tester, 'ABCDE-FGHJK');
      await tester.tap(find.widgetWithText(FilledButton, 'See the memory'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Too many tries'), findsOneWidget);
    });

    testWidgets('removing a shared memory asks first, then goes', (
      tester,
    ) async {
      final cloud = FakeCloudMemoryRepository()
        ..shared = [_sharedBeach]
        ..details['m1'] = _beachDetail;
      await _pumpApp(tester, cloud);
      await _openShared(tester);
      await tester.tap(find.text('Beach day'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Remove from my list'));
      await tester.tap(find.text('Remove from my list'));
      await tester.pumpAndSettle();
      expect(find.text('Remove this memory?'), findsOneWidget);

      // "Keep it" changes nothing.
      await tester.tap(find.text('Keep it'));
      await tester.pumpAndSettle();
      expect(cloud.calls.where((c) => c.startsWith('leave')), isEmpty);

      await tester.ensureVisible(find.text('Remove from my list'));
      await tester.tap(find.text('Remove from my list'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Remove it'));
      await tester.pumpAndSettle();

      expect(cloud.calls, contains('leave:m1'));
      expect(find.text('Nothing shared with you yet'), findsOneWidget);
    });

    testWidgets('a memory that is gone is explained, with a retry', (
      tester,
    ) async {
      final cloud = FakeCloudMemoryRepository()..shared = [_sharedBeach];
      await _pumpApp(tester, cloud);
      await _openShared(tester);

      await tester.tap(find.text('Beach day'));
      await tester.pumpAndSettle();

      expect(find.text("We couldn't open this memory"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('inviting a friend', () {
    testWidgets('explains first, then makes a code with honest progress', (
      tester,
    ) async {
      final cloud = FakeCloudMemoryRepository()..holdInvite = Completer<void>();
      await _pumpSheet(tester, cloud);

      expect(find.text('Invite a friend'), findsOneWidget);
      expect(find.textContaining('Only this one'), findsOneWidget);
      expect(find.text('ABCDE-FGHJK'), findsNothing);

      await tester.tap(find.text('Create an invite code'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Saving this memory online…'), findsOneWidget);
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        0.5,
      );
      // No second tap can start a second upload.
      expect(find.text('Create an invite code'), findsNothing);

      cloud.holdInvite!.complete();
      await tester.pumpAndSettle();

      expect(find.text('ABCDE-FGHJK'), findsOneWidget);
      expect(find.textContaining('7 days'), findsOneWidget);
      expect(
        cloud.calls.where((c) => c.startsWith('createInvite')),
        hasLength(1),
      );
    });

    testWidgets('the code can be copied', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await _pumpSheet(tester, FakeCloudMemoryRepository());
      await tester.tap(find.text('Create an invite code'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      expect(copied, 'ABCDE-FGHJK');
      expect(find.text('Code copied.'), findsOneWidget);
    });

    testWidgets('the code can be sent with a friendly message', (tester) async {
      final sharing = FakeSharingService();
      await _pumpSheet(tester, FakeCloudMemoryRepository(), sharing: sharing);
      await tester.tap(find.text('Create an invite code'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(sharing.sentText, contains('ABCDE-FGHJK'));
      expect(sharing.sentText, contains('Shared with you'));
    });

    testWidgets('a failure is explained and the person can try again', (
      tester,
    ) async {
      final cloud = FakeCloudMemoryRepository()
        ..failNext = const SharingFailure(
          SharingFailureKind.offline,
          "Can't reach Photo Quest right now. Check your connection and try "
          'again.',
        );
      await _pumpSheet(tester, cloud);

      await tester.tap(find.text('Create an invite code'));
      await tester.pumpAndSettle();

      expect(find.textContaining("Can't reach Photo Quest"), findsOneWidget);
      expect(find.text('Create an invite code'), findsOneWidget);

      await tester.tap(find.text('Create an invite code'));
      await tester.pumpAndSettle();

      expect(find.text('ABCDE-FGHJK'), findsOneWidget);
      expect(find.textContaining("Can't reach Photo Quest"), findsNothing);
    });

    testWidgets('shows who can see the memory, and stops sharing on tap', (
      tester,
    ) async {
      final cloud = FakeCloudMemoryRepository()
        ..viewers = [
          ShareViewer(id: 'f1', name: 'Bo', sharedAt: DateTime(2026, 10, 1)),
          ShareViewer(id: 'f2', name: 'Cass', sharedAt: DateTime(2026, 10, 2)),
        ];
      await _pumpSheet(tester, cloud);

      expect(find.text('Who can see this'), findsOneWidget);
      expect(find.text('Bo'), findsOneWidget);

      await tester.tap(find.byTooltip('Stop sharing with Bo'));
      await tester.pumpAndSettle();

      expect(cloud.calls, contains('removeViewer:f1'));
      expect(find.text('Bo'), findsNothing);
      expect(find.text('Cass'), findsOneWidget);
    });

    testWidgets('the sheet fits a small phone', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      final cloud = FakeCloudMemoryRepository()
        ..viewers = [
          ShareViewer(
            id: 'f1',
            name: 'A friend with a rather long name indeed',
            sharedAt: DateTime(2026, 10, 1),
          ),
        ];
      await _pumpSheet(tester, cloud);
      await tester.tap(find.text('Create an invite code'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('invitations and quests you are in', () {
    testWidgets(
      'shows invitations, quests and memories in their own sections',
      (tester) async {
        final quests = FakeCloudQuestRepository()
          ..quests = [
            _dateNight,
            SharedQuestSummary(
              id: 'q2',
              title: 'Family day',
              ownerName: 'Cass',
              status: ParticipationStatus.accepted,
            ),
          ];
        final cloud = FakeCloudMemoryRepository()..shared = [_sharedBeach];
        await _pumpApp(tester, cloud, quests: quests);
        await _openShared(tester);

        expect(find.text('Invitations'), findsOneWidget);
        expect(find.text('Quests you are in'), findsOneWidget);
        expect(find.text('Memories'), findsWidgets);
        expect(find.text('Sam invited you'), findsOneWidget);
        expect(find.text('With Cass'), findsOneWidget);
        expect(find.text('Reply'), findsOneWidget, reason: 'not just a color');
        expect(find.text('Beach day'), findsOneWidget);
      },
    );

    testWidgets('accepting an invitation joins the quest', (tester) async {
      final quests = FakeCloudQuestRepository()
        ..quests = [_dateNight]
        ..details['q1'] = _questDetail();
      await _pumpApp(tester, FakeCloudMemoryRepository(), quests: quests);
      await _openShared(tester);

      await tester.tap(find.text('Date night'));
      await tester.pumpAndSettle();

      expect(find.text('Sam invited you to do this together.'), findsOneWidget);
      expect(find.text('Cheers!'), findsOneWidget);
      expect(find.text('Bo · Joined'), findsOneWidget);
      expect(find.text('Leave this quest'), findsNothing);

      await tester.tap(find.widgetWithText(FilledButton, 'Accept the quest'));
      await tester.pumpAndSettle();

      expect(quests.calls, contains('respond:q1:true'));
      expect(find.text('With Sam'), findsOneWidget);
      expect(find.text('Leave this quest'), findsOneWidget);
      expect(find.text('Accept the quest'), findsNothing);
      expect(
        find.textContaining('add your own photos'),
        findsOneWidget,
        reason: 'tells them what happens next',
      );
    });

    testWidgets('declining goes back and the invitation is gone', (
      tester,
    ) async {
      final quests = FakeCloudQuestRepository()
        ..quests = [_dateNight]
        ..details['q1'] = _questDetail();
      await _pumpApp(tester, FakeCloudMemoryRepository(), quests: quests);
      await _openShared(tester);
      await tester.tap(find.text('Date night'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(quests.calls, contains('respond:q1:false'));
      expect(find.text('Date night'), findsNothing);
      expect(find.text('Nothing shared with you yet'), findsOneWidget);
    });

    testWidgets('a failed answer is explained and nothing changes', (
      tester,
    ) async {
      final quests = FakeCloudQuestRepository()
        ..quests = [_dateNight]
        ..details['q1'] = _questDetail();
      await _pumpApp(tester, FakeCloudMemoryRepository(), quests: quests);
      await _openShared(tester);
      await tester.tap(find.text('Date night'));
      await tester.pumpAndSettle();

      quests.failNext = const SharingFailure(
        SharingFailureKind.notFound,
        'That invitation is no longer open.',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Accept the quest'));
      await tester.pumpAndSettle();

      expect(find.text('That invitation is no longer open.'), findsOneWidget);
      expect(find.text('Accept the quest'), findsOneWidget);
    });

    testWidgets('a quest code leads to the invitation', (tester) async {
      final quests = FakeCloudQuestRepository()
        ..quests = [_dateNight]
        ..details['q1'] = _questDetail();
      final cloud = FakeCloudMemoryRepository()
        ..validCodes['ABCDEFGHJK'] = const InviteTarget(InviteKind.quest, 'q1');
      await _pumpApp(tester, cloud, quests: quests);
      await _openShared(tester);
      await tester.tap(find.widgetWithText(FilledButton, 'Enter a code'));
      await tester.pumpAndSettle();

      await _enterCode(tester, 'abcde-fghjk');
      await tester.tap(find.widgetWithText(FilledButton, 'See the memory'));
      await tester.pumpAndSettle();

      expect(find.text('Accept the quest'), findsOneWidget);
      expect(find.text('Sam invited you to do this together.'), findsOneWidget);
    });

    testWidgets('a joined quest lists its memories and can be left', (
      tester,
    ) async {
      final quests = FakeCloudQuestRepository()
        ..quests = [
          SharedQuestSummary(
            id: 'q1',
            title: 'Date night',
            ownerName: 'Sam',
            status: ParticipationStatus.accepted,
          ),
        ]
        ..details['q1'] = _questDetail(
          status: ParticipationStatus.accepted,
          memories: [_sharedBeach],
        );
      await _pumpApp(tester, FakeCloudMemoryRepository(), quests: quests);
      await _openShared(tester);
      await tester.tap(find.text('Date night'));
      await tester.pumpAndSettle();

      expect(find.text('Memories from this quest'), findsOneWidget);
      expect(find.text('Beach day'), findsOneWidget);

      await tester.ensureVisible(find.text('Leave this quest'));
      await tester.tap(find.text('Leave this quest'));
      await tester.pumpAndSettle();
      expect(find.text('Leave this quest?'), findsOneWidget);

      await tester.tap(find.text('Stay'));
      await tester.pumpAndSettle();
      expect(quests.calls.where((c) => c.startsWith('leave')), isEmpty);

      await tester.ensureVisible(find.text('Leave this quest'));
      await tester.tap(find.text('Leave this quest'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Leave it'));
      await tester.pumpAndSettle();

      expect(quests.calls, contains('leave:q1'));
      expect(find.text('Nothing shared with you yet'), findsOneWidget);
    });

    testWidgets('a quest that is gone is explained, with a retry', (
      tester,
    ) async {
      final quests = FakeCloudQuestRepository()..quests = [_dateNight];
      await _pumpApp(tester, FakeCloudMemoryRepository(), quests: quests);
      await _openShared(tester);

      await tester.tap(find.text('Date night'));
      await tester.pumpAndSettle();

      expect(find.text("We couldn't open this quest"), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  group('adding your own photos to a quest memory', () {
    SharedMemoryDetail detail({
      required bool canAdd,
      bool withFriendPhoto = false,
    }) => SharedMemoryDetail(
      id: 'm1',
      title: 'Beach day',
      capturedAt: DateTime(2026, 9, 20),
      ownerName: 'Sam',
      canAddPhotos: canAdd,
      photos: [
        const SharedPhoto(
          id: 'p1',
          position: 0,
          kind: 'photo',
          url: 'http://fake.test/p1.jpg',
        ),
        if (withFriendPhoto)
          const SharedPhoto(
            id: 'p2',
            position: 1,
            kind: 'photo',
            url: 'http://fake.test/p2.jpg',
            addedByName: 'Bo',
          ),
      ],
    );

    testWidgets('a friend on the quest can add photos', (tester) async {
      final cloud = FakeCloudMemoryRepository()
        ..shared = [_sharedBeach]
        ..details['m1'] = detail(canAdd: true, withFriendPhoto: true);
      final picker = FakePhotoPickerService([
        Uint8List.fromList([1, 2, 3]),
        Uint8List.fromList([4, 5]),
      ]);
      await _pumpApp(tester, cloud, picker: picker);
      await _openShared(tester);
      await tester.tap(find.text('Beach day'));
      await tester.pumpAndSettle();

      expect(
        find.bySemanticsLabel(RegExp('added by Bo')),
        findsOneWidget,
        reason: 'photos say who added them',
      );

      await tester.ensureVisible(find.text('Add your photos'));
      await tester.tap(find.text('Add your photos'));
      await tester.pumpAndSettle();

      expect(cloud.calls, contains('addPhotos:m1:2'));
      expect(cloud.addedPhotos, hasLength(2));
      // The memory is read again so the new photos show.
      expect(cloud.calls.where((c) => c == 'sharedMemory:m1').length, 2);
    });

    testWidgets('someone with only a memory code cannot', (tester) async {
      final cloud = FakeCloudMemoryRepository()
        ..shared = [_sharedBeach]
        ..details['m1'] = detail(canAdd: false);
      await _pumpApp(tester, cloud);
      await _openShared(tester);
      await tester.tap(find.text('Beach day'));
      await tester.pumpAndSettle();

      expect(find.text('Add your photos'), findsNothing);
    });

    testWidgets('backing out of the picker does nothing', (tester) async {
      final cloud = FakeCloudMemoryRepository()
        ..shared = [_sharedBeach]
        ..details['m1'] = detail(canAdd: true);
      await _pumpApp(tester, cloud, picker: FakePhotoPickerService());
      await _openShared(tester);
      await tester.tap(find.text('Beach day'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Add your photos'));
      await tester.tap(find.text('Add your photos'));
      await tester.pumpAndSettle();

      expect(cloud.calls.where((c) => c.startsWith('addPhotos')), isEmpty);
    });

    testWidgets('a full allowance is explained, kindly', (tester) async {
      final cloud = FakeCloudMemoryRepository()
        ..shared = [_sharedBeach]
        ..details['m1'] = detail(canAdd: true);
      await _pumpApp(
        tester,
        cloud,
        picker: FakePhotoPickerService([
          Uint8List.fromList([1]),
        ]),
      );
      await _openShared(tester);
      await tester.tap(find.text('Beach day'));
      await tester.pumpAndSettle();

      cloud.failNext = const SharingFailure(
        SharingFailureKind.storageFull,
        'Your online storage is full. Remove the online copy of a memory to '
        'make room.',
      );
      await tester.ensureVisible(find.text('Add your photos'));
      await tester.tap(find.text('Add your photos'));
      await tester.pumpAndSettle();

      expect(find.textContaining('storage is full'), findsOneWidget);
    });
  });

  group('inviting a friend to a quest', () {
    testWidgets('explains, then makes a code', (tester) async {
      final quests = FakeCloudQuestRepository();
      await _pumpQuestSheet(tester, quests);

      expect(find.text('Do this quest together'), findsOneWidget);
      expect(find.textContaining('add their own photos'), findsOneWidget);

      await tester.tap(find.text('Create an invite code'));
      await tester.pumpAndSettle();

      expect(find.text('QUEST-CODE1'), findsOneWidget);
      expect(quests.calls, contains('createInvite:quest-1'));
    });

    testWidgets(
      'shows who has joined or is still deciding, and can remove them',
      (tester) async {
        final quests = FakeCloudQuestRepository()
          ..participants = [
            ShareViewer(
              id: 'f1',
              name: 'Bo',
              sharedAt: DateTime(2026, 10, 1),
              status: 'Joined',
            ),
            ShareViewer(
              id: 'f2',
              name: 'Cass',
              sharedAt: DateTime(2026, 10, 2),
              status: 'Invited',
            ),
          ];
        await _pumpQuestSheet(tester, quests);

        expect(find.text("Who's taking part"), findsOneWidget);
        expect(find.text('Joined'), findsOneWidget);
        expect(find.text('Invited'), findsOneWidget);

        await tester.tap(find.byTooltip('Remove Bo from this quest'));
        await tester.pumpAndSettle();

        expect(quests.calls, contains('removeParticipant:f1'));
        expect(find.text('Bo'), findsNothing);
        expect(find.text('Cass'), findsOneWidget);
      },
    );

    testWidgets('a quest that can not be shared says why', (tester) async {
      final quests = FakeCloudQuestRepository()
        ..failNext = const SharingFailure.unknown(
          "A quest you do on your own can't be shared. Pick a pair or group "
          'quest.',
        );
      await _pumpQuestSheet(tester, quests);

      await tester.tap(find.text('Create an invite code'));
      await tester.pumpAndSettle();

      expect(find.textContaining('on your own'), findsOneWidget);
      expect(find.text('Create an invite code'), findsOneWidget);
    });
  });

  group('taking the online copy away', () {
    testWidgets('is offered only when the memory is online', (tester) async {
      final cloud = FakeCloudMemoryRepository();
      await _pumpSheet(tester, cloud);
      expect(find.text('Remove the online copy'), findsNothing);
    });

    testWidgets('asks first, then removes it', (tester) async {
      final cloud = FakeCloudMemoryRepository()
        ..online = true
        ..viewers = [
          ShareViewer(id: 'f1', name: 'Bo', sharedAt: DateTime(2026, 10, 1)),
        ];
      await _pumpSheet(tester, cloud);
      expect(find.text('Remove the online copy'), findsOneWidget);

      await tester.tap(find.text('Remove the online copy'));
      await tester.pumpAndSettle();
      expect(find.text('Remove the online copy?'), findsOneWidget);

      await tester.tap(find.text('Keep it'));
      await tester.pumpAndSettle();
      expect(
        cloud.calls.where((c) => c.startsWith('removeOnlineCopy')),
        isEmpty,
      );

      await tester.tap(find.text('Remove the online copy'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Remove it'));
      await tester.pumpAndSettle();

      expect(cloud.calls, contains('removeOnlineCopy:memory-1'));
      expect(find.text('Remove the online copy'), findsNothing);
      expect(find.text('Bo'), findsNothing, reason: 'nobody can see it now');
      expect(find.text('Create an invite code'), findsOneWidget);
    });

    testWidgets('a failure is explained and the copy stays', (tester) async {
      final cloud = FakeCloudMemoryRepository()..online = true;
      await _pumpSheet(tester, cloud);

      cloud.failNext = const SharingFailure.unknown(
        "We couldn't do that just now. Please try again.",
      );
      await tester.tap(find.text('Remove the online copy'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Remove it'));
      await tester.pumpAndSettle();

      expect(find.textContaining("couldn't do that"), findsOneWidget);
      expect(find.text('Remove the online copy'), findsOneWidget);
    });
  });

  group('backup in Settings', () {
    Future<void> openSettings(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
    }

    testWidgets('is off by default and shows the storage allowance', (
      tester,
    ) async {
      await _pumpApp(tester, FakeCloudMemoryRepository());
      await openSettings(tester);

      expect(find.text('Back up my memories'), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
      expect(find.text('12 MB of 100 MB used'), findsOneWidget);
      expect(
        find.textContaining('originals stay on this phone'),
        findsOneWidget,
      );
    });

    testWidgets('the switch is remembered', (tester) async {
      final container = await _pumpApp(tester, FakeCloudMemoryRepository());
      await openSettings(tester);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      expect(
        await container.read(settingsRepositoryProvider).getBackupEnabled(),
        isTrue,
      );

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(
        await container.read(settingsRepositoryProvider).getBackupEnabled(),
        isFalse,
      );
    });

    testWidgets('with nothing to back up it says so', (tester) async {
      await _pumpApp(tester, FakeCloudMemoryRepository());
      await openSettings(tester);

      await tester.tap(find.text('Back up now'));
      await tester.pumpAndSettle();

      expect(find.text('You have no memories to back up yet.'), findsOneWidget);
    });

    testWidgets('"Back up now" saves every memory, on any connection', (
      tester,
    ) async {
      final cloud = FakeCloudMemoryRepository();
      final container = await _pumpApp(
        tester,
        cloud,
        connectivity: FakeConnectivityService(wifi: false),
      );
      final memories = container.read(memoryRepositoryProvider);
      final db = container.read(appDatabaseProvider);
      final quest = (await db.questDao.getAllQuests()).first;
      for (final day in [1, 2]) {
        final session = await memories.startQuestSession(quest.id);
        await memories.createMemory(
          questSessionId: session,
          title: 'Day $day',
          capturedAt: DateTime(2026, 9, day),
          personIds: const [],
        );
      }
      await openSettings(tester);

      await tester.tap(find.text('Back up now'));
      await tester.pumpAndSettle();

      expect(cloud.calls.where((c) => c.startsWith('backUp:')), hasLength(2));
      expect(
        find.text('All 2 of your memories are backed up.'),
        findsOneWidget,
      );
    });

    testWidgets('a full allowance tells the person how to make room', (
      tester,
    ) async {
      final cloud = FakeCloudMemoryRepository()
        ..usage = const StorageUsage(
          usedBytes: 100 * 1024 * 1024,
          quotaBytes: 100 * 1024 * 1024,
        );
      final container = await _pumpApp(tester, cloud);
      final memories = container.read(memoryRepositoryProvider);
      final db = container.read(appDatabaseProvider);
      final quest = (await db.questDao.getAllQuests()).first;
      final session = await memories.startQuestSession(quest.id);
      final memory = await memories.createMemory(
        questSessionId: session,
        title: 'Big one',
        capturedAt: DateTime(2026, 9, 1),
        personIds: const [],
      );
      cloud.failuresByMemory[memory.id] = const SharingFailure(
        SharingFailureKind.storageFull,
        'Your online storage is full.',
      );
      await openSettings(tester);
      expect(find.text('100 MB of 100 MB used'), findsOneWidget);

      await tester.tap(find.text('Back up now'));
      await tester.pumpAndSettle();

      expect(find.textContaining('remove its online copy'), findsOneWidget);
    });

    testWidgets('being offline is explained', (tester) async {
      final cloud = FakeCloudMemoryRepository();
      final container = await _pumpApp(tester, cloud);
      final memories = container.read(memoryRepositoryProvider);
      final db = container.read(appDatabaseProvider);
      final quest = (await db.questDao.getAllQuests()).first;
      final session = await memories.startQuestSession(quest.id);
      final memory = await memories.createMemory(
        questSessionId: session,
        title: 'One',
        capturedAt: DateTime(2026, 9, 1),
        personIds: const [],
      );
      cloud.failuresByMemory[memory.id] = const SharingFailure(
        SharingFailureKind.offline,
        "Can't reach Photo Quest right now. Check your connection and try "
        'again.',
      );
      await openSettings(tester);

      await tester.tap(find.text('Back up now'));
      await tester.pumpAndSettle();

      expect(find.textContaining("Can't reach Photo Quest"), findsOneWidget);
    });

    testWidgets('the backup card fits a small phone', (tester) async {
      await _pumpApp(tester, FakeCloudMemoryRepository());
      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpAndSettle();
      await openSettings(tester);

      expect(tester.takeException(), isNull);
    });

    testWidgets('the app catches up on launch only when backup is on', (
      tester,
    ) async {
      final cloud = FakeCloudMemoryRepository();
      final container = await _pumpApp(tester, cloud);
      // Wait for the launch catch-up, which found backup off.
      await container.read(backupCatchUpProvider.future);
      expect(cloud.calls.where((c) => c.startsWith('backUp')), isEmpty);
    });
  });
}
