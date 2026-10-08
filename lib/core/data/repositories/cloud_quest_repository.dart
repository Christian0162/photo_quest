import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/constant/app_constants.dart';
import '../../domain/sharing/entities/shared_memory.dart';
import '../../domain/sharing/entities/shared_quest.dart';
import '../../errors/app_failure.dart';
import 'cloud_support.dart';
import 'quest_repository.dart';
import 'quest_uploader.dart';

/// Taking part in a quest together: inviting friends with a code, answering an
/// invitation, and seeing a quest you are in. Joining a quest also lets you
/// see the memories made from it and add your own photos (see
/// `CloudMemoryRepository`). Every method throws a [SharingFailure] with copy
/// that is safe to show. See CLAUDE.md §16A, §41, §54C.
abstract class CloudQuestRepository {
  /// Puts the quest online if needed, then makes a code a friend can use to
  /// be invited to it. Shown once.
  Future<String> createInvite(String questId);

  /// Puts the quest online if needed, then invites a real friend (someone
  /// added in People) straight to it, with no code. They still choose to
  /// accept.
  Future<void> inviteFriend(String questId, String friendId);

  /// Quests I've been invited to or have joined, newest first.
  Future<List<SharedQuestSummary>> getMyQuests();

  Future<SharedQuestDetail> getQuest(String questId);

  /// Accepts or declines an invitation.
  Future<void> respond(String questId, {required bool accept});

  /// Stops taking part in a quest.
  Future<void> leave(String questId);

  /// Friends I've invited to one of my quests, and whether they've said yes.
  Future<List<ShareViewer>> getParticipants(String questId);

  Future<void> removeParticipant(String questId, String userId);
}

class SupabaseCloudQuestRepository implements CloudQuestRepository {
  SupabaseCloudQuestRepository({
    required SupabaseClient? client,
    required QuestRepository quests,
    String? Function()? currentUserId,
  }) : _support = CloudSupport(client: client, currentUserId: currentUserId) {
    _uploader = QuestUploader(_support, quests);
  }

  final CloudSupport _support;
  late final QuestUploader _uploader;

  @override
  Future<String> createInvite(String questId) => _support.guard(() async {
    final quest = await _uploader.questFor(questId);
    if (quest == null) {
      throw const SharingFailure(
        SharingFailureKind.notFound,
        "We couldn't find that quest.",
      );
    }
    await _uploader.backUp(quest);
    final code = await _support.db.rpc<dynamic>(
      'create_quest_invite',
      params: {
        'p_quest_id': questId,
        'p_valid_days': AppConstants.inviteValidDays,
        'p_max_uses': AppConstants.inviteMaxUses,
      },
    );
    return code as String;
  });

  @override
  Future<void> inviteFriend(String questId, String friendId) =>
      _support.guard(() async {
        final quest = await _uploader.questFor(questId);
        if (quest == null) {
          throw const SharingFailure(
            SharingFailureKind.notFound,
            "We couldn't find that quest.",
          );
        }
        await _uploader.backUp(quest);
        await _support.db.rpc<dynamic>(
          'invite_friend_to_quest',
          params: {'p_quest': questId, 'p_friend': friendId},
        );
      });

  @override
  Future<List<SharedQuestSummary>> getMyQuests() => _support.guard(() async {
    final db = _support.db;
    final mine = await db
        .from('quest_participants')
        .select('quest_id, status, invited_at')
        .eq('user_id', _support.userId)
        .inFilter('status', ['invited', 'accepted'])
        .order('invited_at', ascending: false);
    if (mine.isEmpty) return const [];

    final statuses = {
      for (final row in mine)
        row['quest_id'] as String: ParticipationStatus.parse(
          row['status'] as String?,
        ),
    };
    final quests = await db
        .from('quests')
        .select('id, owner_id, title, description')
        .inFilter('id', statuses.keys.toList());
    final names = await _support.profileNames([
      for (final q in quests) q['owner_id'] as String,
    ]);
    final byId = {for (final q in quests) q['id'] as String: q};

    return [
      for (final row in mine)
        if (byId[row['quest_id']] case final q?)
          SharedQuestSummary(
            id: q['id'] as String,
            title: q['title'] as String,
            description: q['description'] as String?,
            ownerName: names[q['owner_id']] ?? 'A friend',
            status: statuses[q['id']]!,
          ),
    ];
  });

