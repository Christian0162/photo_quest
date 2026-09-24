
/// The paper the keepsake is printed on.
enum KeepsakeFrame {
  cream('Classic'),
  film('Film'),
  coral('Coral'),
  sunny('Sunny'),
  mint('Mint');

  const KeepsakeFrame(this.label);
  final String label;
}
