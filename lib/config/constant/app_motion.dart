import 'package:flutter/widgets.dart';

/// Animation durations and curves. See CLAUDE.md §45, design system §48-50.
abstract final class AppMotion {
  /// Press feedback, toggles.
  static const micro = Duration(milliseconds: 140);

  /// Small state changes (selection, chips).
  static const short = Duration(milliseconds: 220);

  /// Page-level transitions.
  static const medium = Duration(milliseconds: 320);

  /// Emotional reveals (quest complete, memory reveal).
  static const reveal = Duration(milliseconds: 560);

  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeOutBack;

  /// Whether the person asked the OS to reduce motion. Essential state
  /// feedback stays; movement and scale are dropped. See design system §50.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], or zero when reduced motion is on.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
