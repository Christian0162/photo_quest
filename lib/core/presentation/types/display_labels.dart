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
