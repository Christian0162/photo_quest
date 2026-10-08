import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/friends/entities/friend.dart';
import 'cloud_support.dart';

/// Real friends: people with a Photo Quest account, found with a friend code
/// they chose to share. Nobody can search for people, so nobody can check who
/// has an account. A request only becomes a friendship when the other person
/// accepts. Every method throws a `SharingFailure` with copy that is safe to
/// show. See CLAUDE.md §40, §54C.
abstract class CloudFriendsRepository {
  /// My own friend code, to give to people I want as friends.
  Future<String> getMyFriendCode();

  /// Makes a new code; the old one stops working at once.
  Future<String> resetFriendCode();

  /// Sends a request using someone's code. Null when the code doesn't work.
  Future<FriendRequestResult?> addByCode(String code);

  /// Friends, requests waiting for my answer, and requests I'm waiting on.
  Future<List<Friend>> getFriends();

  Future<void> respond(String userId, {required bool accept});

  /// Removes a friend, or cancels a request.
  Future<void> remove(String userId);
}

class SupabaseCloudFriendsRepository implements CloudFriendsRepository {
  SupabaseCloudFriendsRepository({
    required SupabaseClient? client,
    String? Function()? currentUserId,
  }) : _support = CloudSupport(client: client, currentUserId: currentUserId);

  final CloudSupport _support;

  @override
  Future<String> getMyFriendCode() => _support.guard(() async {
    final code = await _support.db.rpc<dynamic>('my_friend_code', params: {});
    return code as String;
  });

  @override
  Future<String> resetFriendCode() => _support.guard(() async {
    final code = await _support.db.rpc<dynamic>(
      'reset_friend_code',
      params: {},
    );
    return code as String;
  });

  @override
  Future<FriendRequestResult?> addByCode(String code) =>
      _support.guard(() async {
        final result = await _support.db.rpc<dynamic>(
          'request_friend',
          params: {'p_code': code},
        );
        if (result is! Map<String, dynamic>) return null;
        return FriendRequestResult(
          userId: result['user_id'] as String,
          name: CloudSupport.nameOf(result['name'] as String?),
          accepted: result['status'] == 'accepted',
        );
      });

  @override
  Future<List<Friend>> getFriends() => _support.guard(() async {
    final db = _support.db;
    final me = _support.userId;
    final rows = await db
        .from('friendships')
        .select('requester_id, addressee_id, status, created_at')
        .order('created_at', ascending: false);

    // A request I declined is kept quietly on record; it isn't a friend.
    final relevant = [
      for (final row in rows)
        if (row['status'] != 'declined') row,
    ];
    if (relevant.isEmpty) return const [];

    String otherOf(Map<String, dynamic> row) => row['requester_id'] == me
        ? row['addressee_id'] as String
        : row['requester_id'] as String;

    final ids = [for (final row in relevant) otherOf(row)];
    final profiles = await db
        .from('profiles')
        .select('id, display_name, avatar_path')
        .inFilter('id', ids);
    final byId = {for (final p in profiles) p['id'] as String: p};
    final avatars = await _support.signedUrls(CloudSupport.avatarsBucket, [
      for (final p in profiles) ?(p['avatar_path'] as String?),
    ]);

    return [
      for (final row in relevant)
        Friend(
          id: otherOf(row),
          name: CloudSupport.nameOf(
            byId[otherOf(row)]?['display_name'] as String?,
          ),
          avatarUrl: avatars[byId[otherOf(row)]?['avatar_path']],
          status: row['status'] == 'accepted'
              ? FriendStatus.friend
              : row['requester_id'] == me
              ? FriendStatus.requestedByMe
              : FriendStatus.requestedMe,
        ),
    ];
  });

  @override
  Future<void> respond(String userId, {required bool accept}) =>
      _support.guard(() async {
        await _support.db.rpc<dynamic>(
          'respond_to_friend_request',
          params: {'p_user': userId, 'p_accept': accept},
        );
      });

  @override
  Future<void> remove(String userId) => _support.guard(() async {
    final db = _support.db;
    final me = _support.userId;
    // The server only lets me see (and so remove) my own friendships.
    final rows = await db
        .from('friendships')
        .select('id, requester_id, addressee_id');
    for (final row in rows) {
      final pair = {row['requester_id'], row['addressee_id']};
      if (pair.contains(userId) && pair.contains(me)) {
        await db.from('friendships').delete().eq('id', row['id'] as String);
      }
    }
  });
}
