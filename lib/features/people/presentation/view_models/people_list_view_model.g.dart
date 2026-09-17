// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'people_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(peopleList)
final peopleListProvider = PeopleListProvider._();

final class PeopleListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Person>>,
          List<Person>,
          FutureOr<List<Person>>
        >
    with $FutureModifier<List<Person>>, $FutureProvider<List<Person>> {
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
  $FutureProviderElement<List<Person>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Person>> create(Ref ref) {
    return peopleList(ref);
  }
}

String _$peopleListHash() => r'86f5907d3409b158d5b4dd9f250a0406814227a2';
