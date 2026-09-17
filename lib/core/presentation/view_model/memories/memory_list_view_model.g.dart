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
          AsyncValue<List<Memory>>,
          List<Memory>,
          FutureOr<List<Memory>>
        >
    with $FutureModifier<List<Memory>>, $FutureProvider<List<Memory>> {
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
  $FutureProviderElement<List<Memory>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Memory>> create(Ref ref) {
    return memoryList(ref);
  }
}

String _$memoryListHash() => r'77cdbec6751691f716ac062f08a467589777cdc9';
