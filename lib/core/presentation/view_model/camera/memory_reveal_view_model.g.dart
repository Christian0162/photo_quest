// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_reveal_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Makes sure a just-completed session has a printed strip — composing a
/// default one only if the memory has none yet, so a decorated keepsake is
/// never overwritten — and returns the memory it belongs to.

@ProviderFor(memoryReveal)
final memoryRevealProvider = MemoryRevealFamily._();

/// Makes sure a just-completed session has a printed strip — composing a
/// default one only if the memory has none yet, so a decorated keepsake is
/// never overwritten — and returns the memory it belongs to.

final class MemoryRevealProvider
    extends
        $FunctionalProvider<
          AsyncValue<MemoryRevealResult>,
          MemoryRevealResult,
          FutureOr<MemoryRevealResult>
        >
    with
        $FutureModifier<MemoryRevealResult>,
        $FutureProvider<MemoryRevealResult> {
  /// Makes sure a just-completed session has a printed strip — composing a
  /// default one only if the memory has none yet, so a decorated keepsake is
  /// never overwritten — and returns the memory it belongs to.
  MemoryRevealProvider._({
    required MemoryRevealFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'memoryRevealProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$memoryRevealHash();

  @override
  String toString() {
    return r'memoryRevealProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<MemoryRevealResult> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<MemoryRevealResult> create(Ref ref) {
    final argument = this.argument as String;
    return memoryReveal(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MemoryRevealProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$memoryRevealHash() => r'570033948474e91299e3496c7a7872aad4eaa135';

/// Makes sure a just-completed session has a printed strip — composing a
/// default one only if the memory has none yet, so a decorated keepsake is
/// never overwritten — and returns the memory it belongs to.

final class MemoryRevealFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<MemoryRevealResult>, String> {
  MemoryRevealFamily._()
    : super(
        retry: null,
        name: r'memoryRevealProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Makes sure a just-completed session has a printed strip — composing a
  /// default one only if the memory has none yet, so a decorated keepsake is
  /// never overwritten — and returns the memory it belongs to.

  MemoryRevealProvider call(String sessionId) =>
      MemoryRevealProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'memoryRevealProvider';
}
