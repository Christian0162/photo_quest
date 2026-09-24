
/// Stickers and props that can be placed on a keepsake. Icon stickers use
/// the app's icon set, stamps use the handwriting face — never emoji.
enum StickerType {
  heart('Heart'),
  star('Star'),
  sparkle('Sparkle'),
  sun('Sun'),
  flower('Flower'),
  camera('Camera'),
  party('Party popper'),
  crown('Crown'),
  paw('Paw print'),
  music('Music note'),
  bestDay('"Best day ever" stamp', stamp: 'Best day ever'),
  together('"Together" stamp', stamp: 'Together'),
  squad('"Squad" stamp', stamp: 'Squad'),
  love('"Love you" stamp', stamp: 'Love you');

  const StickerType(this.label, {this.stamp});

  /// Name read out by screen readers.
  final String label;

  /// The words on a text stamp, or null for an icon sticker.
  final String? stamp;

  bool get isStamp => stamp != null;
}
