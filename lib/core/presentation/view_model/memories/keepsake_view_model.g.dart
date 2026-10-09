// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keepsake_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Designs the printed keepsake for a Memory — layout, paper, stickers —
/// and saves it as an image file. Shared by the reveal and the designer
/// screen so both show the same design. See CLAUDE.md §36-37.

@ProviderFor(KeepsakeViewModel)
final keepsakeViewModelProvider = KeepsakeViewModelFamily._();

/// Designs the printed keepsake for a Memory — layout, paper, stickers —
/// and saves it as an image file. Shared by the reveal and the designer
/// screen so both show the same design. See CLAUDE.md §36-37.
final class KeepsakeViewModelProvider
    extends $AsyncNotifierProvider<KeepsakeViewModel, KeepsakeDesign> {
  /// Designs the printed keepsake for a Memory — layout, paper, stickers —
  /// and saves it as an image file. Shared by the reveal and the designer
  /// screen so both show the same design. See CLAUDE.md §36-37.
  KeepsakeViewModelProvider._({
    required KeepsakeViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'keepsakeViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$keepsakeViewModelHash();

  @override
  String toString() {
    return r'keepsakeViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  KeepsakeViewModel create() => KeepsakeViewModel();

  @override
  bool operator ==(Object other) {
    return other is KeepsakeViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$keepsakeViewModelHash() => r'70430dc6b8f0576e658c740d8cee408257d8562d';

/// Designs the printed keepsake for a Memory — layout, paper, stickers —
/// and saves it as an image file. Shared by the reveal and the designer
/// screen so both show the same design. See CLAUDE.md §36-37.

final class KeepsakeViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          KeepsakeViewModel,
          AsyncValue<KeepsakeDesign>,
          KeepsakeDesign,
          FutureOr<KeepsakeDesign>,
          String
        > {
  KeepsakeViewModelFamily._()
    : super(
        retry: null,
        name: r'keepsakeViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Designs the printed keepsake for a Memory — layout, paper, stickers —
  /// and saves it as an image file. Shared by the reveal and the designer
  /// screen so both show the same design. See CLAUDE.md §36-37.

  KeepsakeViewModelProvider call(String memoryId) =>
      KeepsakeViewModelProvider._(argument: memoryId, from: this);

  @override
  String toString() => r'keepsakeViewModelProvider';
}

/// Designs the printed keepsake for a Memory — layout, paper, stickers —
/// and saves it as an image file. Shared by the reveal and the designer
/// screen so both show the same design. See CLAUDE.md §36-37.

abstract class _$KeepsakeViewModel extends $AsyncNotifier<KeepsakeDesign> {
  late final _$args = ref.$arg as String;
  String get memoryId => _$args;

  FutureOr<KeepsakeDesign> build(String memoryId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<KeepsakeDesign>, KeepsakeDesign>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<KeepsakeDesign>, KeepsakeDesign>,
              AsyncValue<KeepsakeDesign>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
