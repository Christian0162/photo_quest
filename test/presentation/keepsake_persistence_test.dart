import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/data/database/app_database.dart'
    show AppDatabase;
import 'package:photoquest/core/data/database/database_providers.dart';
import 'package:photoquest/core/data/repositories/memory_repository.dart';
import 'package:photoquest/core/data/services/image/image_processing_service.dart';
import 'package:photoquest/core/data/services/service_providers.dart';
import 'package:photoquest/core/data/services/storage/photo_storage_service.dart';
import 'package:photoquest/core/presentation/view_model/memories/keepsake_view_model.dart';

class _MemoryStorage extends PhotoStorageService {
  @override
  Future<String> savePhotoStrip(String memoryId, List<int> bytes) async =>
      '/strips/$memoryId.jpg';
}

class _PassThrough extends ImageProcessingService {
  @override
  Future<Uint8List> encodeKeepsake(Uint8List pngBytes) async => pngBytes;
}

void main() {
  late AppDatabase db;
  late String memoryId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final repo = MemoryRepository(db.memoryDao);
    final quest = (await db.questDao.getAllQuests()).first;
    final memory = await repo.createMemory(
      questSessionId: await repo.startQuestSession(quest.id),
      title: quest.title,
      capturedAt: DateTime(2026, 9, 17),
      personIds: const [],
    );
    memoryId = memory.id;
  });
  tearDown(() => db.close());

  /// A fresh app session on the same database — like opening the memory.
  ProviderContainer session() {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        photoStorageServiceProvider.overrideWithValue(_MemoryStorage()),
        imageProcessingServiceProvider.overrideWithValue(_PassThrough()),
      ],
    );
    addTearDown(container.dispose);
    container.listen(keepsakeViewModelProvider(memoryId), (_, _) {});
    return container;
  }

  for (final layout in [KeepsakeLayout.grid, KeepsakeLayout.polaroid]) {
    test(
      'a saved ${layout.label} still looks like one when reopened',
      () async {
        final designing = session();
        await designing.read(keepsakeViewModelProvider(memoryId).future);
        final designer = designing.read(
          keepsakeViewModelProvider(memoryId).notifier,
        );
        designer
          ..setLayout(layout)
          ..setFrame(KeepsakeFrame.coral)
          ..addSticker(StickerType.heart);
        await designer.save(Uint8List.fromList([1, 2, 3]));

        final reopened = session();
        final design = await reopened.read(
          keepsakeViewModelProvider(memoryId).future,
        );
        expect(design.layout, layout);
        expect(design.frame, KeepsakeFrame.coral);
        expect(design.stickers.map((s) => s.type), [StickerType.heart]);
      },
    );
  }
}
