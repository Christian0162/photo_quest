// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_detail_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(questDetail)
final questDetailProvider = QuestDetailFamily._();

final class QuestDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<QuestDetail>,
          QuestDetail,
          FutureOr<QuestDetail>
        >
    with $FutureModifier<QuestDetail>, $FutureProvider<QuestDetail> {
  QuestDetailProvider._({
    required QuestDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'questDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$questDetailHash();

  @override
  String toString() {
    return r'questDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<QuestDetail> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<QuestDetail> create(Ref ref) {
    final argument = this.argument as String;
    return questDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is QuestDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$questDetailHash() => r'9cbe994f54f553edf11e23ee4195a658fdd5b533';

final class QuestDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<QuestDetail>, String> {
  QuestDetailFamily._()
    : super(
        retry: null,
        name: r'questDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  QuestDetailProvider call(String questId) =>
      QuestDetailProvider._(argument: questId, from: this);

  @override
  String toString() => r'questDetailProvider';
}
