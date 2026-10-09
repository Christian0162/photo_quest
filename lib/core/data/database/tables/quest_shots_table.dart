import 'package:drift/drift.dart';

import 'quests_table.dart';

/// One instruction/photo within a Quest. See CLAUDE.md §19-20.
class QuestShots extends Table {
  TextColumn get id => text()();
  TextColumn get questId => text().references(Quests, #id)();
  IntColumn get position => integer()();
  TextColumn get instruction => text()();
  TextColumn get shotType => text()(); // solo, group, candid, close_up, wide

  /// A visual example of the pose/framing to demonstrate the shot. See
  /// CLAUDE.md §10A.
  TextColumn get exampleImagePath => text().nullable()();

  /// Whether this shot gates quest completion. See CLAUDE.md §37.
  BoolColumn get required => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
