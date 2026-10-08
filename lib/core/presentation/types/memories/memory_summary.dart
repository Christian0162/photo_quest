import '../../../domain/memories/entities/memory.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../domain/people/entities/person.dart';

/// A Memory as shown in a collection: its cover photo, its photos, the
/// people who were there and the kind of quest it came from.
class MemorySummary {
  const MemorySummary({
    required this.memory,
    required this.coverPhoto,
    required this.people,
    this.photos = const [],
    this.questCategory,
  });

  final Memory memory;

  final Photo? coverPhoto;
  final List<Person> people;

  final List<Photo> photos;

  /// The category of the Quest this memory came from ("For Us", ...), used
  /// to pick its occasion. Null if the quest has since been deleted.
  final String? questCategory;

  String get description {
    final note = memory.note?.trim();
    if (note != null && note.isNotEmpty) return note;

    final others = [
      for (final person in people)
        if (person.type != 'self') person.name,
    ];
    return switch (others.length) {
      0 => 'Just you, and a moment worth keeping.',
      1 => 'You and ${others[0]}, together.',
      2 => 'You, ${others[0]} and ${others[1]}, together.',
      _ => 'You, ${others[0]}, ${others[1]} and ${others.length - 2} more.',
    };
  }
}
