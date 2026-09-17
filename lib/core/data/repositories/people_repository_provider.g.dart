// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(peopleRepository)
final peopleRepositoryProvider = PeopleRepositoryProvider._();

final class PeopleRepositoryProvider
    extends
        $FunctionalProvider<
          PeopleRepository,
          PeopleRepository,
          PeopleRepository
        >
    with $Provider<PeopleRepository> {
  PeopleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'peopleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$peopleRepositoryHash();

  @$internal
  @override
  $ProviderElement<PeopleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PeopleRepository create(Ref ref) {
    return peopleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PeopleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PeopleRepository>(value),
    );
  }
}

String _$peopleRepositoryHash() => r'c93eef23c9a75c23720dda430b04cf52631e158c';
