import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/people_table.dart';

part 'people_dao.g.dart';

/// All Person queries live here. See CLAUDE.md §16, §47.
@DriftAccessor(tables: [People])
class PeopleDao extends DatabaseAccessor<AppDatabase> with _$PeopleDaoMixin {
  PeopleDao(super.db);

  Future<List<PeopleData>> getAllPeople() => select(people).get();

  Future<PeopleData?> getPersonById(String id) =>
      (select(people)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<void> insertPerson(PeopleCompanion person) =>
      into(people).insert(person);

  Future<void> deletePerson(String id) =>
      (delete(people)..where((p) => p.id.equals(id))).go();
}
