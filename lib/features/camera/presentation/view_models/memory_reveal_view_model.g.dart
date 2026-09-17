// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_reveal_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composes the finished photo strip for a just-completed session and
/// returns the memory it belongs to. See CLAUDE.md §36-37.

@ProviderFor(memoryReveal)
final memoryRevealProvider = MemoryRevealFamily._();

/// Composes the finished photo strip for a just-completed session and
/// returns the memory it belongs to. See CLAUDE.md §36-37.

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
  /// Composes the finished photo strip for a just-completed session and
  /// returns the memory it belongs to. See CLAUDE.md §36-37.
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

String _$memoryRevealHash() => r'8f2e15d49ecf940b8505cdda6bc3f6d6ee93dd62';

/// Composes the finished photo strip for a just-completed session and
/// returns the memory it belongs to. See CLAUDE.md §36-37.

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

  /// Composes the finished photo strip for a just-completed session and
  /// returns the memory it belongs to. See CLAUDE.md §36-37.

  MemoryRevealProvider call(String sessionId) =>
      MemoryRevealProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'memoryRevealProvider';
}
