import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../../../config/constant/app_constants.dart';
import '../../domain/moments/entities/day_moment.dart';
import '../database/app_database.dart' as db;
import '../database/daos/day_moment_dao.dart';
import '../services/image/image_processing_service.dart';
import '../services/storage/photo_storage_service.dart';

/// Source of truth for "Your Day" moments: private photos that disappear
/// after 24 hours. See CLAUDE.md §16, §54A.
class DayMomentRepository {
  DayMomentRepository(
    this._dao,
    this._storage,
    this._images, {
    this.clock = DateTime.now,
  });

  final DayMomentDao _dao;
  final PhotoStorageService _storage;
  final ImageProcessingService _images;

  /// What time it is; tests swap this to fast-forward past 24 hours.
  final DateTime Function() clock;
  final _uuid = const Uuid();

  /// The moments still showing, oldest first. Anything past its 24 hours is
  /// removed first, files included.
  Future<List<DayMoment>> getActiveMoments() async {
    await purgeExpired();
    final rows = await _dao.getActive(clock());
    return rows.map(_toEntity).toList();
  }

  /// Keeps [photoBytes] for 24 hours, with an optional [caption].
  Future<DayMoment> addMoment({
    required Uint8List photoBytes,
    String? caption,
  }) async {
    final id = _uuid.v4();
    final now = clock();
    final thumbnail = await _images.createThumbnail(photoBytes);
    final (photoPath, thumbnailPath) = await _storage.saveMoment(
      id,
      photo: photoBytes,
      thumbnail: thumbnail,
    );
    final trimmed = caption?.trim();
    final moment = DayMoment(
      id: id,
      photoPath: photoPath,
      thumbnailPath: thumbnailPath,
      caption: trimmed == null || trimmed.isEmpty ? null : trimmed,
      createdAt: now,
      expiresAt: now.add(AppConstants.dayMomentLifetime),
    );
    await _dao.insertMoment(
      db.DayMomentsCompanion.insert(
        id: moment.id,
        photoPath: moment.photoPath,
        thumbnailPath: moment.thumbnailPath,
        caption: Value(moment.caption),
        createdAt: moment.createdAt,
        expiresAt: moment.expiresAt,
      ),
    );
    return moment;
  }

  Future<void> deleteMoment(String id) async {
    await _dao.deleteById(id);
    await _storage.deleteMoment(id);
  }

  /// Removes every moment whose 24 hours are up, rows and files.
  Future<void> purgeExpired() async {
    for (final row in await _dao.getExpired(clock())) {
      await deleteMoment(row.id);
    }
  }

  DayMoment _toEntity(db.DayMoment row) {
    return DayMoment(
      id: row.id,
      photoPath: row.photoPath,
      thumbnailPath: row.thumbnailPath,
      caption: row.caption,
      createdAt: row.createdAt,
      expiresAt: row.expiresAt,
    );
  }
}
