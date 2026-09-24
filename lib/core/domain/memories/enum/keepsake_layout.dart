
/// How the shots are laid out on the printed keepsake. See CLAUDE.md §36.
enum KeepsakeLayout {
  /// The classic tall photobooth strip.
  strip('Strip'),

  /// A two-column collage.
  grid('Grid'),

  /// One big instant print of the first shot.
  polaroid('Polaroid');

  const KeepsakeLayout(this.label);
  final String label;
}
