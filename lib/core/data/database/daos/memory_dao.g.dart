// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_dao.dart';

// ignore_for_file: type=lint
mixin _$MemoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $PeopleTable get people => attachedDatabase.people;
  $QuestsTable get quests => attachedDatabase.quests;
  $QuestSessionsTable get questSessions => attachedDatabase.questSessions;
  $MemoriesTable get memories => attachedDatabase.memories;
  $QuestShotsTable get questShots => attachedDatabase.questShots;
  $PhotosTable get photos => attachedDatabase.photos;
  $MemoryPeopleTable get memoryPeople => attachedDatabase.memoryPeople;
  MemoryDaoManager get managers => MemoryDaoManager(this);
}

class MemoryDaoManager {
  final _$MemoryDaoMixin _db;
  MemoryDaoManager(this._db);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db.attachedDatabase, _db.people);
  $$QuestsTableTableManager get quests =>
      $$QuestsTableTableManager(_db.attachedDatabase, _db.quests);
  $$QuestSessionsTableTableManager get questSessions =>
      $$QuestSessionsTableTableManager(_db.attachedDatabase, _db.questSessions);
  $$MemoriesTableTableManager get memories =>
      $$MemoriesTableTableManager(_db.attachedDatabase, _db.memories);
  $$QuestShotsTableTableManager get questShots =>
      $$QuestShotsTableTableManager(_db.attachedDatabase, _db.questShots);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db.attachedDatabase, _db.photos);
  $$MemoryPeopleTableTableManager get memoryPeople =>
      $$MemoryPeopleTableTableManager(_db.attachedDatabase, _db.memoryPeople);
}
