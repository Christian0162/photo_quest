// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_moment_dao.dart';

// ignore_for_file: type=lint
mixin _$DayMomentDaoMixin on DatabaseAccessor<AppDatabase> {
  $DayMomentsTable get dayMoments => attachedDatabase.dayMoments;
  DayMomentDaoManager get managers => DayMomentDaoManager(this);
}

class DayMomentDaoManager {
  final _$DayMomentDaoMixin _db;
  DayMomentDaoManager(this._db);
  $$DayMomentsTableTableManager get dayMoments =>
      $$DayMomentsTableTableManager(_db.attachedDatabase, _db.dayMoments);
}
