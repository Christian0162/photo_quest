import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/people_table.dart';

part 'people_dao.g.dart';

/// All Person queries live here.
@DriftAccessor(tables: [People])
class PeopleDao extends DatabaseAccessor<AppDatabase> with _$PeopleDaoMixin {
  PeopleDao(super.db);

  Future<List<PeopleData>> getAllPeople() => select(people).get();

  Future<PeopleData?> getPersonById(String id) =>
      (select(people)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<PeopleData?> getSelfPerson() =>
      (select(people)..where((p) => p.type.equals('self'))).getSingleOrNull();

  Future<void> insertPerson(PeopleCompanion person) =>
      into(people).insert(person);

  Future<void> deletePerson(String id) =>
      (delete(people)..where((p) => p.id.equals(id))).go();
}
