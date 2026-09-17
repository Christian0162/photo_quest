import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/quest_shots_table.dart';
import '../tables/quests_table.dart';

part 'quest_dao.g.dart';

/// All Quest/QuestShot queries live here. Repositories depend on this DAO,
/// never on raw `AppDatabase` queries. See CLAUDE.md §16, §47.
@DriftAccessor(tables: [Quests, QuestShots])
class QuestDao extends DatabaseAccessor<AppDatabase> with _$QuestDaoMixin {
  QuestDao(super.db);

  Future<List<Quest>> getAllQuests() => select(quests).get();

  Future<Quest?> getQuestById(String id) =>
      (select(quests)..where((q) => q.id.equals(id))).getSingleOrNull();

  Future<List<QuestShot>> getShotsForQuest(String questId) {
    return (select(questShots)
          ..where((s) => s.questId.equals(questId))
          ..orderBy([(s) => OrderingTerm.asc(s.position)]))
        .get();
  }

  Future<void> insertQuest(QuestsCompanion quest) => into(quests).insert(quest);

  Future<void> deleteQuest(String id) =>
      (delete(quests)..where((q) => q.id.equals(id))).go();
}
