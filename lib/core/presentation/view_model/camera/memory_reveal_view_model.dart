import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/memory_repository_provider.dart';
import '../../../data/repositories/people_repository_provider.dart';
import '../../../data/services/service_providers.dart';
import '../../../domain/people/entities/person.dart';

part 'memory_reveal_view_model.g.dart';

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

  /// Who was there — the reveal celebrates people, not just pixels. See
  /// design system §32.
  final List<Person> people;
  final String stripPath;
}

/// Makes sure a just-completed session has a printed strip — composing a
/// default one only if the memory has none yet, so a decorated keepsake is
/// never overwritten — and returns the memory it belongs to. See CLAUDE.md
/// §36-37.
@riverpod
Future<MemoryRevealResult> memoryReveal(Ref ref, String sessionId) async {
  final memoryRepo = ref.watch(memoryRepositoryProvider);
  final peopleRepo = ref.watch(peopleRepositoryProvider);
  final storage = ref.watch(photoStorageServiceProvider);

  final memory = await memoryRepo.getMemoryForSession(sessionId);
  if (memory == null) {
    throw StateError('No memory exists yet for session $sessionId.');
  }

  final stripPath =
      await storage.findPhotoStrip(memory.id) ??
      await _composeDefaultStrip(ref, memory.id, memory.capturedAt);

  final people = <Person>[];
  for (final id in await memoryRepo.getPersonIds(memory.id)) {
    final person = await peopleRepo.getPerson(id);
    if (person != null) people.add(person);
  }

  return MemoryRevealResult(
    memoryId: memory.id,
    title: memory.title,
    capturedAt: memory.capturedAt,
    people: people,
    stripPath: stripPath,
  );
}

Future<String> _composeDefaultStrip(
  Ref ref,
  String memoryId,
  DateTime capturedAt,
) async {
  final photos = await ref.read(memoryRepositoryProvider).getPhotos(memoryId);
  final photoBytes = <Uint8List>[];
  for (final photo in photos) {
    // Stills only: GIFs and clips contribute their poster frame.
    final file = File(photo.stillPath);
    if (await file.exists()) {
      photoBytes.add(await file.readAsBytes());
    }
  }

  final stripBytes = await ref
      .read(imageProcessingServiceProvider)
      .composePhotoStrip(
        photoBytes,
        caption: DateFormat.yMMMd().format(capturedAt).toUpperCase(),
      );
  return ref
      .read(photoStorageServiceProvider)
      .savePhotoStrip(memoryId, stripBytes);
}
