// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quest_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(questList)
final questListProvider = QuestListProvider._();

final class QuestListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Quest>>,
          List<Quest>,
          FutureOr<List<Quest>>
        >
    with $FutureModifier<List<Quest>>, $FutureProvider<List<Quest>> {
  QuestListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questListHash();

  @$internal
  @override
  $FutureProviderElement<List<Quest>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Quest>> create(Ref ref) {
    return questList(ref);
  }
}

String _$questListHash() => r'e59f6857be2710f1eb2aafc1639f446f4a862e11';

@ProviderFor(questShelves)
final questShelvesProvider = QuestShelvesProvider._();

final class QuestShelvesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuestCategoryShelf>>,
          List<QuestCategoryShelf>,
          FutureOr<List<QuestCategoryShelf>>
        >
    with
        $FutureModifier<List<QuestCategoryShelf>>,
        $FutureProvider<List<QuestCategoryShelf>> {
  QuestShelvesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'questShelvesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$questShelvesHash();

  @$internal
  @override
  $FutureProviderElement<List<QuestCategoryShelf>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<QuestCategoryShelf>> create(Ref ref) {
    return questShelves(ref);
  }
}

String _$questShelvesHash() => r'86a4e32808bb9a52de1d9092a4e27d6269b2cbae';
