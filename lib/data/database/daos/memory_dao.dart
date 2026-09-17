import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/memories_table.dart';
import '../tables/memory_people_table.dart';
import '../tables/photos_table.dart';
import '../tables/quest_sessions_table.dart';

part 'memory_dao.g.dart';

/// All Memory/Photo/QuestSession/MemoryPeople queries live here. See
/// CLAUDE.md §16, §47.
@DriftAccessor(tables: [Memories, Photos, QuestSessions, MemoryPeople])
class MemoryDao extends DatabaseAccessor<AppDatabase> with _$MemoryDaoMixin {
  MemoryDao(super.db);

  Future<List<Memory>> getAllMemories() {
    return (select(
      memories,
    )..orderBy([(m) => OrderingTerm.desc(m.capturedAt)])).get();
  }

  Future<Memory?> getMemoryById(String id) =>
      (select(memories)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<Memory?> getMemoryBySessionId(String sessionId) => (select(
    memories,
  )..where((m) => m.questSessionId.equals(sessionId))).getSingleOrNull();

  Future<List<Photo>> getPhotosForMemory(String memoryId) {
    return (select(photos)
          ..where((p) => p.memoryId.equals(memoryId))
          ..orderBy([(p) => OrderingTerm.asc(p.position)]))
        .get();
  }

  Future<List<String>> getPersonIdsForMemory(String memoryId) async {
    final rows = await (select(
      memoryPeople,
    )..where((mp) => mp.memoryId.equals(memoryId))).get();
    return rows.map((r) => r.personId).toList();
  }

  Future<QuestSession?> getSessionById(String id) =>
      (select(questSessions)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<void> insertSession(QuestSessionsCompanion session) =>
      into(questSessions).insert(session);

  Future<void> completeSession(String id, DateTime completedAt) {
    return (update(questSessions)..where((s) => s.id.equals(id))).write(
      QuestSessionsCompanion(
        status: const Value('completed'),
        completedAt: Value(completedAt),
      ),
    );
  }

  Future<void> insertMemory(MemoriesCompanion memory) =>
      into(memories).insert(memory);

  Future<void> insertPhoto(PhotosCompanion photo) => into(photos).insert(photo);

  Future<void> linkPerson(String memoryId, String personId) {
    return into(memoryPeople).insert(
      MemoryPeopleCompanion.insert(memoryId: memoryId, personId: personId),
    );
  }

  Future<void> deleteMemory(String id) =>
      (delete(memories)..where((m) => m.id.equals(id))).go();
}
