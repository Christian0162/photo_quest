import 'package:intl/intl.dart';

/// Human-friendly date phrases shared across screens. See CLAUDE.md §57.

/// How long ago [at] was, in words: "Today", "Yesterday", "3 days ago",
/// "2 weeks ago", "5 months ago", "1 year ago".
String relativeDay(DateTime at, DateTime now) {
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(at.year, at.month, at.day)).inDays;
  String ago(int n, String unit) => n == 1 ? '1 $unit ago' : '$n ${unit}s ago';
  if (days <= 0) return 'Today';
  if (days == 1) return 'Yesterday';
  if (days < 7) return ago(days, 'day');
  if (days < 31) return ago(days ~/ 7, 'week');
  if (days < 365) return ago(days ~/ 30, 'month');
  return ago(days ~/ 365, 'year');
}

/// "SATURDAY, OCT 14 · 8:42 PM" — the day a memory was made, and when.
String memoryMoment(DateTime at) {
  final day = DateFormat('EEEE, MMM d').format(at).toUpperCase();
  // intl puts a narrow no-break space before AM/PM, which the bundled
  // fonts can't draw; a plain space reads the same.
  final time = DateFormat.jm().format(at).replaceAll(_narrowSpace, ' ');
  return '$day · $time';
}

/// The narrow no-break space (U+202F) intl uses before AM/PM.
final _narrowSpace = String.fromCharCode(0x202f);
