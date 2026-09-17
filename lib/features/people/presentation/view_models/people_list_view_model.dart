import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/people_repository_provider.dart';
import '../../domain/entities/person.dart';

part 'people_list_view_model.g.dart';

@riverpod
Future<List<Person>> peopleList(Ref ref) {
  return ref.watch(peopleRepositoryProvider).getPeople();
}
