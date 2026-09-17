import 'package:drift/drift.dart';

import 'quests_table.dart';

/// One execution/attempt of a Quest. See CLAUDE.md §19-21.
class QuestSessions extends Table {
  TextColumn get id => text()();
  TextColumn get questId => text().references(Quests, #id)();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => text()(); // in_progress, completed, cancelled

  @override
  Set<Column> get primaryKey => {id};
}
