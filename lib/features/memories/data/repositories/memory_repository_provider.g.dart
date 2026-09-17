// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memoryRepository)
final memoryRepositoryProvider = MemoryRepositoryProvider._();

final class MemoryRepositoryProvider
    extends
        $FunctionalProvider<
          MemoryRepository,
          MemoryRepository,
          MemoryRepository
        >
    with $Provider<MemoryRepository> {
  MemoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<MemoryRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MemoryRepository create(Ref ref) {
    return memoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoryRepository>(value),
    );
  }
}

String _$memoryRepositoryHash() => r'18f489e790a2b8645f5c4b6c570f902f83f3e9af';
