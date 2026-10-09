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

/// Centralized corner-radius scale.
abstract final class AppRadius {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;

  static const photo = 28.0;

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
