/// Where someone stands with the signed-in person.
enum FriendStatus { friend, requestedMe, requestedByMe }

/// A real person on Photo Quest (an account), as opposed to the local people
/// and pets kept on this phone.
class Friend {
  const Friend({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.status,
  });

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
