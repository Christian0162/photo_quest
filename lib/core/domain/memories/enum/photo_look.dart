/// An aesthetic "look" (filter) for photobooth shots. One color matrix is
/// the single source of truth: the live camera preview shows it, and the
/// saved photo is processed with exactly the same numbers, so what you see
/// is what you keep. See CLAUDE.md §7.
///
/// [matrix] is a 4×5 row-major RGBA color matrix with offsets in 0–255 —
/// the same format as Flutter's `ColorFilter.matrix`.
enum PhotoLook {
  natural('Natural', [
    1, 0, 0, 0, 0, //
    0, 1, 0, 0, 0, //
    0, 0, 1, 0, 0, //
    0, 0, 0, 1, 0,
  ]),

  /// Warm, slightly faded, like a disposable camera.
  film('Film', [
    0.95, 0.06, 0, 0, 14, //
    0.02, 0.92, 0.02, 0, 12, //
    0, 0.05, 0.80, 0, 18, //
    0, 0, 0, 1, 0,
  ]),

  /// The classic black-and-white photobooth print.
  mono('Booth B&W', [
    0.244, 0.822, 0.083, 0, -12, //
    0.244, 0.822, 0.083, 0, -12, //
    0.244, 0.822, 0.083, 0, -12, //
    0, 0, 0, 1, 0,
  ]),

  /// Soft pastel: lifted shadows, gentle color.
  dreamy('Dreamy', [
    0.649, 0.182, 0.018, 0, 38, //
    0.054, 0.777, 0.018, 0, 32, //
    0.054, 0.182, 0.613, 0, 36, //
    0, 0, 0, 1, 0,
  ]),

  /// Rich, warm late-afternoon color.
  golden('Golden', [
    1.25, -0.154, -0.016, 0, 6, //
    -0.043, 1.057, -0.014, 0, 4, //
    -0.036, -0.122, 1.008, 0, -4, //
    0, 0, 0, 1, 0,
  ]);

  const PhotoLook(this.label, this.matrix);

  /// Short, friendly name shown in the booth.
  final String label;
  final List<double> matrix;

  bool get isNatural => this == natural;
}
