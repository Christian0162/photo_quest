// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'day_moments_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The "Your Day" moments still showing. Each one disappears 24 hours after
/// it was added, even while the app stays open. See CLAUDE.md §54A.

@ProviderFor(DayMomentList)
final dayMomentListProvider = DayMomentListProvider._();

/// The "Your Day" moments still showing. Each one disappears 24 hours after
/// it was added, even while the app stays open. See CLAUDE.md §54A.
final class DayMomentListProvider
    extends $AsyncNotifierProvider<DayMomentList, List<DayMoment>> {
  /// The "Your Day" moments still showing. Each one disappears 24 hours after
  /// it was added, even while the app stays open. See CLAUDE.md §54A.
  DayMomentListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dayMomentListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dayMomentListHash();

  @$internal
  @override
  DayMomentList create() => DayMomentList();
}

String _$dayMomentListHash() => r'55c3fab995334b671deb95d7def10427e09f17e4';

/// The "Your Day" moments still showing. Each one disappears 24 hours after
/// it was added, even while the app stays open. See CLAUDE.md §54A.

abstract class _$DayMomentList extends $AsyncNotifier<List<DayMoment>> {
  FutureOr<List<DayMoment>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<DayMoment>>, List<DayMoment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<DayMoment>>, List<DayMoment>>,
              AsyncValue<List<DayMoment>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
