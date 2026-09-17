import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../../data/database/app_database.dart' as db;
import '../../../../data/database/daos/quest_dao.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_shot.dart';

/// Source of truth for Quest data. ViewModels depend on this, never on
/// [QuestDao] or [db.AppDatabase] directly. See CLAUDE.md §16.
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
          ),
        )
        .toList();
  }

  Future<void> createQuest(Quest quest) {
    return _dao.insertQuest(
      db.QuestsCompanion.insert(
        id: quest.id.isEmpty ? _uuid.v4() : quest.id,
        title: quest.title,
        category: quest.category,
        description: Value(quest.description),
        coverImagePath: Value(quest.coverImagePath),
        createdAt: quest.createdAt,
        updatedAt: quest.updatedAt,
      ),
    );
  }

  Future<void> deleteQuest(String id) => _dao.deleteQuest(id);

  Quest _toEntity(db.Quest row) {
    return Quest(
      id: row.id,
      title: row.title,
      description: row.description,
      category: row.category,
      coverImagePath: row.coverImagePath,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
