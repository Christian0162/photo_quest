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
import 'tables/quest_sessions_table.dart';
import 'tables/quest_shots_table.dart';
import 'tables/quests_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    People,
    Quests,
    QuestShots,
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedDefaultQuests(this);
    },
    // Future schema changes add a step here rather than recreating
    // tables. See CLAUDE.md §48.
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'photoquest');
  }
}