  @override
  Future<SharedQuestDetail> getQuest(String questId) =>
      _support.guard(() async {
        final db = _support.db;
        final quest = await db
            .from('quests')
            .select('id, owner_id, title, description')
            .eq('id', questId)
            .maybeSingle();
        if (quest == null) {
          throw const SharingFailure(
            SharingFailureKind.notFound,
            'This quest is no longer shared with you.',
          );
        }
        final ownerId = quest['owner_id'] as String;

        final mine = await db
            .from('quest_participants')
            .select('status')
            .eq('quest_id', questId)
            .eq('user_id', _support.userId)
            .maybeSingle();
        final status = ParticipationStatus.parse(mine?['status'] as String?);

        final owner = await db
            .from('profiles')
            .select('display_name, avatar_path')
            .eq('id', ownerId)
            .maybeSingle();
        final avatarPath = owner?['avatar_path'] as String?;
        final avatarUrls = await _support.signedUrls(
          CloudSupport.avatarsBucket,
          [?avatarPath],
        );

        final shotRows = await db
            .from('quest_shots')
            .select('instruction, position')
            .eq('quest_id', questId)
            .order('position', ascending: true);

        final participants = await _participantsOf(questId, ownerId: ownerId);

        // Memories made from this quest: only people who have accepted can see
        // them, so an invitation shows none.
        var memories = <SharedMemorySummary>[];
        if (status == ParticipationStatus.accepted) {
          final sessions = await db
              .from('quest_sessions')
              .select('id')
              .eq('quest_id', questId);
          final sessionIds = [for (final s in sessions) s['id'] as String];
          if (sessionIds.isNotEmpty) {
            final memoryRows = await db
                .from('memories')
                .select('id, owner_id, title, captured_at')
                .inFilter('quest_session_id', sessionIds)
                .order('captured_at', ascending: false);
            memories = await _support.memorySummaries(memoryRows);
          }
        }

        return SharedQuestDetail(
          id: questId,
          title: quest['title'] as String,
          description: quest['description'] as String?,
          ownerName: CloudSupport.nameOf(owner?['display_name'] as String?),
          ownerAvatarUrl: avatarUrls[avatarPath],
          status: status,
          shots: [for (final s in shotRows) s['instruction'] as String],
          participants: participants,
          memories: memories,
        );
      });

  @override
  Future<void> respond(String questId, {required bool accept}) =>
      _support.guard(() async {
        await _support.db.rpc<dynamic>(
          'respond_to_quest_invitation',
          params: {'p_quest_id': questId, 'p_accept': accept},
        );
      });

  @override
  Future<void> leave(String questId) => _support.guard(() async {
    await _support.db
        .from('quest_participants')
        .delete()
        .eq('quest_id', questId)
        .eq('user_id', _support.userId);
  });

  @override
  Future<List<ShareViewer>> getParticipants(String questId) =>
      _support.guard(() => _participantsOf(questId));

  @override
  Future<void> removeParticipant(String questId, String userId) =>
      _support.guard(() async {
        await _support.db
            .from('quest_participants')
            .delete()
            .eq('quest_id', questId)
            .eq('user_id', userId);
      });

  /// Everyone on the quest I'm allowed to see, except me and the owner.
  Future<List<ShareViewer>> _participantsOf(
    String questId, {
    String? ownerId,
  }) async {
    final db = _support.db;
    final rows = await db
        .from('quest_participants')
        .select('user_id, status, invited_at')
        .eq('quest_id', questId)
        .order('invited_at', ascending: true);
    final others = [
      for (final row in rows)
        if (row['user_id'] != _support.userId && row['user_id'] != ownerId) row,
    ];
    if (others.isEmpty) return const [];

    final profiles = await db
        .from('profiles')
        .select('id, display_name, avatar_path')
        .inFilter('id', [for (final r in others) r['user_id'] as String]);
    final byId = {for (final p in profiles) p['id'] as String: p};
    final avatars = await _support.signedUrls(CloudSupport.avatarsBucket, [
      for (final p in profiles) ?(p['avatar_path'] as String?),
    ]);

    return [
      for (final row in others)
        ShareViewer(
          id: row['user_id'] as String,
          name: CloudSupport.nameOf(
            byId[row['user_id']]?['display_name'] as String?,
          ),
          avatarUrl: avatars[byId[row['user_id']]?['avatar_path']],
          sharedAt: DateTime.parse(row['invited_at'] as String).toLocal(),
          status: switch (ParticipationStatus.parse(row['status'] as String?)) {
            ParticipationStatus.accepted => 'Joined',
            ParticipationStatus.declined => 'Declined',
            ParticipationStatus.invited => 'Invited',
          },
        ),
    ];
  }
}
