import 'dart:io';
import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/services/service_providers.dart';
import '../../../memories/data/repositories/memory_repository_provider.dart';

part 'memory_reveal_view_model.g.dart';

class MemoryRevealResult {
  const MemoryRevealResult({required this.memoryId, required this.stripPath});

  final String memoryId;
  final String stripPath;
}

/// Composes the finished photo strip for a just-completed session and
/// returns the memory it belongs to. See CLAUDE.md §36-37.
@riverpod
Future<MemoryRevealResult> memoryReveal(Ref ref, String sessionId) async {
  final memoryRepo = ref.watch(memoryRepositoryProvider);
  final storage = ref.watch(photoStorageServiceProvider);
  final imageProcessing = ref.watch(imageProcessingServiceProvider);

  final memory = await memoryRepo.getMemoryForSession(sessionId);
  if (memory == null) {
    throw StateError('No memory exists yet for session $sessionId.');
  }

  final photos = await memoryRepo.getPhotos(memory.id);
  final photoBytes = <Uint8List>[];
  for (final photo in photos) {
    final file = File(photo.originalPath);
    if (await file.exists()) {
      photoBytes.add(await file.readAsBytes());
    }
  }

  final stripBytes = await imageProcessing.composePhotoStrip(photoBytes);
  final stripPath = await storage.savePhotoStrip(memory.id, stripBytes);

  return MemoryRevealResult(memoryId: memory.id, stripPath: stripPath);
}
