import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/app.dart';
import 'package:photoquest/config/constant/app_theme.dart';
import 'package:photoquest/core/data/database/app_database.dart'
    show AppDatabase;
import 'package:photoquest/core/data/database/database_providers.dart';
import 'package:photoquest/core/data/repositories/auth_repository_provider.dart';
import 'package:photoquest/core/data/repositories/cloud_memory_repository_provider.dart';
import 'package:photoquest/core/data/repositories/service_providers.dart';
import 'package:photoquest/core/domain/friends/entities/friend.dart';
import 'package:photoquest/core/errors/app_failure.dart';
import 'package:photoquest/core/presentation/screen/sharing/invite_friend_sheet.dart';

import '../support/fake_auth_repository.dart';
import '../support/fake_cloud_memory_repository.dart';

const _bo = Friend(id: 'bo', name: 'Bo', status: FriendStatus.friend);
const _cass = Friend(
  id: 'cass',
  name: 'Cass',
  status: FriendStatus.requestedMe,
);
const _dee = Friend(id: 'dee', name: 'Dee', status: FriendStatus.requestedByMe);

Future<void> _pumpPeople(
  WidgetTester tester,
  FakeCloudFriendsRepository friends, {
  FakeSharingService? sharing,
}) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final db = AppDatabase.forTesting(NativeDatabase.memory());
  addTearDown(db.close);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(signedIn: true),
        ),
        cloudFriendsRepositoryProvider.overrideWithValue(friends),
        cloudMemoryRepositoryProvider.overrideWithValue(
          FakeCloudMemoryRepository(),
        ),
        cloudQuestRepositoryProvider.overrideWithValue(
          FakeCloudQuestRepository(),
        ),
        sharingServiceProvider.overrideWithValue(
          sharing ?? FakeSharingService(),
        ),
      ],
      child: const PhotoQuestApp(),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.bySemanticsLabel('People'));
  await tester.pumpAndSettle();
}

Future<void> _openAddFriend(WidgetTester tester) async {
  await tester.tap(find.text('Add a friend'));
  await tester.pumpAndSettle();
}

Future<void> _typeFriendCode(WidgetTester tester, String code) async {
  await tester.enterText(
    find.widgetWithText(TextField, 'Their friend code'),
    code,
  );
  await tester.pump();
}

/// Just the invite sheets, opened from a button.
Future<void> _pumpSheet(
  WidgetTester tester, {
  required Widget Function(BuildContext) open,
  required List<Override> overrides,
}) async {
  tester.view.physicalSize = const Size(420, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharingServiceProvider.overrideWithValue(FakeSharingService()),
        ...overrides,
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: Builder(builder: open)),
      ),
    ),
  );
  await tester.tap(find.text('Open sheet'));
  await tester.pumpAndSettle();
}

Widget _openButton(VoidCallback onPressed) => Center(
  child: FilledButton(onPressed: onPressed, child: const Text('Open sheet')),
);

