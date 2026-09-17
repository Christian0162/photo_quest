// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_dao.dart';

// ignore_for_file: type=lint
mixin _$QuestDaoMixin on DatabaseAccessor<AppDatabase> {
  $PeopleTable get people => attachedDatabase.people;
  $QuestsTable get quests => attachedDatabase.quests;
  $QuestShotsTable get questShots => attachedDatabase.questShots;
  $QuestParticipantsTable get questParticipants =>
      attachedDatabase.questParticipants;
  QuestDaoManager get managers => QuestDaoManager(this);
}

class QuestDaoManager {
  final _$QuestDaoMixin _db;
  QuestDaoManager(this._db);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db.attachedDatabase, _db.people);
  $$QuestsTableTableManager get quests =>
      $$QuestsTableTableManager(_db.attachedDatabase, _db.quests);
  $$QuestShotsTableTableManager get questShots =>
      $$QuestShotsTableTableManager(_db.attachedDatabase, _db.questShots);
  $$QuestParticipantsTableTableManager get questParticipants =>
      $$QuestParticipantsTableTableManager(
        _db.attachedDatabase,
        _db.questParticipants,
      );
}
