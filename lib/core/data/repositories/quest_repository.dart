import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../database/app_database.dart' as db;
import '../database/daos/quest_dao.dart';
import '../../domain/quests/entities/quest.dart';
import '../../domain/quests/entities/quest_participant.dart';
import '../../domain/quests/entities/quest_shot.dart';

/// Source of truth for Quest, Quest Shot and Quest Participant data.
/// ViewModels depend on this, never on [QuestDao] or [db.AppDatabase]
/// directly. See CLAUDE.md §16.
class QuestRepository {
  QuestRepository(this._dao);

  final QuestDao _dao;
  final _uuid = const Uuid();

  Future<List<Quest>> getQuests() async {
    final rows = await _dao.getAllQuests();
    return rows.map(_toEntity).toList();
  }

  Future<Quest?> getQuest(String id) async {
    final row = await _dao.getQuestById(id);
    return row == null ? null : _toEntity(row);
  }

  Future<List<QuestShot>> getShots(String questId) async {
    final rows = await _dao.getShotsForQuest(questId);
    return rows
        .map(
          (r) => QuestShot(
            id: r.id,
            questId: r.questId,
            position: r.position,
            instruction: r.instruction,
            shotType: r.shotType,
            exampleImagePath: r.exampleImagePath,
            required: r.required,
          ),
        )
        .toList();
  }

  Future<void> createQuest(Quest quest) {
    return _dao.insertQuest(
      db.QuestsCompanion.insert(
        id: quest.id.isEmpty ? _uuid.v4() : quest.id,
        creatorId: Value(quest.creatorId),
        title: quest.title,
        category: quest.category,
        description: Value(quest.description),
        type: Value(quest.type),
        status: Value(quest.status),
        maxParticipants: Value(quest.maxParticipants),
        coverImagePath: Value(quest.coverImagePath),
        createdAt: quest.createdAt,
        updatedAt: quest.updatedAt,
      ),
    );
  }

  Future<void> deleteQuest(String id) => _dao.deleteQuest(id);

  /// Invites a Person to participate in a Quest, creating a
  /// [QuestParticipant] with status `invited`. See CLAUDE.md §16A, §59.
  Future<void> inviteParticipant({
    required String questId,
    required String personId,
  }) {
    return _dao.insertParticipant(
      db.QuestParticipantsCompanion.insert(
        id: _uuid.v4(),
        questId: questId,
        personId: personId,
        invitedAt: DateTime.now(),
      ),
    );
  }

  Future<List<QuestParticipant>> getParticipants(String questId) async {
    final rows = await _dao.getParticipantsForQuest(questId);
    return rows
        .map(
          (r) => QuestParticipant(
            id: r.id,
            questId: r.questId,
            personId: r.personId,
            status: r.status,
            invitedAt: r.invitedAt,
            respondedAt: r.respondedAt,
          ),
        )
        .toList();
  }

  /// Records a participant's response to a quest invitation (`accepted`
  /// or `declined`). See CLAUDE.md §16A.
  Future<void> respondToInvitation({
    required String participantId,
    required bool accepted,
  }) {
    return _dao.updateParticipantStatus(
      participantId: participantId,
      status: accepted ? 'accepted' : 'declined',
      respondedAt: DateTime.now(),
    );
  }

  Future<void> removeParticipant(String participantId) =>
      _dao.deleteParticipant(participantId);

  Quest _toEntity(db.Quest row) {
    return Quest(
      id: row.id,
      creatorId: row.creatorId,
      title: row.title,
      description: row.description,
      category: row.category,
      type: row.type,
      status: row.status,
      maxParticipants: row.maxParticipants,
      coverImagePath: row.coverImagePath,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
