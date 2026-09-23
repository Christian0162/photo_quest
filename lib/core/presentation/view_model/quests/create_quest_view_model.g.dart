// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_quest_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the guided Create Quest flow: what/description/participants/shots
/// -> review -> create. See CLAUDE.md §33, design system §17-19.

@ProviderFor(CreateQuestViewModel)
final createQuestViewModelProvider = CreateQuestViewModelProvider._();

/// Drives the guided Create Quest flow: what/description/participants/shots
/// -> review -> create. See CLAUDE.md §33, design system §17-19.
final class CreateQuestViewModelProvider
    extends $NotifierProvider<CreateQuestViewModel, CreateQuestDraft> {
  /// Drives the guided Create Quest flow: what/description/participants/shots
  /// -> review -> create. See CLAUDE.md §33, design system §17-19.
  CreateQuestViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createQuestViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createQuestViewModelHash();

  @$internal
  @override
  CreateQuestViewModel create() => CreateQuestViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateQuestDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateQuestDraft>(value),
    );
  }
}

String _$createQuestViewModelHash() =>
    r'39fd90d14c8f695967c7f5439f44f7321dd5a344';

/// Drives the guided Create Quest flow: what/description/participants/shots
/// -> review -> create. See CLAUDE.md §33, design system §17-19.

abstract class _$CreateQuestViewModel extends $Notifier<CreateQuestDraft> {
  CreateQuestDraft build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CreateQuestDraft, CreateQuestDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreateQuestDraft, CreateQuestDraft>,
              CreateQuestDraft,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
