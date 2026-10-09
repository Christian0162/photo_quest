import '../../../domain/memories/entities/memory.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../domain/people/entities/person.dart';

class MemoryDetail {
  const MemoryDetail({
    required this.memory,
    required this.photos,
    required this.people,
    required this.questId,
    required this.stripPath,
  });

  final Memory memory;
  final List<Photo> photos;
  final List<Person> people;

  /// The Quest this Memory's session belongs to, so "Do This Again" can
  /// start a fresh session on the same Quest.
  final String? questId;

  final String? stripPath;
}
