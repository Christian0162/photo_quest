import 'package:drift/drift.dart';

/// A person (or pet) memories can be tagged with. See CLAUDE.md §19.
class People extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()(); // self, partner, family, friend, pet, other
  TextColumn get avatarPath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
