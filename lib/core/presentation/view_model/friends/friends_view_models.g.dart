// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_view_models.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Real friends: people I've added, requests waiting for my answer, and
/// requests I'm waiting on.

@ProviderFor(friends)
final friendsProvider = FriendsProvider._();

/// Real friends: people I've added, requests waiting for my answer, and
/// requests I'm waiting on.

final class FriendsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Friend>>,
          List<Friend>,
          FutureOr<List<Friend>>
        >
    with $FutureModifier<List<Friend>>, $FutureProvider<List<Friend>> {
  /// Real friends: people I've added, requests waiting for my answer, and
  /// requests I'm waiting on.
  FriendsProvider._()
    : super(
        from: null,
        argument: null,
        retry: neverRetry,
        name: r'friendsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendsHash();

  @$internal
  @override
  $FutureProviderElement<List<Friend>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Friend>> create(Ref ref) {
    return friends(ref);
  }
}

String _$friendsHash() => r'd153fca4aa036202364a2426f0056fb79e1700f9';

/// My friend code: shown to copy or send, and reset when I want a new one.

@ProviderFor(FriendCodeViewModel)
final friendCodeViewModelProvider = FriendCodeViewModelProvider._();

/// My friend code: shown to copy or send, and reset when I want a new one.
final class FriendCodeViewModelProvider
    extends $NotifierProvider<FriendCodeViewModel, FriendCodeState> {
  /// My friend code: shown to copy or send, and reset when I want a new one.
  FriendCodeViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendCodeViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendCodeViewModelHash();

  @$internal
  @override
  FriendCodeViewModel create() => FriendCodeViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FriendCodeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FriendCodeState>(value),
    );
  }
}

String _$friendCodeViewModelHash() =>
    r'3cdde5b715aef32b3a508ea2521526e495fdfc9d';

/// My friend code: shown to copy or send, and reset when I want a new one.

abstract class _$FriendCodeViewModel extends $Notifier<FriendCodeState> {
  FriendCodeState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FriendCodeState, FriendCodeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FriendCodeState, FriendCodeState>,
              FriendCodeState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The "enter a friend's code" form.

@ProviderFor(AddFriendViewModel)
final addFriendViewModelProvider = AddFriendViewModelProvider._();

/// The "enter a friend's code" form.
final class AddFriendViewModelProvider
    extends $NotifierProvider<AddFriendViewModel, AddFriendState> {
  /// The "enter a friend's code" form.
  AddFriendViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addFriendViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addFriendViewModelHash();

  @$internal
  @override
  AddFriendViewModel create() => AddFriendViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddFriendState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddFriendState>(value),
    );
  }
}

String _$addFriendViewModelHash() =>
    r'1388e44981bc9bb7687286da35fc97b96d7e7c72';

/// The "enter a friend's code" form.

abstract class _$AddFriendViewModel extends $Notifier<AddFriendState> {
  AddFriendState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AddFriendState, AddFriendState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AddFriendState, AddFriendState>,
              AddFriendState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Answering a request, or removing a friend. The state is true while
/// something is happening.

@ProviderFor(FriendActionsViewModel)
final friendActionsViewModelProvider = FriendActionsViewModelProvider._();

/// Answering a request, or removing a friend. The state is true while
/// something is happening.
final class FriendActionsViewModelProvider
    extends $NotifierProvider<FriendActionsViewModel, bool> {
  /// Answering a request, or removing a friend. The state is true while
  /// something is happening.
  FriendActionsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendActionsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendActionsViewModelHash();

  @$internal
  @override
  FriendActionsViewModel create() => FriendActionsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$friendActionsViewModelHash() =>
    r'7a215acf6060ea1d141fc79498a3fb307b3798b9';

/// Answering a request, or removing a friend. The state is true while
/// something is happening.

abstract class _$FriendActionsViewModel extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
