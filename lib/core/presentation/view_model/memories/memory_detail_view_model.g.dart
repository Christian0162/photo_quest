// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(memoryDetail)
final memoryDetailProvider = MemoryDetailFamily._();

final class MemoryDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemoryDetail>,
          MemoryDetail,
          FutureOr<MemoryDetail>
        >
    with $FutureModifier<MemoryDetail>, $FutureProvider<MemoryDetail> {
  MemoryDetailProvider._({
    required MemoryDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memoryDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memoryDetailHash();

  @override
  String toString() {
    return r'memoryDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MemoryDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemoryDetail> create(Ref ref) {
    final argument = this.argument as String;
    return memoryDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemoryDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memoryDetailHash() => r'4b053d5887f4c5dd6e309beb06e7a11f31406beb';

final class MemoryDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MemoryDetail>, String> {
  MemoryDetailFamily._()
    : super(
        retry: null,
        name: r'memoryDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MemoryDetailProvider call(String memoryId) =>
      MemoryDetailProvider._(argument: memoryId, from: this);

  @override
  String toString() => r'memoryDetailProvider';
}
