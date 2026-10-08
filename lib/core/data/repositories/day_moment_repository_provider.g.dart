// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_moment_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dayMomentRepository)
final dayMomentRepositoryProvider = DayMomentRepositoryProvider._();

final class DayMomentRepositoryProvider
    extends
        $FunctionalProvider<
          DayMomentRepository,
          DayMomentRepository,
          DayMomentRepository
        >
    with $Provider<DayMomentRepository> {
  DayMomentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dayMomentRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dayMomentRepositoryHash();

  @$internal
  @override
  $ProviderElement<DayMomentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DayMomentRepository create(Ref ref) {
    return dayMomentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DayMomentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DayMomentRepository>(value),
    );
  }
}

String _$dayMomentRepositoryHash() =>
    r'633f7238acec6a5edd4682fc363810aef2e2d892';
