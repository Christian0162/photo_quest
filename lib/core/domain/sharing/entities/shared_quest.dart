import 'shared_memory.dart';

/// Where a friend stands on a quest someone invited them to.
enum ParticipationStatus {
  invited,
  accepted,
  declined;

  static ParticipationStatus parse(String? value) => switch (value) {
    'accepted' => accepted,
    'declined' => declined,
    _ => invited,
  };
}

/// What an invite code turned out to be.
enum InviteKind { memory, quest }

class InviteTarget {
  const InviteTarget(this.kind, this.id);

  final InviteKind kind;
  final String id;
}

/// A quest a friend invited me to, or that I'm taking part in, as a card.
class SharedQuestSummary {
  const SharedQuestSummary({
    required this.id,
    required this.title,
    this.description,
    required this.ownerName,
    required this.status,
  });

  final String id;
  final String title;
  final String? description;
  final String ownerName;
  final ParticipationStatus status;
}

/// A shared quest, opened: what it is, who is in, and the memories made so far
/// (which only people who have accepted can see).
class SharedQuestDetail {
  const SharedQuestDetail({
    required this.id,
    required this.title,
    this.description,
    required this.ownerName,
    this.ownerAvatarUrl,
    required this.status,
    required this.shots,
    required this.participants,
    required this.memories,
  });

  final String id;
  final String title;
  final String? description;
  final String ownerName;
  final String? ownerAvatarUrl;
  final ParticipationStatus status;

  /// The instruction of each shot, in order.
  final List<String> shots;

  /// Everyone I'm allowed to see besides the owner.
  final List<ShareViewer> participants;
  final List<SharedMemorySummary> memories;
}

/// How much online photo storage a person has used.
class StorageUsage {
  const StorageUsage({required this.usedBytes, required this.quotaBytes});

  final int usedBytes;
  final int quotaBytes;

  bool get isFull => usedBytes >= quotaBytes;

  /// 0 to 1, for a progress bar.
  double get fraction =>
      quotaBytes <= 0 ? 0 : (usedBytes / quotaBytes).clamp(0.0, 1.0);

  /// "12 MB of 100 MB used".
  String get label => '${_mb(usedBytes)} of ${_mb(quotaBytes)} used';

  static String _mb(int bytes) {
    final megabytes = bytes / (1024 * 1024);
    if (megabytes >= 10 || megabytes == megabytes.roundToDouble()) {
      return '${megabytes.round()} MB';
    }
    return '${megabytes.toStringAsFixed(1)} MB';
  }
}
