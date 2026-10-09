enum CapturePhase {
  instruction,
  countdown,

  /// A GIF burst, boomerang or 360° clip is being recorded.
  capturing,

  /// Turning the burst into a GIF / boomerang, or saving the clip.
  processing,
  captured,
  finishing,
  complete,
}
