/// Centralized 4-point spacing scale.
abstract final class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 8.0;
  static const ms = 12.0;
  static const md = 16.0;
  static const ml = 20.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 40.0;
  static const xxxl = 48.0;
  static const jumbo = 64.0;

  static const gutter = ml;

  /// Bottom padding at the end of a tab screen's scroll, so the last item
  /// settles comfortably above the quest prompt and dock.
  static const tabScrollEnd = xl;

  static const dockHeight = 64.0;
}

/// Centralized corner radii.
///
/// Every card, tile, sheet and photo frame shares [base] (10px); buttons
/// use [button] (15px).
/// [pill] is only for badges, counters, dots and progress bars.
abstract final class AppRadius {
  static const base = 10.0;

  /// Buttons, including the big call-to-action bars, are a little rounder
  /// than cards.
  static const button = 15.0;

  static const pill = 999.0;
}

/// Icon sizes.
abstract final class AppIconSizes {
  static const sm = 16.0;
  static const md = 20.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const hero = 48.0;
}

/// Minimum interactive sizes.
abstract final class AppTouch {
  static const minTarget = 48.0;

  static const buttonHeight = 56.0;

  static const captureButton = 84.0;
}
