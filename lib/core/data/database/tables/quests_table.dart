import 'package:drift/drift.dart';

import 'people_table.dart';

/// A reusable guided real-life activity + photobooth experience, with an
/// owner and a participation model. See CLAUDE.md §18-20.
class Quests extends Table {
  TextColumn get id => text()();

  /// The [People] row that created this quest. Null for built-in quest
  /// templates that ship with the app. See CLAUDE.md §18 note.
  TextColumn get creatorId => text().nullable().references(People, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()();

  /// solo, pair, group. See CLAUDE.md §19.
  TextColumn get type => text().withDefault(const Constant('solo'))();

  /// draft, published, invited, active, completed. See CLAUDE.md §16A.
  TextColumn get status => text().withDefault(const Constant('published'))();

  /// Nullable; a configured default applies when null. See CLAUDE.md §15A.
  IntColumn get maxParticipants => integer().nullable()();
  TextColumn get coverImagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
