import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/people_repository_provider.dart';
import '../../../domain/people/entities/person.dart';
import '../../../data/repositories/memory_repository_provider.dart';
import '../../../domain/memories/entities/memory.dart';
import '../../../domain/memories/entities/photo.dart';

part 'memory_detail_view_model.g.dart';

class MemoryDetail {
  const MemoryDetail({
    required this.memory,
    required this.photos,
    required this.people,
    required this.questId,
  });

  final Memory memory;
  final List<Photo> photos;
  final List<Person> people;

  /// The Quest this Memory's session belongs to, so "Do This Again" can
  /// start a fresh session on the same Quest. See CLAUDE.md §21, §39.
  final String? questId;
}

@riverpod
Future<MemoryDetail> memoryDetail(Ref ref, String memoryId) async {
  final memoryRepo = ref.watch(memoryRepositoryProvider);
  final peopleRepo = ref.watch(peopleRepositoryProvider);

  final memory = await memoryRepo.getMemory(memoryId);
  if (memory == null) {
    throw StateError('Memory $memoryId was not found.');
  }

  final photos = await memoryRepo.getPhotos(memoryId);
  final personIds = await memoryRepo.getPersonIds(memoryId);
  final people = <Person>[];
  for (final id in personIds) {
    final person = await peopleRepo.getPerson(id);
    if (person != null) people.add(person);
  }

  final session = await memoryRepo.getSession(memory.questSessionId);

  return MemoryDetail(
    memory: memory,
    photos: photos,
    people: people,
    questId: session?.questId,
  );
}
