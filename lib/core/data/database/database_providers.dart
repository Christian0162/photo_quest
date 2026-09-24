import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';
import 'daos/memory_dao.dart';
import 'daos/people_dao.dart';
import 'daos/quest_dao.dart';
import 'daos/settings_dao.dart';

part 'database_providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

@riverpod
QuestDao questDao(Ref ref) => ref.watch(appDatabaseProvider).questDao;

@riverpod
MemoryDao memoryDao(Ref ref) => ref.watch(appDatabaseProvider).memoryDao;

@riverpod
PeopleDao peopleDao(Ref ref) => ref.watch(appDatabaseProvider).peopleDao;

@riverpod
SettingsDao settingsDao(Ref ref) => ref.watch(appDatabaseProvider).settingsDao;
