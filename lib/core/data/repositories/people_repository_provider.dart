import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database_providers.dart';
import 'people_repository.dart';

part 'people_repository_provider.g.dart';

@riverpod
PeopleRepository peopleRepository(Ref ref) {
  return PeopleRepository(ref.watch(peopleDaoProvider));
}
