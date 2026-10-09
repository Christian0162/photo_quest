import 'package:drift/drift.dart';

import 'quest_sessions_table.dart';

/// The completed memory produced by a Quest session. See CLAUDE.md §19-20.
class Memories extends Table {
  TextColumn get id => text()();
  TextColumn get questSessionId => text().references(QuestSessions, #id)();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get capturedAt => dateTime()();
  // Not a FK constraint: photos reference memories, so this stays a plain
  // pointer to avoid a circular table dependency.
  TextColumn get coverPhotoId => text().nullable()();

  /// How the printed keepsake is designed (layout, paper, stickers), as
  /// JSON, so it can be re-opened and replayed live. Added in schema v4.
  TextColumn get keepsakeDesign => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
