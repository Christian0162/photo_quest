import 'package:drift/drift.dart';

import 'quests_table.dart';

/// One instruction/photo within a Quest.
class QuestShots extends Table {
  TextColumn get id => text()();
  TextColumn get questId => text().references(Quests, #id)();
  IntColumn get position => integer()();
  TextColumn get instruction => text()();
  TextColumn get shotType => text()(); // solo, group, candid, close_up, wide

  TextColumn get exampleImagePath => text().nullable()();

  BoolColumn get required => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
