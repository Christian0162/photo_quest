import 'dart:ui' show Color;

/// A group of avatars to browse, like "Animals".
class AvatarCategory {
  const AvatarCategory(this.id, this.label, this.names);

  final String id;
  final String label;

  /// File names (without `.png`) inside `assets/images/avatars/<id>/`.
  final List<String> names;

  /// The saveable id of each avatar, `<category>/<name>`.
  List<String> get ids => [for (final name in names) '$id/$name'];
}

/// The profile avatars people can choose from, bundled with the app so they
/// work offline. Credits: `assets/images/avatars/CREDITS.md`. See CLAUDE.md
/// §55.
abstract final class AppAvatars {
  static const categories = [
    AvatarCategory('animals', 'Animals', [
      'cat',
      'dog',
      'fox',
      'panda',
      'koala',
      'rabbit',
      'bear',
      'hamster',
      'frog',
      'penguin',
      'unicorn',
      'owl',
    ]),
    AvatarCategory('travel', 'Travel', [
      'airplane',
      'globe',
      'camera',
      'mountain',
      'palm',
      'beach',
      'castle',
      'compass',
      'rocket',
      'ferris-wheel',
      'sailboat',
      'tent',
    ]),
    AvatarCategory('food', 'Food', [
      'pizza',
      'sushi',
      'ice-cream',
      'cupcake',
      'doughnut',
      'avocado',
      'strawberry',
      'coffee',
      'cookie',
      'burger',
      'taco',
      'cherries',
    ]),
    AvatarCategory('nature', 'Nature', [
      'sunflower',
      'blossom',
      'rainbow',
      'cactus',
      'clover',
      'rose',
      'mushroom',
      'seedling',
      'sun',
      'star',
      'cloud',
      'snowflake',
    ]),
    AvatarCategory('fun', 'Fun', [
      'guitar',
      'dice',
      'soccer',
      'palette',
      'books',
      'crown',
      'balloon',
      'gift',
      'headphones',
      'game',
      'party',
      'sparkles',
    ]),
  ];

  /// Every saveable avatar id.
  static final ids = [for (final category in categories) ...category.ids];

  /// The bundled image for [id], or null if [id] isn't one of ours.
  static String? assetFor(String? id) =>
      ids.contains(id) ? 'assets/images/avatars/$id.png' : null;

  /// The category [id] belongs to, or the first one.
  static AvatarCategory categoryOf(String? id) => categories.firstWhere(
    (category) => category.ids.contains(id),
    orElse: () => categories.first,
  );

  /// Soft backgrounds the pictures sit on, so each one reads as a little
  /// sticker. A given avatar always gets the same one.
  static const tints = [
    Color(0xFFFFD9C7),
    Color(0xFFFFE9A8),
    Color(0xFFD5E6D0),
    Color(0xFFFFC8C2),
    Color(0xFFD9E8F5),
    Color(0xFFE6DDF2),
  ];

  static Color tintFor(String id) =>
      tints[id.codeUnits.fold(0, (a, b) => a + b) % tints.length];
}
