import '../../../config/constant/app_constants.dart';
import '../../domain/quests/entities/quest.dart';
import 'cloud_support.dart';
import 'quest_repository.dart';

/// Copies a quest and its shots to the account, only what is missing. Used
/// when a memory is backed up and when someone is invited to a quest, so both
/// leave the quest online the same way. Safe to run again.
class QuestUploader {
  QuestUploader(this._support, this._quests);

  final CloudSupport _support;
  final QuestRepository _quests;

  static const _types = {'solo', 'pair', 'group'};
  static const _statuses = {
    'draft',
    'published',
    'invited',
    'active',
    'completed',
  };

  /// The local quest, or null if it is gone.
  Future<Quest?> questFor(String questId) => _quests.getQuest(questId);

  /// Makes sure the quest and its shots are online. Returns the ids of every
  /// shot that is online afterwards, so photos can point at them.
  Future<Set<String>> backUp(Quest quest) async {
    await _ensureQuest(quest);
    return _ensureShots(quest.id);
  }

  /// How many people a quest holds, owner included. Solo quests have no
  /// room for anyone else; pairs hold two; groups hold what was chosen, or
  /// the app's usual group size. The server enforces it.
  static int? participantLimit(Quest quest) => switch (quest.type) {
    'pair' => 2,
    'group' =>
      (quest.maxParticipants ?? AppConstants.defaultGroupQuestParticipantLimit)
          .clamp(2, 20),
    _ => null,
  };

  Future<void> _ensureQuest(Quest quest) async {
    final db = _support.db;
    final existing = await db
        .from('quests')
        .select('id')
        .eq('id', quest.id)
        .maybeSingle();
    if (existing != null) return;

    await db.from('quests').insert({
      'id': quest.id,
      'owner_id': _support.userId,
      'title': CloudSupport.clamp(quest.title, 100, fallback: 'Quest'),
      'description': CloudSupport.clampOrNull(quest.description, 500),
      'category': CloudSupport.clamp(quest.category, 50, fallback: 'Quest'),
      'type': _types.contains(quest.type) ? quest.type : 'solo',
      'status': _statuses.contains(quest.status) ? quest.status : 'draft',
      'max_participants': participantLimit(quest),
    });
  }

  Future<Set<String>> _ensureShots(String questId) async {
    final db = _support.db;
    final shots = await _quests.getShots(questId);
    final online = await _support.existingIds(
      'quest_shots',
      'quest_id',
      questId,
    );
    final missing = shots.where((shot) => !online.contains(shot.id)).toList();
    if (missing.isNotEmpty) {
      await db.from('quest_shots').insert([
        for (final shot in missing)
          {
            'id': shot.id,
            'quest_id': questId,
            'owner_id': _support.userId,
            'position': shot.position < 0 ? 0 : shot.position,
            'instruction': CloudSupport.clamp(
              shot.instruction,
              200,
              fallback: 'Take a photo',
            ),
            'shot_type': CloudSupport.clamp(
              shot.shotType,
              30,
              fallback: 'group',
            ),
            'required': shot.required,
          },
      ]);
    }
    return {...online, ...missing.map((shot) => shot.id)};
  }
}
