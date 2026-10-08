import '../../domain/moments/entities/day_moment.dart';

/// How long a "Your Day" moment has left, in plain words. See CLAUDE.md §57.
extension MomentTimeLabel on DayMoment {
  String timeLeftLabel(DateTime now) {
    final left = remaining(now);
    if (left.inHours >= 1) return '${left.inHours}h left';
    final minutes = left.inMinutes < 1 ? 1 : left.inMinutes;
    return '${minutes}m left';
  }
}
