/// Where someone stands with the signed-in person.
enum FriendStatus {
  /// Both said yes: they can be invited straight from People.
  friend,

  /// They asked me, and I haven't answered yet.
  requestedMe,

  /// I asked them, and they haven't answered yet.
  requestedByMe,
}

/// A real person on Photo Quest (an account), as opposed to the local people
/// and pets kept on this phone.
class Friend {
  const Friend({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.status,
  });

  /// Their account id. Only ever used to talk to the server; never shown.
  final String id;
  final String name;
  final String? avatarUrl;
  final FriendStatus status;

  bool get isFriend => status == FriendStatus.friend;
}

/// What happened when a friend code was entered.
class FriendRequestResult {
  const FriendRequestResult({
    required this.userId,
    required this.name,
    required this.accepted,
  });

  final String userId;
  final String name;

  /// True when you are now friends (they had already asked you, or already
  /// were). False when the request is waiting for them to answer.
  final bool accepted;
}
