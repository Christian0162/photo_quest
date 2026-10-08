import 'package:drift/drift.dart';

import 'memories_table.dart';
import 'quest_shots_table.dart';

/// A single captured image belonging to a Memory. Only metadata lives here —
/// the image bytes live on the filesystem.
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

  TextColumn get kind => text().withDefault(const Constant('photo'))();

  /// True for a 360° clip whose file is not mirrored but whose preview and
  /// poster were, so the viewer flips it to match. Added in schema v5.
  BoolColumn get mirrored => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
