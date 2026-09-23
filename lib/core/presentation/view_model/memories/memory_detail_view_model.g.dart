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

String _$memoryDetailHash() => r'003727739e0cf685b584f472b2990f24e7ff1849';

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

/// Actions on an open Memory; its data lives in [memoryDetailProvider].

@ProviderFor(MemoryDetailViewModel)
final memoryDetailViewModelProvider = MemoryDetailViewModelFamily._();

/// Actions on an open Memory; its data lives in [memoryDetailProvider].
final class MemoryDetailViewModelProvider
    extends $NotifierProvider<MemoryDetailViewModel, void> {
  /// Actions on an open Memory; its data lives in [memoryDetailProvider].
  MemoryDetailViewModelProvider._({
    required MemoryDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memoryDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memoryDetailViewModelHash();

  @override
  String toString() {
    return r'memoryDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MemoryDetailViewModel create() => MemoryDetailViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MemoryDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memoryDetailViewModelHash() =>
    r'a7c2184c19564def10e95471b41cc014bf42176a';

/// Actions on an open Memory; its data lives in [memoryDetailProvider].

final class MemoryDetailViewModelFamily extends $Family
    with $ClassFamilyOverride<MemoryDetailViewModel, void, void, void, String> {
  MemoryDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'memoryDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Actions on an open Memory; its data lives in [memoryDetailProvider].

  MemoryDetailViewModelProvider call(String memoryId) =>
      MemoryDetailViewModelProvider._(argument: memoryId, from: this);

  @override
  String toString() => r'memoryDetailViewModelProvider';
}

/// Actions on an open Memory; its data lives in [memoryDetailProvider].

abstract class _$MemoryDetailViewModel extends $Notifier<void> {
  late final _$args = ref.$arg as String;
  String get memoryId => _$args;

  void build(String memoryId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
