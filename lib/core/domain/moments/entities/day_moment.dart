/// A private "Your Day" moment that disappears after 24 hours. Separate
/// from a Memory: it is not part of a quest and is never kept. See
/// CLAUDE.md §20.
class DayMoment {
  const DayMoment({
    required this.id,
    required this.photoPath,
    required this.thumbnailPath,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
  });

  final String id;
  final String photoPath;
  final String thumbnailPath;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;

  /// How long is left at [now], never negative.
  Duration remaining(DateTime now) {
    final left = expiresAt.difference(now);
    return left.isNegative ? Duration.zero : left;
  }

  bool isExpired(DateTime now) => !expiresAt.isAfter(now);
}
