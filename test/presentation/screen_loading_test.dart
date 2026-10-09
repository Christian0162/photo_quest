import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/config/constant/app_theme.dart';
import 'package:photoquest/core/domain/friends/entities/friend.dart';
import 'package:photoquest/core/domain/people/entities/person.dart';
import 'package:photoquest/core/presentation/screen/memories/memories_screen.dart';
import 'package:photoquest/core/presentation/screen/people/people_screen.dart';
import 'package:photoquest/core/presentation/view_model/friends/friends_view_models.dart';
import 'package:photoquest/core/presentation/view_model/memories/memory_list_view_model.dart';
import 'package:photoquest/core/presentation/view_model/people/people_list_view_model.dart';
import 'package:photoquest/core/presentation/widget/molecules/common/md_screen_loading.dart';
import 'package:photoquest/core/presentation/widget/templates/memories/memories_template.dart';
import 'package:photoquest/core/presentation/widget/templates/people/people_template.dart';
import 'package:photoquest/core/presentation/widget/templates/preview_samples.dart';

Widget _screen(Widget screen, List overrides) => ProviderScope(
  overrides: [...overrides],
  child: MaterialApp(theme: AppTheme.light, home: screen),
);

class _NoPeople extends PeopleList {
  @override
  Future<List<Person>> build() async => const [];
}

void main() {
  testWidgets('while memories load, only the loader shows, not the page', (
    tester,
  ) async {
    final pending = Completer<List<Never>>();
    await tester.pumpWidget(
      _screen(const MemoriesScreen(), [
        memoryListProvider.overrideWith((ref) => pending.future),
      ]),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MdScreenLoading), findsOneWidget);
    expect(find.text('Memories'), findsNothing);

    pending.complete(const []);
    await tester.pumpAndSettle();

    expect(find.byType(MdScreenLoading), findsNothing);
    expect(find.text('Memories'), findsOneWidget);
  });

  testWidgets('People waits for the friends too, not just the local people', (
    tester,
  ) async {
    final friends = Completer<List<Friend>>();
    await tester.pumpWidget(
      _screen(const PeopleScreen(), [
        peopleListProvider.overrideWith(_NoPeople.new),
        friendsProvider.overrideWith((ref) => friends.future),
      ]),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(MdScreenLoading), findsOneWidget);
    expect(find.text('People'), findsNothing);

    friends.complete(const []);
    await tester.pumpAndSettle();

    expect(find.byType(MdScreenLoading), findsNothing);
    expect(find.text('People'), findsOneWidget);
  });

  testWidgets('pulling down refreshes Memories and People', (tester) async {
    var memoriesRefreshed = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MemoriesTemplate(
          box: AsyncData(PreviewSamples.memoryBox()),
          now: PreviewSamples.today,
          onFilterChanged: (_) {},
          onRetry: () {},
          onRefresh: () async => memoriesRefreshed++,
          onStartQuest: () {},
          onOpenMemory: (_) {},
          onViewPhoto: (_, _) {},
          onOpenShared: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
    expect(memoriesRefreshed, 1);

    var peopleRefreshed = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: PeopleTemplate(
          people: const AsyncData<List<Person>>([]),
          onRetry: () {},
          onRefresh: () async => peopleRefreshed++,
          onAddPerson: () {},
          friends: const AsyncData<List<Friend>>([]),
          onAddFriend: () {},
          onRespondToFriend: (_, {required accept}) {},
          onRemoveFriend: (_) {},
          onRetryFriends: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
    expect(peopleRefreshed, 1);
  });
}
