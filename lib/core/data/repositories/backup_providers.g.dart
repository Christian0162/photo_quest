// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(connectivityService)
final connectivityServiceProvider = ConnectivityServiceProvider._();

final class ConnectivityServiceProvider
    extends
        $FunctionalProvider<
          ConnectivityService,
          ConnectivityService,
          ConnectivityService
        >
    with $Provider<ConnectivityService> {
  ConnectivityServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectivityServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectivityServiceHash();

  @$internal
  @override
  $ProviderElement<ConnectivityService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ConnectivityService create(Ref ref) {
    return connectivityService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConnectivityService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConnectivityService>(value),
    );
  }
}

String _$connectivityServiceHash() =>
    r'a41855a7e07cfa28457d4a8747cbc16077f207b4';

@ProviderFor(memoryBackupService)
final memoryBackupServiceProvider = MemoryBackupServiceProvider._();

final class MemoryBackupServiceProvider
    extends
        $FunctionalProvider<
          MemoryBackupService,
          MemoryBackupService,
          MemoryBackupService
        >
    with $Provider<MemoryBackupService> {
  MemoryBackupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryBackupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryBackupServiceHash();

  @$internal
  @override
  $ProviderElement<MemoryBackupService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MemoryBackupService create(Ref ref) {
    return memoryBackupService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoryBackupService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoryBackupService>(value),
    );
  }
}

String _$memoryBackupServiceHash() =>
    r'93c769db145b927ab0a631c603200c8b445042a1';
