import 'dart:developer' as developer;
import 'dart:ui' show Rect;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/memory_repository_provider.dart';
import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/repositories/service_providers.dart';
import '../../../domain/memories/entities/photo.dart';
import '../../../domain/people/entities/person.dart';
import '../../../errors/app_failure.dart';
import '../../types/memories/memory_detail.dart';

part 'memory_detail_view_model.g.dart';

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

  /// Shares one shot as it was captured — the photo, the GIF or
  /// boomerang, or the 360° clip. Throws if sharing couldn't open.
  Future<void> shareShot(Photo photo, {Rect? origin}) async {
    final detail = await ref.read(memoryDetailProvider(memoryId).future);
    final mimeType = photo.isVideo
        ? 'video/mp4'
        : photo.isAnimated
        ? 'image/gif'
        : 'image/jpeg';
    try {
      await ref
          .read(sharingServiceProvider)
          .shareFile(
            photo.originalPath,
            mimeType: mimeType,
            text: '${detail.memory.title} · Made with Photo Quest',
            origin: origin,
          );
    } catch (error, stack) {
      developer.log(
        'Sharing a shot failed',
        name: 'photoquest.share',
        error: error,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// Saves one shot to the phone's photo library, as it was captured —
  /// photo, GIF or boomerang, or 360° clip. Throws a friendly failure.
  Future<void> downloadShot(Photo photo) => ref
      .read(galleryServiceProvider)
      .save(photo.originalPath, isVideo: photo.isVideo);

  /// Saves the printed keepsake to the phone's photo library. Throws a
  /// friendly failure.
  Future<void> downloadStrip() async {
    final detail = await ref.read(memoryDetailProvider(memoryId).future);
    final stripPath = detail.stripPath;
    if (stripPath == null) throw const GallerySaveFailure();
    await ref.read(galleryServiceProvider).save(stripPath, isVideo: false);
  }
}
