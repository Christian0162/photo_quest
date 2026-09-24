// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memoryList)
final memoryListProvider = MemoryListProvider._();

final class MemoryListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemorySummary>>,
          List<MemorySummary>,
          FutureOr<List<MemorySummary>>
        >
    with
        $FutureModifier<List<MemorySummary>>,
        $FutureProvider<List<MemorySummary>> {
  MemoryListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryListHash();

  @$internal
  @override
  $FutureProviderElement<List<MemorySummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemorySummary>> create(Ref ref) {
    return memoryList(ref);
  }
}

String _$memoryListHash() => r'398bd0f7ee7c362539101c9a69a8bd163e79e390';

/// Which [MemoryFilter] the Memories screen is showing.

@ProviderFor(MemoryFilterSelection)
final memoryFilterSelectionProvider = MemoryFilterSelectionProvider._();

/// Which [MemoryFilter] the Memories screen is showing.
final class MemoryFilterSelectionProvider
    extends $NotifierProvider<MemoryFilterSelection, MemoryFilter> {
  /// Which [MemoryFilter] the Memories screen is showing.
  MemoryFilterSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryFilterSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryFilterSelectionHash();

  @$internal
  @override
  MemoryFilterSelection create() => MemoryFilterSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MemoryFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MemoryFilter>(value),
    );
  }
}

String _$memoryFilterSelectionHash() =>
    r'8fca2788d32dd1b8da2a9dcd1bd2136a7d8b06c6';

/// Which [MemoryFilter] the Memories screen is showing.

abstract class _$MemoryFilterSelection extends $Notifier<MemoryFilter> {
  MemoryFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MemoryFilter, MemoryFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MemoryFilter, MemoryFilter>,
              MemoryFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Filtering is synchronous on top of [memoryListProvider], so switching
/// filters never flashes a loading state. See CLAUDE.md §38, §43.

@ProviderFor(memoryBox)
final memoryBoxProvider = MemoryBoxProvider._();

/// Filtering is synchronous on top of [memoryListProvider], so switching
/// filters never flashes a loading state. See CLAUDE.md §38, §43.

final class MemoryBoxProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemoryBox>,
          AsyncValue<MemoryBox>,
          AsyncValue<MemoryBox>
        >
    with $Provider<AsyncValue<MemoryBox>> {
  /// Filtering is synchronous on top of [memoryListProvider], so switching
  /// filters never flashes a loading state. See CLAUDE.md §38, §43.
  MemoryBoxProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoryBoxProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoryBoxHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<MemoryBox>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<MemoryBox> create(Ref ref) {
    return memoryBox(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<MemoryBox> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<MemoryBox>>(value),
    );
  }
}

String _$memoryBoxHash() => r'153ce8a14bd8329acd65e7c2969c698aa2095af9';

/// A memory made on this calendar day in an earlier year, if there is one —
/// the time-capsule moment ("2 years ago today"). The most recent year wins.
/// See CLAUDE.md §21, §68.

@ProviderFor(onThisDayMemory)
final onThisDayMemoryProvider = OnThisDayMemoryProvider._();

/// A memory made on this calendar day in an earlier year, if there is one —
/// the time-capsule moment ("2 years ago today"). The most recent year wins.
/// See CLAUDE.md §21, §68.

final class OnThisDayMemoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemorySummary?>,
          MemorySummary?,
          FutureOr<MemorySummary?>
        >
    with $FutureModifier<MemorySummary?>, $FutureProvider<MemorySummary?> {
  /// A memory made on this calendar day in an earlier year, if there is one —
  /// the time-capsule moment ("2 years ago today"). The most recent year wins.
  /// See CLAUDE.md §21, §68.
  OnThisDayMemoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onThisDayMemoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onThisDayMemoryHash();

  @$internal
  @override
  $FutureProviderElement<MemorySummary?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemorySummary?> create(Ref ref) {
    return onThisDayMemory(ref);
  }
}

String _$onThisDayMemoryHash() => r'f9c5c9c24067191258f57bbf914a5ea6a24ea54c';
