// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_capture_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Takes one quick photo for "Your Day" and keeps it for 24 hours. See
/// CLAUDE.md §35, §47.

@ProviderFor(MomentCapture)
final momentCaptureProvider = MomentCaptureProvider._();

/// Takes one quick photo for "Your Day" and keeps it for 24 hours. See
/// CLAUDE.md §35, §47.
final class MomentCaptureProvider
    extends $AsyncNotifierProvider<MomentCapture, MomentCaptureState> {
  /// Takes one quick photo for "Your Day" and keeps it for 24 hours. See
  /// CLAUDE.md §35, §47.
  MomentCaptureProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'momentCaptureProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$momentCaptureHash();

  @$internal
  @override
  MomentCapture create() => MomentCapture();
}

String _$momentCaptureHash() => r'44216c06352d3a8f445cbb3a7de1bdca69f74bc8';

/// Takes one quick photo for "Your Day" and keeps it for 24 hours. See
/// CLAUDE.md §35, §47.

abstract class _$MomentCapture extends $AsyncNotifier<MomentCaptureState> {
  FutureOr<MomentCaptureState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<MomentCaptureState>, MomentCaptureState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MomentCaptureState>, MomentCaptureState>,
              AsyncValue<MomentCaptureState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
