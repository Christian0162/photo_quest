import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/data/database/app_database.dart';
import 'package:photoquest/core/data/repositories/memory_repository.dart';
import 'package:photoquest/core/domain/memories/entities/photo.dart';

void main() {
  late AppDatabase db;
  late MemoryRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = MemoryRepository(db.memoryDao);
  });

  tearDown(() => db.close());

  Future<String> startMemory() async {
    final quest = (await db.questDao.getAllQuests()).first;
    final sessionId = await repo.startQuestSession(quest.id);
    final memory = await repo.createMemory(
      questSessionId: sessionId,
      title: quest.title,
      capturedAt: DateTime(2026, 9, 17),
      personIds: const [],
    );
    return memory.id;
  }

  Future<void> addPhoto(String memoryId, String id, int position) {
    return repo.addPhoto(
      id: id,
      memoryId: memoryId,
      originalPath: '/originals/$id.jpg',
      thumbnailPath: '/thumbnails/$id.jpg',
      position: position,
      width: 300,
      height: 400,
    );
  }

  test('retaking a shot deletes only that photo', () async {
    final memoryId = await startMemory();
    await addPhoto(memoryId, 'a', 0);
    await addPhoto(memoryId, 'b', 1);

    await repo.deletePhoto('b');

    final photos = await repo.getPhotos(memoryId);
    expect(photos.map((p) => p.id), ['a']);
  });

  test('photos come back in shot order', () async {
    final memoryId = await startMemory();
    await addPhoto(memoryId, 'second', 1);
    await addPhoto(memoryId, 'first', 0);

    final photos = await repo.getPhotos(memoryId);
    expect(photos.map((p) => p.id), ['first', 'second']);
  });

  test('repeating a quest creates a new session and memory', () async {
    final first = await startMemory();
    final second = await startMemory();

    expect(first, isNot(second));
    expect(await repo.getMemories(), hasLength(2));
  });

  test('a GIF, boomerang or 360° shot keeps its kind and poster', () async {
    final memoryId = await startMemory();
    await repo.addPhoto(
      id: 'spin',
      memoryId: memoryId,
      originalPath: '/videos/spin.mp4',
      thumbnailPath: '/thumbnails/spin.jpg',
      position: 0,
      width: 720,
      height: 1280,
      kind: PhotoKind.video,
    );
    await addPhoto(memoryId, 'still', 1);

    final photos = await repo.getPhotos(memoryId);
    expect(photos.map((p) => p.kind), [PhotoKind.video, PhotoKind.photo]);
    expect(photos.first.stillPath, '/thumbnails/spin.jpg');
    expect(photos.last.stillPath, '/originals/still.jpg');
  });
}
