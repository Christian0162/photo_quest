import 'package:drift/drift.dart';

import 'memories_table.dart';
import 'quest_shots_table.dart';

/// A single captured image belonging to a Memory. Only metadata lives here —
/// the image bytes live on the filesystem. See CLAUDE.md §5, §19.
class Photos extends Table {
  TextColumn get id => text()();
  TextColumn get memoryId => text().references(Memories, #id)();
  TextColumn get shotId => text().nullable().references(QuestShots, #id)();
  TextColumn get originalPath => text()();
  TextColumn get thumbnailPath => text()();
  IntColumn get position => integer()();
  DateTimeColumn get capturedAt => dateTime()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
