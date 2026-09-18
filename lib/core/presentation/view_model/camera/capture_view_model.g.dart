// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'capture_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the photobooth capture flow: instruction -> countdown -> shutter
/// -> next shot, one shot at a time. See CLAUDE.md §34-35.

@ProviderFor(CaptureViewModel)
final captureViewModelProvider = CaptureViewModelFamily._();

/// Drives the photobooth capture flow: instruction -> countdown -> shutter
/// -> next shot, one shot at a time. See CLAUDE.md §34-35.
final class CaptureViewModelProvider
    extends $AsyncNotifierProvider<CaptureViewModel, CaptureState> {
  /// Drives the photobooth capture flow: instruction -> countdown -> shutter
  /// -> next shot, one shot at a time. See CLAUDE.md §34-35.
  CaptureViewModelProvider._({
    required CaptureViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'captureViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$captureViewModelHash();

  @override
  String toString() {
    return r'captureViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CaptureViewModel create() => CaptureViewModel();

  @override
  bool operator ==(Object other) {
    return other is CaptureViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$captureViewModelHash() => r'1c8c9df410ff52b8af5d40410f1e0615f4056726';

/// Drives the photobooth capture flow: instruction -> countdown -> shutter
/// -> next shot, one shot at a time. See CLAUDE.md §34-35.

final class CaptureViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          CaptureViewModel,
          AsyncValue<CaptureState>,
          CaptureState,
          FutureOr<CaptureState>,
          String
        > {
  CaptureViewModelFamily._()
    : super(
        retry: null,
        name: r'captureViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives the photobooth capture flow: instruction -> countdown -> shutter
  /// -> next shot, one shot at a time. See CLAUDE.md §34-35.

  CaptureViewModelProvider call(String sessionId) =>
      CaptureViewModelProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'captureViewModelProvider';
}

/// Drives the photobooth capture flow: instruction -> countdown -> shutter
/// -> next shot, one shot at a time. See CLAUDE.md §34-35.

abstract class _$CaptureViewModel extends $AsyncNotifier<CaptureState> {
  late final _$args = ref.$arg as String;
  String get sessionId => _$args;

  FutureOr<CaptureState> build(String sessionId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CaptureState>, CaptureState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CaptureState>, CaptureState>,
              AsyncValue<CaptureState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
