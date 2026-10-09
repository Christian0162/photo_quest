// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_quest_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Picks the day's featured Quest for Home's hero card from the built-in
/// templates. Stable for the whole calendar day, different the next. See
/// CLAUDE.md §31, design system §14.

@ProviderFor(todayQuest)
final todayQuestProvider = TodayQuestProvider._();

/// Picks the day's featured Quest for Home's hero card from the built-in
/// templates. Stable for the whole calendar day, different the next. See
/// CLAUDE.md §31, design system §14.

final class TodayQuestProvider
    extends $FunctionalProvider<AsyncValue<Quest?>, Quest?, FutureOr<Quest?>>
    with $FutureModifier<Quest?>, $FutureProvider<Quest?> {
  /// Picks the day's featured Quest for Home's hero card from the built-in
  /// templates. Stable for the whole calendar day, different the next. See
  /// CLAUDE.md §31, design system §14.
  TodayQuestProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayQuestProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayQuestHash();

  @$internal
  @override
  $FutureProviderElement<Quest?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Quest?> create(Ref ref) {
    return todayQuest(ref);
  }
}

String _$todayQuestHash() => r'20e092c31eca8a4ef9b556d832984d19b66edbbb';
