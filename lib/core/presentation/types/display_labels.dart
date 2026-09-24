import 'package:flutter/material.dart';

/// Human-facing labels and icons for stored enum-like values, so screens
/// never show raw values like `close_up` or `family`, and every screen
/// describes the same value the same way. See CLAUDE.md §57.

/// Quest participation models (`quests.type`).
const questTypes = [
  ('solo', 'Just me', Icons.person_rounded),
  ('pair', 'The two of us', Icons.favorite_rounded),
  ('group', 'A group', Icons.groups_rounded),
];

String questTypeLabel(String type) => _lookup(questTypes, type).$2;
IconData questTypeIcon(String type) => _lookup(questTypes, type).$3;

/// Shot framings (`quest_shots.shot_type`).
const shotTypes = [
  ('group', 'Group', Icons.groups_rounded),
  ('solo', 'Solo', Icons.person_rounded),
  ('candid', 'Candid', Icons.mood_rounded),
  ('close_up', 'Close-up', Icons.center_focus_strong_rounded),
  ('wide', 'Wide', Icons.landscape_rounded),
];

String shotTypeLabel(String type) => _lookup(shotTypes, type).$2;
IconData shotTypeIcon(String type) => _lookup(shotTypes, type).$3;

/// Relationship types a person can be added with (`people.type`). `self`
/// is created by the app for the device owner, never picked by hand.
const personTypes = [
  ('partner', 'Partner', Icons.favorite_rounded),
  ('family', 'Family', Icons.family_restroom_rounded),
  ('friend', 'Friend', Icons.emoji_people_rounded),
  ('pet', 'Pet', Icons.pets_rounded),
  ('other', 'Someone else', Icons.person_rounded),
];

String personTypeLabel(String type) =>
    type == 'self' ? 'You' : _lookup(personTypes, type).$2;
IconData personTypeIcon(String type) => _lookup(personTypes, type).$3;

/// Heading for a group of people of one type on the People screen.
String personGroupLabel(String type) => switch (type) {
  'partner' => 'Your person',
  'family' => 'Family',
  'friend' => 'Friends',
  'pet' => 'Pets',
  _ => 'Everyone else',
};

/// What kind of day a memory was — "Anniversary", "Birthday", "Family
/// day" — with a matching icon for its card. Read from the memory's title
/// first (it's the most specific), then its quest's category.
(String, IconData) memoryOccasion(String title, String? category) {
  bool has(String text, List<String> words) =>
      words.any(text.toLowerCase().contains);

  for (final text in [title, category ?? '']) {
    if (has(text, ['anniversary'])) {
      return ('Anniversary', Icons.favorite_rounded);
    }
    if (has(text, ['birthday', 'bday'])) {
      return ('Birthday', Icons.cake_rounded);
    }
    if (has(text, ['christmas', 'holiday', 'new year'])) {
      return ('Holiday', Icons.park_rounded);
    }
    if (has(text, ['date'])) return ('Date night', Icons.local_bar_rounded);
    if (has(text, ['wedding'])) return ('Wedding', Icons.diamond_rounded);
    if (has(text, ['trip', 'weekend', 'lake', 'beach', 'adventure'])) {
      return ('Getaway', Icons.luggage_rounded);
    }
    if (has(text, ['dog', 'cat', 'pet', 'park'])) {
      return ('Pet day', Icons.pets_rounded);
    }
    if (has(text, ['family'])) {
      return ('Family day', Icons.family_restroom_rounded);
    }
    if (has(text, ['friend'])) {
      return ('Friends day', Icons.celebration_rounded);
    }
    if (has(text, ['for us', 'couple', 'love'])) {
      return ('Us day', Icons.favorite_rounded);
    }
    if (has(text, ['for me', 'just me', 'solo'])) {
      return ('Me time', Icons.self_improvement_rounded);
    }
  }
  return ('Good day', Icons.wb_sunny_rounded);
}

/// A friendly icon for a quest category ("For Us", "Birthday", ...).
IconData questCategoryIcon(String category) {
  final c = category.toLowerCase();
  if (c.contains('us') || c.contains('date')) return Icons.favorite_rounded;
  if (c.contains('family')) return Icons.family_restroom_rounded;
  if (c.contains('friend')) return Icons.celebration_rounded;
  if (c.contains('memory')) return Icons.auto_awesome_rounded;
  if (c.contains('me')) return Icons.self_improvement_rounded;
  if (c.contains('birthday')) return Icons.cake_rounded;
  if (c.contains('adventure')) return Icons.hiking_rounded;
  if (c.contains('funny')) return Icons.sentiment_very_satisfied_rounded;
  return Icons.auto_awesome_rounded;
}

(String, String, IconData) _lookup(
  List<(String, String, IconData)> options,
  String value,
) {
  return options.firstWhere((o) => o.$1 == value, orElse: () => options.last);
}

/// The example photo, where to focus it, and a short line for a quest
/// category — so "For Us" or "Birthday" shows what that kind of memory looks
/// like. Built-in categories map directly; custom ones by keyword. Null when
/// nothing fits (callers fall back to illustrated art). Credits:
/// `assets/images/quests/CREDITS.md`.
({String asset, Alignment focus, String tagline})? questCategoryExample(
  String category,
) {
  const dir = 'assets/images/quests';
  final c = category.toLowerCase();
  // Whole words, so "Just" isn't "us" and "Memory" isn't "me".
  final words = c.split(RegExp(r'[^a-z]+')).toSet();
  if (words.contains('us') || c.contains('date') || c.contains('anniversary')) {
    return (
      asset: '$dir/for_us.jpg',
      focus: const Alignment(0, -0.3),
      tagline: 'Just the two of you',
    );
  }
  if (c.contains('family') || c.contains('holiday')) {
    return (
      asset: '$dir/for_family.jpg',
      focus: const Alignment(0, 0.1),
      tagline: 'Everyone, all together',
    );
  }
  if (c.contains('friend') || c.contains('birthday') || c.contains('funny')) {
    return (
      asset: '$dir/for_friends.jpg',
      focus: Alignment.center,
      tagline: 'Your people, being silly',
    );
  }
  if (c.contains('memory') || c.contains('life') || c.contains('adventure')) {
    return (
      asset: '$dir/for_life.jpg',
      focus: const Alignment(0, 0.35),
      tagline: 'The ordinary days, too',
    );
  }
  if (words.contains('me') || c.contains('solo')) {
    return (
      asset: '$dir/for_me.jpg',
      focus: const Alignment(0, -0.5),
      tagline: 'A little time for you',
    );
  }
  return null;
}
