// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_person_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The in-progress "Add someone" form. Lives only while the sheet is open,
/// so the next one starts blank.

@ProviderFor(AddPersonViewModel)
final addPersonViewModelProvider = AddPersonViewModelProvider._();

/// The in-progress "Add someone" form. Lives only while the sheet is open,
/// so the next one starts blank.
final class AddPersonViewModelProvider
    extends $NotifierProvider<AddPersonViewModel, AddPersonDraft> {
  /// The in-progress "Add someone" form. Lives only while the sheet is open,
  /// so the next one starts blank.
  AddPersonViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addPersonViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addPersonViewModelHash();

  @$internal
  @override
  AddPersonViewModel create() => AddPersonViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddPersonDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddPersonDraft>(value),
    );
  }
}

String _$addPersonViewModelHash() =>
    r'ffcc327becc66d65420b75c5aee0149af7985677';

/// The in-progress "Add someone" form. Lives only while the sheet is open,
/// so the next one starts blank.

abstract class _$AddPersonViewModel extends $Notifier<AddPersonDraft> {
  AddPersonDraft build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AddPersonDraft, AddPersonDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddPersonDraft, AddPersonDraft>,
              AddPersonDraft,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
