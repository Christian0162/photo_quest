import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/quest_participants_table.dart';
import '../tables/quest_shots_table.dart';
import '../tables/quests_table.dart';

part 'quest_dao.g.dart';

/// All Quest/QuestShot/QuestParticipant queries live here. Repositories
/// depend on this DAO, never on raw `AppDatabase` queries. See CLAUDE.md
/// §16, §48.
@DriftAccessor(tables: [Quests, QuestShots, QuestParticipants])
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

  Future<void> insertShot(QuestShotsCompanion shot) =>
      into(questShots).insert(shot);

  Future<void> deleteQuest(String id) =>
      (delete(quests)..where((q) => q.id.equals(id))).go();

  Future<List<QuestParticipant>> getParticipantsForQuest(String questId) {
    return (select(
      questParticipants,
    )..where((p) => p.questId.equals(questId))).get();
  }

  Future<void> insertParticipant(QuestParticipantsCompanion participant) =>
      into(questParticipants).insert(participant);

  Future<void> updateParticipantStatus({
    required String participantId,
    required String status,
    required DateTime respondedAt,
  }) {
    return (update(
      questParticipants,
    )..where((p) => p.id.equals(participantId))).write(
      QuestParticipantsCompanion(
        status: Value(status),
        respondedAt: Value(respondedAt),
      ),
    );
  }

  Future<void> deleteParticipant(String participantId) => (delete(
    questParticipants,
  )..where((p) => p.id.equals(participantId))).go();
}
