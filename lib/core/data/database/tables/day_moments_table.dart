import 'package:drift/drift.dart';

/// A private, on-device "Your Day" moment that disappears after 24 hours.
/// Only metadata lives here — the image bytes live on the filesystem. Not a
/// Memory: it is never part of a quest. See CLAUDE.md §5, §54A.
class DayMoments extends Table {
  TextColumn get id => text()();
  TextColumn get photoPath => text()();
  TextColumn get thumbnailPath => text()();
  TextColumn get caption => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
