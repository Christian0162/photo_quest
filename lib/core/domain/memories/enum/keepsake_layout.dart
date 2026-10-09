/// How the shots are laid out on the printed keepsake.
enum KeepsakeLayout {
  strip('Strip'),

  grid('Grid'),

  polaroid('Polaroid');

  const KeepsakeLayout(this.label);
  final String label;
}
