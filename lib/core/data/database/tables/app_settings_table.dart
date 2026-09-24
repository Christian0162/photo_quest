import 'package:drift/drift.dart';

/// Small on-device preferences, e.g. the photobooth countdown length.
/// Key-value so new settings need no migration. See CLAUDE.md §5, §19.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
