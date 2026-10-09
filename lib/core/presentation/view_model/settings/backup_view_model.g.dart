// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Uploads anything still missing when the app opens (and again after logging
/// in), if the person has turned backup on. Watched once from the app root.

@ProviderFor(backupCatchUp)
final backupCatchUpProvider = BackupCatchUpProvider._();

/// Uploads anything still missing when the app opens (and again after logging
/// in), if the person has turned backup on. Watched once from the app root.

final class BackupCatchUpProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Uploads anything still missing when the app opens (and again after logging
  /// in), if the person has turned backup on. Watched once from the app root.
  BackupCatchUpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupCatchUpProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupCatchUpHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return backupCatchUp(ref);
  }
}

String _$backupCatchUpHash() => r'8be744a38f07412a079aed9ca9c8edb17a47b3cc';

/// The backup switch, the storage meter and "Back up now" in Settings.

@ProviderFor(BackupViewModel)
final backupViewModelProvider = BackupViewModelProvider._();

/// The backup switch, the storage meter and "Back up now" in Settings.
final class BackupViewModelProvider
    extends $NotifierProvider<BackupViewModel, BackupState> {
  /// The backup switch, the storage meter and "Back up now" in Settings.
  BackupViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupViewModelHash();

  @$internal
  @override
  BackupViewModel create() => BackupViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackupState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackupState>(value),
    );
  }
}

String _$backupViewModelHash() => r'2cdeb7dfb1f78023b8229a6cd0b34bc3bd35e33f';

/// The backup switch, the storage meter and "Back up now" in Settings.

abstract class _$BackupViewModel extends $Notifier<BackupState> {
  BackupState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BackupState, BackupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BackupState, BackupState>,
              BackupState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
