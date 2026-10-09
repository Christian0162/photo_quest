import 'package:drift/drift.dart';

import 'people_table.dart';
import 'quests_table.dart';

/// One Person's membership/invitation status on one Quest. See CLAUDE.md
/// §16A, §18-20.
class QuestParticipants extends Table {
  TextColumn get id => text()();
  TextColumn get questId => text().references(Quests, #id)();
  TextColumn get personId => text().references(People, #id)();

  /// invited, accepted, declined, removed, completed. See CLAUDE.md §16A.
  TextColumn get status => text().withDefault(const Constant('invited'))();
  DateTimeColumn get invitedAt => dateTime()();
  DateTimeColumn get respondedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
