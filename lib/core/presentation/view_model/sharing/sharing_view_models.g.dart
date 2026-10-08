// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing_view_models.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The "Invite a friend" sheet for one of my memories: saves it online, makes
/// a code, lists (and removes) the friends who can see it, and can take the
/// online copy away again.

@ProviderFor(ShareMemoryViewModel)
final shareMemoryViewModelProvider = ShareMemoryViewModelFamily._();

/// The "Invite a friend" sheet for one of my memories: saves it online, makes
/// a code, lists (and removes) the friends who can see it, and can take the
/// online copy away again.
final class ShareMemoryViewModelProvider
    extends $NotifierProvider<ShareMemoryViewModel, ShareMemoryState> {
  /// The "Invite a friend" sheet for one of my memories: saves it online, makes
  /// a code, lists (and removes) the friends who can see it, and can take the
  /// online copy away again.
  ShareMemoryViewModelProvider._({
    required ShareMemoryViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shareMemoryViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shareMemoryViewModelHash();

  @override
  String toString() {
    return r'shareMemoryViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ShareMemoryViewModel create() => ShareMemoryViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareMemoryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareMemoryState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShareMemoryViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shareMemoryViewModelHash() =>
    r'4461ed6314fc17a6add5e7f084ce495b05dccffd';

/// The "Invite a friend" sheet for one of my memories: saves it online, makes
/// a code, lists (and removes) the friends who can see it, and can take the
/// online copy away again.

final class ShareMemoryViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ShareMemoryViewModel,
          ShareMemoryState,
          ShareMemoryState,
          ShareMemoryState,
          String
        > {
  ShareMemoryViewModelFamily._()
    : super(
        retry: null,
        name: r'shareMemoryViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The "Invite a friend" sheet for one of my memories: saves it online, makes
  /// a code, lists (and removes) the friends who can see it, and can take the
  /// online copy away again.

  ShareMemoryViewModelProvider call(String memoryId) =>
      ShareMemoryViewModelProvider._(argument: memoryId, from: this);

  @override
  String toString() => r'shareMemoryViewModelProvider';
}

/// The "Invite a friend" sheet for one of my memories: saves it online, makes
/// a code, lists (and removes) the friends who can see it, and can take the
/// online copy away again.

abstract class _$ShareMemoryViewModel extends $Notifier<ShareMemoryState> {
  late final _$args = ref.$arg as String;
  String get memoryId => _$args;

  ShareMemoryState build(String memoryId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ShareMemoryState, ShareMemoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ShareMemoryState, ShareMemoryState>,
              ShareMemoryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The "Invite a friend" sheet for one of my quests.

@ProviderFor(ShareQuestViewModel)
final shareQuestViewModelProvider = ShareQuestViewModelFamily._();

/// The "Invite a friend" sheet for one of my quests.
final class ShareQuestViewModelProvider
    extends $NotifierProvider<ShareQuestViewModel, ShareMemoryState> {
  /// The "Invite a friend" sheet for one of my quests.
  ShareQuestViewModelProvider._({
    required ShareQuestViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shareQuestViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shareQuestViewModelHash();

  @override
  String toString() {
    return r'shareQuestViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ShareQuestViewModel create() => ShareQuestViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareMemoryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareMemoryState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShareQuestViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shareQuestViewModelHash() =>
    r'2fd37230780bf5a0cd2c516d13cddc9ddc1d2338';

/// The "Invite a friend" sheet for one of my quests.

final class ShareQuestViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          ShareQuestViewModel,
          ShareMemoryState,
          ShareMemoryState,
          ShareMemoryState,
          String
        > {
  ShareQuestViewModelFamily._()
    : super(
        retry: null,
        name: r'shareQuestViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The "Invite a friend" sheet for one of my quests.

  ShareQuestViewModelProvider call(String questId) =>
      ShareQuestViewModelProvider._(argument: questId, from: this);

  @override
  String toString() => r'shareQuestViewModelProvider';
}

/// The "Invite a friend" sheet for one of my quests.

abstract class _$ShareQuestViewModel extends $Notifier<ShareMemoryState> {
  late final _$args = ref.$arg as String;
  String get questId => _$args;

  ShareMemoryState build(String questId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ShareMemoryState, ShareMemoryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ShareMemoryState, ShareMemoryState>,
              ShareMemoryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The "Got a code?" form. A code can be for a memory or for a quest.

@ProviderFor(JoinMemoryViewModel)
final joinMemoryViewModelProvider = JoinMemoryViewModelProvider._();

/// The "Got a code?" form. A code can be for a memory or for a quest.
final class JoinMemoryViewModelProvider
    extends $NotifierProvider<JoinMemoryViewModel, JoinFormState> {
  /// The "Got a code?" form. A code can be for a memory or for a quest.
  JoinMemoryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'joinMemoryViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$joinMemoryViewModelHash();

  @$internal
  @override
  JoinMemoryViewModel create() => JoinMemoryViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JoinFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JoinFormState>(value),
    );
  }
}

String _$joinMemoryViewModelHash() =>
    r'617c6575c655defe2b4c9c500652da4893837b8d';

/// The "Got a code?" form. A code can be for a memory or for a quest.

abstract class _$JoinMemoryViewModel extends $Notifier<JoinFormState> {
  JoinFormState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<JoinFormState, JoinFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<JoinFormState, JoinFormState>,
              JoinFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Memories friends shared with me.

@ProviderFor(sharedMemories)
final sharedMemoriesProvider = SharedMemoriesProvider._();

/// Memories friends shared with me.

final class SharedMemoriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SharedMemorySummary>>,
          List<SharedMemorySummary>,
          FutureOr<List<SharedMemorySummary>>
        >
    with
        $FutureModifier<List<SharedMemorySummary>>,
        $FutureProvider<List<SharedMemorySummary>> {
  /// Memories friends shared with me.
  SharedMemoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: neverRetry,
        name: r'sharedMemoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedMemoriesHash();

  @$internal
  @override
  $FutureProviderElement<List<SharedMemorySummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SharedMemorySummary>> create(Ref ref) {
    return sharedMemories(ref);
  }
}

String _$sharedMemoriesHash() => r'599ff62a7a9baa6eb91e989cc11a4a2c0ddd5084';

/// Quests I've been invited to or have joined.

@ProviderFor(sharedQuests)
final sharedQuestsProvider = SharedQuestsProvider._();

/// Quests I've been invited to or have joined.

final class SharedQuestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SharedQuestSummary>>,
          List<SharedQuestSummary>,
          FutureOr<List<SharedQuestSummary>>
        >
    with
        $FutureModifier<List<SharedQuestSummary>>,
        $FutureProvider<List<SharedQuestSummary>> {
  /// Quests I've been invited to or have joined.
  SharedQuestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: neverRetry,
        name: r'sharedQuestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedQuestsHash();

  @$internal
  @override
  $FutureProviderElement<List<SharedQuestSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SharedQuestSummary>> create(Ref ref) {
    return sharedQuests(ref);
  }
}

String _$sharedQuestsHash() => r'fa84e1016594b444b3fa89a9415d0642b35c7411';

/// Everything shared with me, in one list.

@ProviderFor(sharedHub)
final sharedHubProvider = SharedHubProvider._();

/// Everything shared with me, in one list.

final class SharedHubProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedHub>,
          SharedHub,
          FutureOr<SharedHub>
        >
    with $FutureModifier<SharedHub>, $FutureProvider<SharedHub> {
  /// Everything shared with me, in one list.
  SharedHubProvider._()
    : super(
        from: null,
        argument: null,
        retry: neverRetry,
        name: r'sharedHubProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedHubHash();

  @$internal
  @override
  $FutureProviderElement<SharedHub> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<SharedHub> create(Ref ref) {
    return sharedHub(ref);
  }
}

String _$sharedHubHash() => r'148e5ccadb037b634ea151afb6ce4b6b964f8b03';

/// One shared memory, with fresh links to its photos.

@ProviderFor(sharedMemory)
final sharedMemoryProvider = SharedMemoryFamily._();

/// One shared memory, with fresh links to its photos.

final class SharedMemoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedMemoryDetail>,
          SharedMemoryDetail,
          FutureOr<SharedMemoryDetail>
        >
    with
        $FutureModifier<SharedMemoryDetail>,
        $FutureProvider<SharedMemoryDetail> {
  /// One shared memory, with fresh links to its photos.
  SharedMemoryProvider._({
    required SharedMemoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: neverRetry,
         name: r'sharedMemoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sharedMemoryHash();

  @override
  String toString() {
    return r'sharedMemoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SharedMemoryDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedMemoryDetail> create(Ref ref) {
    final argument = this.argument as String;
    return sharedMemory(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SharedMemoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sharedMemoryHash() => r'6658322f4bf59cd0ca10ed0c68b7d5ea7d7fae2e';

/// One shared memory, with fresh links to its photos.

final class SharedMemoryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SharedMemoryDetail>, String> {
  SharedMemoryFamily._()
    : super(
        retry: neverRetry,
        name: r'sharedMemoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One shared memory, with fresh links to its photos.

  SharedMemoryProvider call(String memoryId) =>
      SharedMemoryProvider._(argument: memoryId, from: this);

  @override
  String toString() => r'sharedMemoryProvider';
}

/// Actions on a memory somebody shared with me. The state is true while the
/// person's own photos are being added.

@ProviderFor(SharedMemoryViewModel)
final sharedMemoryViewModelProvider = SharedMemoryViewModelFamily._();

/// Actions on a memory somebody shared with me. The state is true while the
/// person's own photos are being added.
final class SharedMemoryViewModelProvider
    extends $NotifierProvider<SharedMemoryViewModel, bool> {
  /// Actions on a memory somebody shared with me. The state is true while the
  /// person's own photos are being added.
  SharedMemoryViewModelProvider._({
    required SharedMemoryViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sharedMemoryViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sharedMemoryViewModelHash();

  @override
  String toString() {
    return r'sharedMemoryViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SharedMemoryViewModel create() => SharedMemoryViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SharedMemoryViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sharedMemoryViewModelHash() =>
    r'77881bbca47ee0b99fb81619b7214269da44b5c6';

/// Actions on a memory somebody shared with me. The state is true while the
/// person's own photos are being added.

final class SharedMemoryViewModelFamily extends $Family
    with $ClassFamilyOverride<SharedMemoryViewModel, bool, bool, bool, String> {
  SharedMemoryViewModelFamily._()
    : super(
        retry: null,
        name: r'sharedMemoryViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Actions on a memory somebody shared with me. The state is true while the
  /// person's own photos are being added.

  SharedMemoryViewModelProvider call(String memoryId) =>
      SharedMemoryViewModelProvider._(argument: memoryId, from: this);

  @override
  String toString() => r'sharedMemoryViewModelProvider';
}

/// Actions on a memory somebody shared with me. The state is true while the
/// person's own photos are being added.

abstract class _$SharedMemoryViewModel extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get memoryId => _$args;

  bool build(String memoryId);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// One shared quest: what it is, who is in, and the memories made from it.

@ProviderFor(sharedQuest)
final sharedQuestProvider = SharedQuestFamily._();

/// One shared quest: what it is, who is in, and the memories made from it.

final class SharedQuestProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedQuestDetail>,
          SharedQuestDetail,
          FutureOr<SharedQuestDetail>
        >
    with
        $FutureModifier<SharedQuestDetail>,
        $FutureProvider<SharedQuestDetail> {
  /// One shared quest: what it is, who is in, and the memories made from it.
  SharedQuestProvider._({
    required SharedQuestFamily super.from,
    required String super.argument,
  }) : super(
         retry: neverRetry,
         name: r'sharedQuestProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sharedQuestHash();

  @override
  String toString() {
    return r'sharedQuestProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SharedQuestDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedQuestDetail> create(Ref ref) {
    final argument = this.argument as String;
    return sharedQuest(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SharedQuestProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sharedQuestHash() => r'37f7a115d9e2915f7054003571c4d832c9f70f81';

/// One shared quest: what it is, who is in, and the memories made from it.

final class SharedQuestFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SharedQuestDetail>, String> {
  SharedQuestFamily._()
    : super(
        retry: neverRetry,
        name: r'sharedQuestProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One shared quest: what it is, who is in, and the memories made from it.

  SharedQuestProvider call(String questId) =>
      SharedQuestProvider._(argument: questId, from: this);

  @override
  String toString() => r'sharedQuestProvider';
}

/// Answering an invitation, or leaving a quest. The state is true while
/// something is happening.

@ProviderFor(SharedQuestViewModel)
final sharedQuestViewModelProvider = SharedQuestViewModelFamily._();

/// Answering an invitation, or leaving a quest. The state is true while
/// something is happening.
final class SharedQuestViewModelProvider
    extends $NotifierProvider<SharedQuestViewModel, bool> {
  /// Answering an invitation, or leaving a quest. The state is true while
  /// something is happening.
  SharedQuestViewModelProvider._({
    required SharedQuestViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sharedQuestViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sharedQuestViewModelHash();

  @override
  String toString() {
    return r'sharedQuestViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SharedQuestViewModel create() => SharedQuestViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SharedQuestViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sharedQuestViewModelHash() =>
    r'bb31acbef9088893393844e53bab1deb504ad548';

/// Answering an invitation, or leaving a quest. The state is true while
/// something is happening.

final class SharedQuestViewModelFamily extends $Family
    with $ClassFamilyOverride<SharedQuestViewModel, bool, bool, bool, String> {
  SharedQuestViewModelFamily._()
    : super(
        retry: null,
        name: r'sharedQuestViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Answering an invitation, or leaving a quest. The state is true while
  /// something is happening.

  SharedQuestViewModelProvider call(String questId) =>
      SharedQuestViewModelProvider._(argument: questId, from: this);

  @override
  String toString() => r'sharedQuestViewModelProvider';
}

/// Answering an invitation, or leaving a quest. The state is true while
/// something is happening.

abstract class _$SharedQuestViewModel extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get questId => _$args;

  bool build(String questId);
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
    return element.handleCreate(ref, () => build(_$args));
  }
}
