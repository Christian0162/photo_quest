import 'package:drift/drift.dart';

import 'quests_table.dart';

/// One instruction/photo within a Quest. See CLAUDE.md §19-20.
class QuestShots extends Table {
  TextColumn get id => text()();
  TextColumn get questId => text().references(Quests, #id)();
  IntColumn get position => integer()();
  TextColumn get instruction => text()();
  TextColumn get shotType => text()(); // solo, group, candid, close_up, wide
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
