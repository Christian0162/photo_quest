// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_intro_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(questStartReadiness)
final questStartReadinessProvider = QuestStartReadinessFamily._();

final class QuestStartReadinessProvider
    extends
        $FunctionalProvider<
          QuestStartReadiness,
          QuestStartReadiness,
          QuestStartReadiness
        >
    with $Provider<QuestStartReadiness> {
  QuestStartReadinessProvider._({
    required QuestStartReadinessFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'questStartReadinessProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$questStartReadinessHash();

  @override
  String toString() {
    return r'questStartReadinessProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<QuestStartReadiness> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuestStartReadiness create(Ref ref) {
    final argument = this.argument as String;
    return questStartReadiness(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuestStartReadiness value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuestStartReadiness>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QuestStartReadinessProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$questStartReadinessHash() =>
    r'1e148ea8f17e26804dde216ba101a0c5a4515dc7';

final class QuestStartReadinessFamily extends $Family
    with $FunctionalFamilyOverride<QuestStartReadiness, String> {
  QuestStartReadinessFamily._()
    : super(
        retry: null,
        name: r'questStartReadinessProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  QuestStartReadinessProvider call(String questId) =>
      QuestStartReadinessProvider._(argument: questId, from: this);

  @override
  String toString() => r'questStartReadinessProvider';
}

/// Starts a Quest from its introduction. State is true while starting.
/// See CLAUDE.md §21, §59.

@ProviderFor(QuestIntroViewModel)
final questIntroViewModelProvider = QuestIntroViewModelFamily._();

/// Starts a Quest from its introduction. State is true while starting.
/// See CLAUDE.md §21, §59.
final class QuestIntroViewModelProvider
    extends $NotifierProvider<QuestIntroViewModel, bool> {
  /// Starts a Quest from its introduction. State is true while starting.
  /// See CLAUDE.md §21, §59.
  QuestIntroViewModelProvider._({
    required QuestIntroViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'questIntroViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$questIntroViewModelHash();

  @override
  String toString() {
    return r'questIntroViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  QuestIntroViewModel create() => QuestIntroViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is QuestIntroViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$questIntroViewModelHash() =>
    r'44eff54ab6caa1ecc2595507655a120284b5cb4d';

/// Starts a Quest from its introduction. State is true while starting.
/// See CLAUDE.md §21, §59.

final class QuestIntroViewModelFamily extends $Family
    with $ClassFamilyOverride<QuestIntroViewModel, bool, bool, bool, String> {
  QuestIntroViewModelFamily._()
    : super(
        retry: null,
        name: r'questIntroViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Starts a Quest from its introduction. State is true while starting.
  /// See CLAUDE.md §21, §59.

  QuestIntroViewModelProvider call(String questId) =>
      QuestIntroViewModelProvider._(argument: questId, from: this);

  @override
  String toString() => r'questIntroViewModelProvider';
}

/// Starts a Quest from its introduction. State is true while starting.
/// See CLAUDE.md §21, §59.

abstract class _$QuestIntroViewModel extends $Notifier<bool> {
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
