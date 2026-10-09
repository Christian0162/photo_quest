import '../../../domain/people/entities/person.dart';

class MemoryRevealResult {
  const MemoryRevealResult({
    required this.memoryId,
    required this.title,
    required this.capturedAt,
    required this.people,
    required this.stripPath,
  });

  final String memoryId;
  final String title;
  final DateTime capturedAt;

  final List<Person> people;
  final String stripPath;
}
