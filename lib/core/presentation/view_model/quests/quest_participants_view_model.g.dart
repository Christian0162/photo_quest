// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_participants_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Drives the participant list on the Quest Introduction screen: who's
/// invited/joined, and inviting more People. See CLAUDE.md §33, §40-41.
///
/// V1 is local-only (CLAUDE.md §54A): inviting a Person immediately marks
/// them `accepted`, since there is no other device to confirm the invite.

@ProviderFor(QuestParticipantsViewModel)
final questParticipantsViewModelProvider = QuestParticipantsViewModelFamily._();

/// Drives the participant list on the Quest Introduction screen: who's
/// invited/joined, and inviting more People. See CLAUDE.md §33, §40-41.
///
/// V1 is local-only (CLAUDE.md §54A): inviting a Person immediately marks
/// them `accepted`, since there is no other device to confirm the invite.
final class QuestParticipantsViewModelProvider
    extends
        $AsyncNotifierProvider<
          QuestParticipantsViewModel,
          List<QuestParticipantWithPerson>
        > {
  /// Drives the participant list on the Quest Introduction screen: who's
  /// invited/joined, and inviting more People. See CLAUDE.md §33, §40-41.
  ///
  /// V1 is local-only (CLAUDE.md §54A): inviting a Person immediately marks
  /// them `accepted`, since there is no other device to confirm the invite.
  QuestParticipantsViewModelProvider._({
    required QuestParticipantsViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'questParticipantsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$questParticipantsViewModelHash();

  @override
  String toString() {
    return r'questParticipantsViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  QuestParticipantsViewModel create() => QuestParticipantsViewModel();

  @override
  bool operator ==(Object other) {
    return other is QuestParticipantsViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$questParticipantsViewModelHash() =>
    r'fa6a984dc078fb063a122caf01974e26e5675e2e';

/// Drives the participant list on the Quest Introduction screen: who's
/// invited/joined, and inviting more People. See CLAUDE.md §33, §40-41.
///
/// V1 is local-only (CLAUDE.md §54A): inviting a Person immediately marks
/// them `accepted`, since there is no other device to confirm the invite.

final class QuestParticipantsViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          QuestParticipantsViewModel,
          AsyncValue<List<QuestParticipantWithPerson>>,
          List<QuestParticipantWithPerson>,
          FutureOr<List<QuestParticipantWithPerson>>,
          String
        > {
  QuestParticipantsViewModelFamily._()
    : super(
        retry: null,
        name: r'questParticipantsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Drives the participant list on the Quest Introduction screen: who's
  /// invited/joined, and inviting more People. See CLAUDE.md §33, §40-41.
  ///
  /// V1 is local-only (CLAUDE.md §54A): inviting a Person immediately marks
  /// them `accepted`, since there is no other device to confirm the invite.

  QuestParticipantsViewModelProvider call(String questId) =>
      QuestParticipantsViewModelProvider._(argument: questId, from: this);

  @override
  String toString() => r'questParticipantsViewModelProvider';
}

/// Drives the participant list on the Quest Introduction screen: who's
/// invited/joined, and inviting more People. See CLAUDE.md §33, §40-41.
///
/// V1 is local-only (CLAUDE.md §54A): inviting a Person immediately marks
/// them `accepted`, since there is no other device to confirm the invite.

abstract class _$QuestParticipantsViewModel
    extends $AsyncNotifier<List<QuestParticipantWithPerson>> {
  late final _$args = ref.$arg as String;
  String get questId => _$args;

  FutureOr<List<QuestParticipantWithPerson>> build(String questId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<QuestParticipantWithPerson>>,
              List<QuestParticipantWithPerson>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<QuestParticipantWithPerson>>,
                List<QuestParticipantWithPerson>
              >,
              AsyncValue<List<QuestParticipantWithPerson>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
