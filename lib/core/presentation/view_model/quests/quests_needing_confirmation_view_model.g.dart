// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quests_needing_confirmation_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Quests you created that still have participants who haven't confirmed
/// they're in. Surfaced on Home so a group quest doesn't quietly stall.
/// See CLAUDE.md §16A, §31, design system §13.

@ProviderFor(questsNeedingConfirmation)
final questsNeedingConfirmationProvider = QuestsNeedingConfirmationProvider._();

/// Quests you created that still have participants who haven't confirmed
/// they're in. Surfaced on Home so a group quest doesn't quietly stall.
/// See CLAUDE.md §16A, §31, design system §13.

final class QuestsNeedingConfirmationProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuestNeedingConfirmation>>,
          List<QuestNeedingConfirmation>,
          FutureOr<List<QuestNeedingConfirmation>>
        >
    with
        $FutureModifier<List<QuestNeedingConfirmation>>,
        $FutureProvider<List<QuestNeedingConfirmation>> {
  /// Quests you created that still have participants who haven't confirmed
  /// they're in. Surfaced on Home so a group quest doesn't quietly stall.
  /// See CLAUDE.md §16A, §31, design system §13.
  QuestsNeedingConfirmationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questsNeedingConfirmationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questsNeedingConfirmationHash();

  @$internal
  @override
  $FutureProviderElement<List<QuestNeedingConfirmation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<QuestNeedingConfirmation>> create(Ref ref) {
    return questsNeedingConfirmation(ref);
  }
}

String _$questsNeedingConfirmationHash() =>
    r'672b04ba203c2f6c3858379eb8a43c2a856b5902';
