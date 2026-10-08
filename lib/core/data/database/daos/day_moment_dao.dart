import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/day_moments_table.dart';

part 'day_moment_dao.g.dart';

/// All "Your Day" moment queries live here. See CLAUDE.md §47.
@DriftAccessor(tables: [DayMoments])
class DayMomentDao extends DatabaseAccessor<AppDatabase>
    with _$DayMomentDaoMixin {
  DayMomentDao(super.db);

  /// Moments still showing at [now], oldest first (so they play in the order
  /// they happened).
  Future<List<DayMoment>> getActive(DateTime now) =>
      (select(dayMoments)
            ..where((m) => m.expiresAt.isBiggerThanValue(now))
            ..orderBy([(m) => OrderingTerm.asc(m.createdAt)]))
          .get();

  Future<List<DayMoment>> getExpired(DateTime now) => (select(
    dayMoments,
  )..where((m) => m.expiresAt.isSmallerOrEqualValue(now))).get();

  Future<DayMoment?> getById(String id) =>
      (select(dayMoments)..where((m) => m.id.equals(id))).getSingleOrNull();

  Future<void> insertMoment(DayMomentsCompanion moment) =>
      into(dayMoments).insert(moment);

  Future<void> deleteById(String id) =>
      (delete(dayMoments)..where((m) => m.id.equals(id))).go();
}
