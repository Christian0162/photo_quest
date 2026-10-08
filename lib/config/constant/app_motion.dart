import 'package:flutter/widgets.dart';

/// Animation durations and curves.
abstract final class AppMotion {
  static const micro = Duration(milliseconds: 140);

  static const short = Duration(milliseconds: 220);

  static const medium = Duration(milliseconds: 320);

  static const reveal = Duration(milliseconds: 560);

  static const pop = Duration(milliseconds: 640);

  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeOutBack;

  static const spring = Curves.elasticOut;

  /// Whether the person asked the OS to reduce motion. Essential state
  /// feedback stays; movement and scale are dropped.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
