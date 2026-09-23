// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The People known to this device, and adding new ones. Keeps repository
/// calls out of widgets. See CLAUDE.md §15, §40, §50.

@ProviderFor(PeopleList)
final peopleListProvider = PeopleListProvider._();

/// The People known to this device, and adding new ones. Keeps repository
/// calls out of widgets. See CLAUDE.md §15, §40, §50.
final class PeopleListProvider
    extends $AsyncNotifierProvider<PeopleList, List<Person>> {
  /// The People known to this device, and adding new ones. Keeps repository
  /// calls out of widgets. See CLAUDE.md §15, §40, §50.
  PeopleListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'peopleListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$peopleListHash();

  @$internal
  @override
  PeopleList create() => PeopleList();
}

String _$peopleListHash() => r'f91f54b995569200242cedc2dbddc6530d8a3f2d';

/// The People known to this device, and adding new ones. Keeps repository
/// calls out of widgets. See CLAUDE.md §15, §40, §50.

abstract class _$PeopleList extends $AsyncNotifier<List<Person>> {
  FutureOr<List<Person>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Person>>, List<Person>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Person>>, List<Person>>,
              AsyncValue<List<Person>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Everyone except the device owner — the People you can invite to a Quest.
/// See CLAUDE.md §19, §40.

@ProviderFor(invitablePeople)
final invitablePeopleProvider = InvitablePeopleProvider._();

/// Everyone except the device owner — the People you can invite to a Quest.
/// See CLAUDE.md §19, §40.

final class InvitablePeopleProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Person>>,
          List<Person>,
          FutureOr<List<Person>>
        >
    with $FutureModifier<List<Person>>, $FutureProvider<List<Person>> {
  /// Everyone except the device owner — the People you can invite to a Quest.
  /// See CLAUDE.md §19, §40.
  InvitablePeopleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'invitablePeopleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$invitablePeopleHash();

  @$internal
  @override
  $FutureProviderElement<List<Person>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Person>> create(Ref ref) {
    return invitablePeople(ref);
  }
}

String _$invitablePeopleHash() => r'efb6c1e54093e9ca29a20f40c3edcd6bec9a774b';
