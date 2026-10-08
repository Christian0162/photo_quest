import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/config/constant/app_constants.dart';
import 'package:photoquest/core/data/database/app_database.dart';
import 'package:photoquest/core/data/repositories/day_moment_repository.dart';
import 'package:photoquest/core/data/repositories/settings_repository.dart';
import 'package:photoquest/core/data/services/image/image_processing_service.dart';
import 'package:photoquest/core/data/services/storage/photo_storage_service.dart';
import 'package:photoquest/core/domain/people/enum/mood.dart';

class _FakeStorage extends PhotoStorageService {
  final saved = <String>{};
  final deleted = <String>[];

  @override
  Future<(String, String)> saveMoment(
    String momentId, {
    required List<int> photo,
    required List<int> thumbnail,
  }) async {
    saved.add(momentId);
    return ('/moments/$momentId.jpg', '/moments/$momentId-thumb.jpg');
  }

  @override
  Future<void> deleteMoment(String momentId) async {
    saved.remove(momentId);
    deleted.add(momentId);
  }
}

class _FakeImages extends ImageProcessingService {
  @override
  Future<Uint8List> createThumbnail(Uint8List originalBytes) async =>
      originalBytes;
}

void main() {
  late AppDatabase db;
  late _FakeStorage storage;
  late DayMomentRepository repo;
  var now = DateTime(2026, 10, 9, 9);

  setUp(() {
    now = DateTime(2026, 10, 9, 9);
    db = AppDatabase.forTesting(NativeDatabase.memory());
    storage = _FakeStorage();
    repo = DayMomentRepository(
      db.dayMomentDao,
      storage,
      _FakeImages(),
      clock: () => now,
    );
  });

  tearDown(() => db.close());

  final photo = Uint8List.fromList([1, 2, 3]);

  test('a moment lasts exactly 24 hours', () async {
    final moment = await repo.addMoment(photoBytes: photo);

    expect(
      moment.expiresAt.difference(moment.createdAt),
      AppConstants.dayMomentLifetime,
    );
    expect((await repo.getActiveMoments()).map((m) => m.id), [moment.id]);
  });

  test('a moment is gone, files and all, once its 24 hours are up', () async {
    final moment = await repo.addMoment(photoBytes: photo);

    now = now.add(const Duration(hours: 23, minutes: 59));
    expect(await repo.getActiveMoments(), hasLength(1));

    now = now.add(const Duration(minutes: 1));
    expect(await repo.getActiveMoments(), isEmpty);
    expect(storage.deleted, [moment.id]);
    expect(storage.saved, isEmpty);
  });

  test('only the moments past 24 hours go; newer ones stay', () async {
    final old = await repo.addMoment(photoBytes: photo);
    now = now.add(const Duration(hours: 12));
    final recent = await repo.addMoment(photoBytes: photo);

    now = now.add(const Duration(hours: 13));
    final active = await repo.getActiveMoments();

    expect(active.map((m) => m.id), [recent.id]);
    expect(storage.deleted, [old.id]);
  });

  test('moments come back oldest first', () async {
    final first = await repo.addMoment(photoBytes: photo);
    now = now.add(const Duration(hours: 1));
    final second = await repo.addMoment(photoBytes: photo);

    expect((await repo.getActiveMoments()).map((m) => m.id), [
      first.id,
      second.id,
    ]);
  });

  test('a caption is trimmed, and a blank one is dropped', () async {
    final worded = await repo.addMoment(
      photoBytes: photo,
      caption: '  Coffee with Jamie  ',
    );
    final blank = await repo.addMoment(photoBytes: photo, caption: '   ');

    expect(worded.caption, 'Coffee with Jamie');
    expect(blank.caption, isNull);
  });

  test('removing a moment early deletes its files too', () async {
    final moment = await repo.addMoment(photoBytes: photo);

    await repo.deleteMoment(moment.id);

    expect(await repo.getActiveMoments(), isEmpty);
    expect(storage.deleted, [moment.id]);
  });

  test('how you feel is remembered, and can be cleared', () async {
    final settings = SettingsRepository(db.settingsDao);
    expect(await settings.getMood(), isNull);

    await settings.setMood(Mood.sad);
    expect(await settings.getMood(), Mood.sad);

    await settings.setMood(null);
    expect(await settings.getMood(), isNull);
  });
}
