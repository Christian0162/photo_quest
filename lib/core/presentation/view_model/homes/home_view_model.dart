import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_view_model.g.dart';

/// A time-of-day greeting for the top of Home. See CLAUDE.md §31.
@riverpod
String homeGreeting(Ref ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}
