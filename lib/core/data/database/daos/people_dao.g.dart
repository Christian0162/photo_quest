// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_dao.dart';

// ignore_for_file: type=lint
mixin _$PeopleDaoMixin on DatabaseAccessor<AppDatabase> {
  $PeopleTable get people => attachedDatabase.people;
  PeopleDaoManager get managers => PeopleDaoManager(this);
}

class PeopleDaoManager {
  final _$PeopleDaoMixin _db;
  PeopleDaoManager(this._db);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db.attachedDatabase, _db.people);
}
