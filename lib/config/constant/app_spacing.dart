/// Centralized 4-point spacing scale. See CLAUDE.md §27, design system §8.
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

  /// Horizontal page gutter for every screen.
  static const gutter = ml;

  /// Bottom padding at the end of a tab screen's scroll, so the last item
  /// settles comfortably above the dock.
  static const tabScrollEnd = dockHeight + xl + lg;

  /// Height of the floating navigation dock.
  static const dockHeight = 56.0;
}

/// Centralized corner-radius scale. Rounded corners in the app are 10px, and
/// 24px on the floating toast and navigation bar, so pop-ups read as softer:
/// the names stay so each surface keeps saying what it is (a card, a photo,
/// a chip), but they all share one soft, slightly squared look. Only things
/// that are genuinely round (avatars, the shutter) are circles. See
/// CLAUDE.md §27, design system §9.
abstract final class AppRadius {
  static const corner = 10.0;

  static const sm = corner;
  static const md = corner;
  static const lg = corner;
  static const xl = corner;

  /// Large photography and hero surfaces.
  static const photo = corner;

  /// Floating surfaces: the toast and the navigation bar.
  static const floating = 24.0;

  /// Tags, status, compact chips.
  static const pill = corner;
}

/// Icon sizes. See design system §56.
abstract final class AppIconSizes {
  static const sm = 16.0;
  static const md = 20.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const hero = 48.0;
}

/// Minimum interactive sizes. See design system §52, CLAUDE.md §65.
abstract final class AppTouch {
  /// Material/WCAG minimum tap target.
  static const minTarget = 48.0;

  /// Height of full-width primary/secondary buttons.
  static const buttonHeight = 56.0;

  /// The photobooth shutter.
  static const captureButton = 84.0;
}
