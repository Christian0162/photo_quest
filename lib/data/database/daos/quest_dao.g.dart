// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_dao.dart';

// ignore_for_file: type=lint
mixin _$QuestDaoMixin on DatabaseAccessor<AppDatabase> {
  $QuestsTable get quests => attachedDatabase.quests;
  $QuestShotsTable get questShots => attachedDatabase.questShots;
  QuestDaoManager get managers => QuestDaoManager(this);
}

class QuestDaoManager {
  final _$QuestDaoMixin _db;
  QuestDaoManager(this._db);
  $$QuestsTableTableManager get quests =>
      $$QuestsTableTableManager(_db.attachedDatabase, _db.quests);
  $$QuestShotsTableTableManager get questShots =>
      $$QuestShotsTableTableManager(_db.attachedDatabase, _db.questShots);
}