void main() {
  group('real friends in People', () {
    testWidgets('start empty, with a way to add someone', (tester) async {
      await _pumpPeople(tester, FakeCloudFriendsRepository());

      expect(find.text('Friends on Photo Quest'), findsOneWidget);
      expect(
        find.text('No friends yet. Share your friend code, or enter theirs.'),
        findsOneWidget,
      );
      expect(find.text('Add a friend'), findsOneWidget);
      // The local people (and pets) are still there too.
      expect(find.text('People'), findsWidgets);
    });

    testWidgets('lists friends, requests to answer and requests waiting', (
      tester,
    ) async {
      await _pumpPeople(
        tester,
        FakeCloudFriendsRepository()..friends = [_cass, _bo, _dee],
      );

      expect(find.text('Cass wants to connect'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
      expect(find.text('Bo'), findsOneWidget);
      expect(find.text('Friend'), findsOneWidget);
      expect(find.text('Dee'), findsOneWidget);
      expect(find.text('Request sent'), findsOneWidget);
    });

    testWidgets('accepting a request makes them a friend', (tester) async {
      final friends = FakeCloudFriendsRepository()..friends = [_cass];
      await _pumpPeople(tester, friends);

      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(friends.calls, contains('respond:cass:true'));
      expect(find.text('Cass wants to connect'), findsNothing);
      expect(find.text('Cass'), findsOneWidget);
      expect(find.text('Friend'), findsOneWidget);
    });

    testWidgets('declining a request removes it', (tester) async {
      final friends = FakeCloudFriendsRepository()..friends = [_cass];
      await _pumpPeople(tester, friends);

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();

      expect(friends.calls, contains('respond:cass:false'));
      expect(find.text('Cass wants to connect'), findsNothing);
    });

    testWidgets('a failed answer is explained and nothing changes', (
      tester,
    ) async {
      final friends = FakeCloudFriendsRepository()..friends = [_cass];
      await _pumpPeople(tester, friends);

      friends.failNext = const SharingFailure(
        SharingFailureKind.notFound,
        'That invitation is no longer open.',
      );
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(find.text('That invitation is no longer open.'), findsOneWidget);
      expect(find.text('Cass wants to connect'), findsOneWidget);
    });

    testWidgets('removing a friend asks first', (tester) async {
      final friends = FakeCloudFriendsRepository()..friends = [_bo];
      await _pumpPeople(tester, friends);

      await tester.tap(find.byTooltip('Remove Bo from your friends'));
      await tester.pumpAndSettle();
      expect(find.text('Remove Bo?'), findsOneWidget);

      await tester.tap(find.text('Keep them'));
      await tester.pumpAndSettle();
      expect(friends.calls.where((c) => c.startsWith('remove')), isEmpty);
      expect(find.text('Bo'), findsOneWidget);

      await tester.tap(find.byTooltip('Remove Bo from your friends'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Remove them'));
      await tester.pumpAndSettle();

      expect(friends.calls, contains('remove:bo'));
      expect(find.text('Bo'), findsNothing);
    });

    testWidgets('a request you sent can be cancelled', (tester) async {
      final friends = FakeCloudFriendsRepository()..friends = [_dee];
      await _pumpPeople(tester, friends);

      await tester.tap(find.byTooltip('Cancel the request to Dee'));
      await tester.pumpAndSettle();
      expect(find.text('Cancel the request?'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(OutlinedButton, 'Cancel the request'),
      );
      await tester.pumpAndSettle();

      expect(friends.calls, contains('remove:dee'));
      expect(find.text('Dee'), findsNothing);
    });

    testWidgets('offline, People still works and says friends can\'t load', (
      tester,
    ) async {
      final friends = FakeCloudFriendsRepository()
        ..failNext = const SharingFailure(
          SharingFailureKind.offline,
          "Can't reach Photo Quest right now.",
        );
      await _pumpPeople(tester, friends);

      expect(find.text("Can't reach your friends right now."), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(
        find.text('No friends yet. Share your friend code, or enter theirs.'),
        findsOneWidget,
      );
    });
  });

  group('adding a friend', () {
    testWidgets('shows your own code and a box for theirs', (tester) async {
      await _pumpPeople(tester, FakeCloudFriendsRepository());
      await _openAddFriend(tester);

      expect(find.text('Your friend code'), findsOneWidget);
      expect(find.text('ABCDE-FGHJK'), findsOneWidget);
      expect(
        find.textContaining('Only people you give it to can find you'),
        findsOneWidget,
      );
      expect(find.text('Their friend code'), findsOneWidget);
      expect(
        find.textContaining('nobody can add you without your OK'),
        findsOneWidget,
      );
    });

    testWidgets('your code can be copied', (tester) async {
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
      await _pumpPeople(tester, FakeCloudFriendsRepository());
      await _openAddFriend(tester);

      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      expect(copied, 'ABCDE-FGHJK');
      expect(find.text('Code copied.'), findsOneWidget);
    });

    testWidgets('your code can be sent in a friendly message', (tester) async {
      final sharing = FakeSharingService();
      await _pumpPeople(tester, FakeCloudFriendsRepository(), sharing: sharing);
      await _openAddFriend(tester);

      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(sharing.sentText, contains('ABCDE-FGHJK'));
      expect(sharing.sentText, contains('Add a friend'));
    });

    testWidgets('a new code is asked about first, then replaces the old', (
      tester,
    ) async {
      final friends = FakeCloudFriendsRepository();
      await _pumpPeople(tester, friends);
      await _openAddFriend(tester);

      await tester.tap(find.text('Get a new code'));
      await tester.pumpAndSettle();
      expect(find.text('Get a new code?'), findsOneWidget);
      expect(find.textContaining('old code stops working'), findsOneWidget);

      await tester.tap(find.text('Keep my code'));
      await tester.pumpAndSettle();
      expect(friends.calls, isNot(contains('resetCode')));
      expect(find.text('ABCDE-FGHJK'), findsOneWidget);

      await tester.tap(find.text('Get a new code'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Get a new code'));
      await tester.pumpAndSettle();

      expect(friends.calls, contains('resetCode'));
      expect(find.text('MNPQR-STVWX'), findsOneWidget);
      expect(find.text('ABCDE-FGHJK'), findsNothing);
    });

    testWidgets('a code that does not load can be retried', (tester) async {
      final friends = FakeCloudFriendsRepository()
        ..failNext = const SharingFailure.unknown();
      await _pumpPeople(tester, friends);
      // The first call to fail is the friends list, so fail the code too.
      friends.failNext = const SharingFailure.unknown();
      await _openAddFriend(tester);

      expect(find.text('Try again'), findsWidgets);
      await tester.tap(find.text('Try again').last);
      await tester.pumpAndSettle();

      expect(find.text('ABCDE-FGHJK'), findsOneWidget);
    });

    testWidgets('an incomplete code is caught before asking the server', (
      tester,
    ) async {
      final friends = FakeCloudFriendsRepository();
      await _pumpPeople(tester, friends);
      await _openAddFriend(tester);

      await _typeFriendCode(tester, 'ABC');
      await tester.tap(find.widgetWithText(FilledButton, 'Send request'));
      await tester.pumpAndSettle();

      expect(find.text('A code has 10 letters and numbers.'), findsOneWidget);
      expect(friends.calls.where((c) => c.startsWith('add')), isEmpty);
    });

    testWidgets('a wrong code says so kindly', (tester) async {
      final friends = FakeCloudFriendsRepository();
      await _pumpPeople(tester, friends);
      await _openAddFriend(tester);

      await _typeFriendCode(tester, 'zzzzz-zzzzz');
      await tester.tap(find.widgetWithText(FilledButton, 'Send request'));
      await tester.pumpAndSettle();

      expect(find.textContaining("That code didn't work"), findsOneWidget);
    });

    testWidgets('a right code sends a request, and it shows in the list', (
      tester,
    ) async {
      final friends = FakeCloudFriendsRepository()
        ..validCodes['MNPQRSTVWX'] = const FriendRequestResult(
          userId: 'bo',
          name: 'Bo',
          accepted: false,
        );
      await _pumpPeople(tester, friends);
      await _openAddFriend(tester);

      await _typeFriendCode(tester, 'mnpqr-stvwx');
      await tester.tap(find.widgetWithText(FilledButton, 'Send request'));
      await tester.pumpAndSettle();

      expect(friends.calls, contains('add:MNPQRSTVWX'));
      expect(
        find.text('Request sent to Bo. They will see it in People.'),
        findsOneWidget,
      );
      // The list behind the sheet shows the request too.
      expect(find.text('Request sent'), findsOneWidget);
    });

    testWidgets(
      'entering the code of someone who already asked you makes you friends',
      (tester) async {
        final friends = FakeCloudFriendsRepository()
          ..validCodes['MNPQRSTVWX'] = const FriendRequestResult(
            userId: 'bo',
            name: 'Bo',
            accepted: true,
          );
        await _pumpPeople(tester, friends);
        await _openAddFriend(tester);

        await _typeFriendCode(tester, 'MNPQRSTVWX');
        await tester.tap(find.widgetWithText(FilledButton, 'Send request'));
        await tester.pumpAndSettle();

        expect(find.text('You and Bo are now friends.'), findsOneWidget);
      },
    );

    testWidgets('guessing too much asks the person to wait', (tester) async {
      final friends = FakeCloudFriendsRepository();
      await _pumpPeople(tester, friends);
      await _openAddFriend(tester);

      friends.failNext = const SharingFailure(
        SharingFailureKind.tooManyTries,
        'Too many tries for now. Please wait a little and try again.',
      );
      await _typeFriendCode(tester, 'MNPQRSTVWX');
      await tester.tap(find.widgetWithText(FilledButton, 'Send request'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Too many tries'), findsOneWidget);
    });

    testWidgets('the sheet fits a small phone with the keyboard open', (
      tester,
    ) async {
      await _pumpPeople(tester, FakeCloudFriendsRepository());
      tester.view.physicalSize = const Size(320, 568);
      await tester.pumpAndSettle();
      await _openAddFriend(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('inviting a friend straight from a sheet', () {
    testWidgets('a memory: friends are listed and one tap shares it', (
      tester,
    ) async {
      final cloud = FakeCloudMemoryRepository();
      final friends = FakeCloudFriendsRepository()
        ..friends = [_bo, _cass, _dee];
      await _pumpSheet(
        tester,
        open: (context) =>
            _openButton(() => showInviteFriendSheet(context, 'memory-1')),
        overrides: [
          cloudMemoryRepositoryProvider.overrideWithValue(cloud),
          cloudFriendsRepositoryProvider.overrideWithValue(friends),
        ],
      );

      // Only real friends, not pending requests.
      expect(find.text('Your friends'), findsOneWidget);
      expect(find.text('Bo'), findsOneWidget);
      expect(find.text('Cass'), findsNothing);
      expect(find.text('Dee'), findsNothing);
      expect(find.text('Or share a code with someone else'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Invite Bo'));
      await tester.pumpAndSettle();

      expect(cloud.calls, contains('shareWithFriend:memory-1:bo'));
      // They are now one of the people who can see it, not offered again.
      expect(find.text('Who can see this'), findsOneWidget);
      expect(find.bySemanticsLabel('Invite Bo'), findsNothing);
    });

    testWidgets('a quest: a friend is invited and shows as invited', (
      tester,
    ) async {
      final quests = FakeCloudQuestRepository();
      final friends = FakeCloudFriendsRepository()..friends = [_bo];
      await _pumpSheet(
        tester,
        open: (context) =>
            _openButton(() => showInviteToQuestSheet(context, 'quest-1')),
        overrides: [
          cloudQuestRepositoryProvider.overrideWithValue(quests),
          cloudFriendsRepositoryProvider.overrideWithValue(friends),
        ],
      );

      await tester.tap(find.bySemanticsLabel('Invite Bo'));
      await tester.pumpAndSettle();

      expect(quests.calls, contains('inviteFriend:quest-1:bo'));
      expect(find.text("Who's taking part"), findsOneWidget);
      expect(find.text('Invited'), findsOneWidget);
    });

    testWidgets('a failure is explained and the friend stays on offer', (
      tester,
    ) async {
      final quests = FakeCloudQuestRepository();
      final friends = FakeCloudFriendsRepository()..friends = [_bo];
      await _pumpSheet(
        tester,
        open: (context) =>
            _openButton(() => showInviteToQuestSheet(context, 'quest-1')),
        overrides: [
          cloudQuestRepositoryProvider.overrideWithValue(quests),
          cloudFriendsRepositoryProvider.overrideWithValue(friends),
        ],
      );

      quests.failNext = const SharingFailure(
        SharingFailureKind.questFull,
        'This quest is full. Ask the person who invited you to make room.',
      );
      await tester.tap(find.bySemanticsLabel('Invite Bo'));
      await tester.pumpAndSettle();

      expect(find.textContaining('This quest is full'), findsOneWidget);
      expect(find.bySemanticsLabel('Invite Bo'), findsOneWidget);
    });

    testWidgets('with no friends the sheet works by code, as before', (
      tester,
    ) async {
      await _pumpSheet(
        tester,
        open: (context) =>
            _openButton(() => showInviteFriendSheet(context, 'memory-1')),
        overrides: [
          cloudMemoryRepositoryProvider.overrideWithValue(
            FakeCloudMemoryRepository(),
          ),
          cloudFriendsRepositoryProvider.overrideWithValue(
            FakeCloudFriendsRepository(),
          ),
        ],
      );

      expect(find.text('Your friends'), findsNothing);
      expect(find.text('Create an invite code'), findsOneWidget);
    });
  });
}
