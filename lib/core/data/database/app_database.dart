import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/memory_dao.dart';
import 'daos/people_dao.dart';
import 'daos/quest_dao.dart';
import 'seed/default_quests_seed.dart';
import 'tables/memories_table.dart';
import 'tables/memory_people_table.dart';
import 'tables/people_table.dart';
import 'tables/photos_table.dart';
import 'tables/quest_participants_table.dart';
import 'tables/quest_sessions_table.dart';
import 'tables/quest_shots_table.dart';
import 'tables/quests_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    People,
    Quests,
    QuestShots,
    QuestParticipants,
    QuestSessions,
    Memories,
    Photos,
    MemoryPeople,
  ],
  daos: [QuestDao, MemoryDao, PeopleDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedDefaultQuests(this);
    },
    onUpgrade: (m, from, to) async {
      // v1 -> v2: quest participants/invitations (CLAUDE.md §16A, §18).
      if (from < 2) {
        await m.addColumn(quests, quests.creatorId);
        await m.addColumn(quests, quests.type);
        await m.addColumn(quests, quests.status);
        await m.addColumn(quests, quests.maxParticipants);
        await m.addColumn(questShots, questShots.exampleImagePath);
        await m.addColumn(questShots, questShots.required);
        await m.createTable(questParticipants);
      }
    },
    // Future schema changes add a step here rather than recreating
    // tables. See CLAUDE.md §49.
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'photoquest');
  }
}
