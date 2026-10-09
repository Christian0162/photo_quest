import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../domain/people/entities/person.dart';
import '../database/app_database.dart' as db;
import '../database/daos/people_dao.dart';

/// Source of truth for Person data. See CLAUDE.md §16.
class PeopleRepository {
  PeopleRepository(this._dao);

  final PeopleDao _dao;
  final _uuid = const Uuid();

  Future<List<Person>> getPeople() async {
    final rows = await _dao.getAllPeople();
    return rows.map(_toEntity).toList();
  }

  Future<Person?> getPerson(String id) async {
    final row = await _dao.getPersonById(id);
    return row == null ? null : _toEntity(row);
  }

  Future<Person?> getSelfPerson() async {
    final row = await _dao.getSelfPerson();
    return row == null ? null : _toEntity(row);
  }

  Future<void> createPerson(Person person) {
    return _dao.insertPerson(
      db.PeopleCompanion.insert(
        id: person.id.isEmpty ? _uuid.v4() : person.id,
        name: person.name,
        type: person.type,
        avatarPath: Value(person.avatarPath),
        createdAt: person.createdAt,
        updatedAt: person.updatedAt,
      ),
    );
  }

  Future<void> deletePerson(String id) => _dao.deletePerson(id);

  Person _toEntity(db.PeopleData row) {
    return Person(
      id: row.id,
      name: row.name,
      type: row.type,
      avatarPath: row.avatarPath,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
