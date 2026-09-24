import 'package:drift/drift.dart' show Value;
import 'package:uuid/uuid.dart';

import '../database/app_database.dart' as db;
import '../database/daos/memory_dao.dart';
import '../../domain/quests/entities/quest_session.dart';
import '../../domain/memories/entities/memory.dart';
import '../../domain/memories/entities/photo.dart';

/// Source of truth for Memory/Photo data. See CLAUDE.md §16.
class MemoryRepository {
  MemoryRepository(this._dao);

  final MemoryDao _dao;
  final _uuid = const Uuid();

  Future<List<Memory>> getMemories() async {
    final rows = await _dao.getAllMemories();
    return rows.map(_toEntity).toList();
  }

  Future<Memory?> getMemory(String id) async {
    final row = await _dao.getMemoryById(id);
    return row == null ? null : _toEntity(row);
  }

  Future<List<Photo>> getPhotos(String memoryId) async {
    final rows = await _dao.getPhotosForMemory(memoryId);
    return rows
        .map(
          (r) => Photo(
            id: r.id,
            memoryId: r.memoryId,
            shotId: r.shotId,
            originalPath: r.originalPath,
            thumbnailPath: r.thumbnailPath,
            position: r.position,
            capturedAt: r.capturedAt,
            width: r.width,
            height: r.height,
            kind: r.kind,
          ),
        )
        .toList();
  }

  /// The saved keepsake design for [memoryId] (JSON), or null if it was
  /// never decorated.
  Future<String?> getKeepsakeDesign(String memoryId) async =>
      (await _dao.getMemoryById(memoryId))?.keepsakeDesign;

  Future<void> saveKeepsakeDesign(String memoryId, String design) =>
      _dao.updateKeepsakeDesign(memoryId, design);

  Future<List<String>> getPersonIds(String memoryId) =>
      _dao.getPersonIdsForMemory(memoryId);

  Future<QuestSession?> getSession(String id) async {
    final row = await _dao.getSessionById(id);
    if (row == null) return null;
    return QuestSession(
      id: row.id,
      questId: row.questId,
      startedAt: row.startedAt,
      completedAt: row.completedAt,
      status: row.status,
    );
  }

  /// Starts a new attempt at a Quest. Repeating a Quest always starts a new
  /// session rather than reusing a prior one. See CLAUDE.md §21.
  Future<String> startQuestSession(String questId) async {
    final id = _uuid.v4();
    await _dao.insertSession(
      db.QuestSessionsCompanion.insert(
        id: id,
        questId: questId,
        startedAt: DateTime.now(),
        status: 'in_progress',
      ),
    );
    return id;
  }

  Future<void> completeQuestSession(String id) =>
      _dao.completeSession(id, DateTime.now());

  Future<Memory?> getMemoryForSession(String sessionId) async {
    final row = await _dao.getMemoryBySessionId(sessionId);
    return row == null ? null : _toEntity(row);
  }

  /// Creates a new Memory tied to a Quest session. Repeating a Quest always
  /// calls this again rather than mutating a prior Memory. See CLAUDE.md §21.
  Future<Memory> createMemory({
    required String questSessionId,
    required String title,
    String? note,
    required DateTime capturedAt,
    required List<String> personIds,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _dao.insertMemory(
      db.MemoriesCompanion.insert(
        id: id,
        questSessionId: questSessionId,
        title: title,
        note: Value(note),
        capturedAt: capturedAt,
        createdAt: now,
        updatedAt: now,
      ),
    );

    for (final personId in personIds) {
      await _dao.linkPerson(id, personId);
    }

    return Memory(
      id: id,
      questSessionId: questSessionId,
      title: title,
      note: note,
      capturedAt: capturedAt,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<Photo> addPhoto({
    required String id,
    required String memoryId,
    String? shotId,
    required String originalPath,
    required String thumbnailPath,
    required int position,
    required int width,
    required int height,
    String kind = PhotoKind.photo,
  }) async {
    final capturedAt = DateTime.now();

    await _dao.insertPhoto(
      db.PhotosCompanion.insert(
        id: id,
        memoryId: memoryId,
        shotId: Value(shotId),
        originalPath: originalPath,
        thumbnailPath: thumbnailPath,
        position: position,
        capturedAt: capturedAt,
        width: width,
        height: height,
        kind: Value(kind),
      ),
    );

    return Photo(
      id: id,
      memoryId: memoryId,
      shotId: shotId,
      originalPath: originalPath,
      thumbnailPath: thumbnailPath,
      position: position,
      capturedAt: capturedAt,
      width: width,
      height: height,
      kind: kind,
    );
  }

  /// Removes a photo record so its shot can be retaken. The caller deletes
  /// the files through `PhotoStorageService`. See CLAUDE.md §35.
  Future<void> deletePhoto(String id) => _dao.deletePhoto(id);

  Future<void> deleteMemory(String id) => _dao.deleteMemory(id);

  Memory _toEntity(db.Memory row) {
    return Memory(
      id: row.id,
      questSessionId: row.questSessionId,
      title: row.title,
      note: row.note,
      capturedAt: row.capturedAt,
      coverPhotoId: row.coverPhotoId,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
