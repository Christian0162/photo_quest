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

String _$memoryListHash() => r'49e19327ee6f0d3fea7b18c6cfffe3318b7d3c88';

/// Memories bucketed by month, newest first. See CLAUDE.md §38.

@ProviderFor(memoriesByMonth)
final memoriesByMonthProvider = MemoriesByMonthProvider._();

/// Memories bucketed by month, newest first. See CLAUDE.md §38.

final class MemoriesByMonthProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<MemoryMonth>>,
          List<MemoryMonth>,
          FutureOr<List<MemoryMonth>>
        >
    with
        $FutureModifier<List<MemoryMonth>>,
        $FutureProvider<List<MemoryMonth>> {
  /// Memories bucketed by month, newest first. See CLAUDE.md §38.
  MemoriesByMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'memoriesByMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$memoriesByMonthHash();

  @$internal
  @override
  $FutureProviderElement<List<MemoryMonth>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<MemoryMonth>> create(Ref ref) {
    return memoriesByMonth(ref);
  }
}

String _$memoriesByMonthHash() => r'082510734fe2397d9a4692588ef580f00087b9d1';
