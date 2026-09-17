// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

@ProviderFor(questDao)
final questDaoProvider = QuestDaoProvider._();

final class QuestDaoProvider
    extends $FunctionalProvider<QuestDao, QuestDao, QuestDao>
    with $Provider<QuestDao> {
  QuestDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questDaoHash();

  @$internal
  @override
  $ProviderElement<QuestDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  QuestDao create(Ref ref) {
    return questDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestDao>(value),
    );
  }
}

String _$questDaoHash() => r'0b3938197409a5c599f01b5e2780b25b17fb39f2';

@ProviderFor(memoryDao)
final memoryDaoProvider = MemoryDaoProvider._();

final class MemoryDaoProvider
    extends $FunctionalProvider<MemoryDao, MemoryDao, MemoryDao>
    with $Provider<MemoryDao> {
  MemoryDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryDaoHash();

  @$internal
  @override
  $ProviderElement<MemoryDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemoryDao create(Ref ref) {
    return memoryDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoryDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoryDao>(value),
    );
  }
}

String _$memoryDaoHash() => r'9b45f16625fedc18ce92eaece597f585836b6424';

@ProviderFor(peopleDao)
final peopleDaoProvider = PeopleDaoProvider._();

final class PeopleDaoProvider
    extends $FunctionalProvider<PeopleDao, PeopleDao, PeopleDao>
    with $Provider<PeopleDao> {
  PeopleDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'peopleDaoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$peopleDaoHash();

  @$internal
  @override
  $ProviderElement<PeopleDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PeopleDao create(Ref ref) {
    return peopleDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PeopleDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PeopleDao>(value),
    );
  }
}

String _$peopleDaoHash() => r'55a8f857f66b18843ea59560103cfe7ebbe3e668';
