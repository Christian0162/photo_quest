import 'dart:developer' as developer;
import 'dart:ui' show Rect;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/services/service_providers.dart';
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
    required this.stripPath,
  });

  final Memory memory;
  final List<Photo> photos;
  final List<Person> people;

  /// The Quest this Memory's session belongs to, so "Do This Again" can
  /// start a fresh session on the same Quest. See CLAUDE.md §21, §39.
  final String? questId;

  /// The generated photobooth strip, if one was made. See CLAUDE.md §36.
  final String? stripPath;
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
  final stripPath = await ref
      .watch(photoStorageServiceProvider)
      .findPhotoStrip(memoryId);

  return MemoryDetail(
    memory: memory,
    photos: photos,
    people: people,
    questId: session?.questId,
    stripPath: stripPath,
  );
}

/// Actions on an open Memory; its data lives in [memoryDetailProvider].
@riverpod
class MemoryDetailViewModel extends _$MemoryDetailViewModel {
  @override
  void build(String memoryId) {}

  /// Opens the share sheet for the photo strip — only ever on an explicit
  /// tap. Throws if sharing couldn't open. See CLAUDE.md §11, §56.
  Future<void> shareStrip({Rect? origin}) async {
    final detail = await ref.read(memoryDetailProvider(memoryId).future);
    final stripPath = detail.stripPath;
    if (stripPath == null) return;

    try {
      await ref
          .read(sharingServiceProvider)
          .sharePhoto(
            stripPath,
            text: '${detail.memory.title} · Made with Photo Quest',
            origin: origin,
          );
    } catch (error, stack) {
      developer.log(
        'Sharing failed',
        name: 'photoquest.share',
        error: error,
        stackTrace: stack,
      );
      rethrow;
    }
  }
}
