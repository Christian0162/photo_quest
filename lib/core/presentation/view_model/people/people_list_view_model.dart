import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/repositories/people_repository_provider.dart';
import '../../../domain/people/entities/person.dart';

part 'people_list_view_model.g.dart';

/// The People known to this device, and adding new ones. Keeps repository
/// calls out of widgets. See CLAUDE.md §15, §40, §50.
@riverpod
class PeopleList extends _$PeopleList {
  @override
  Future<List<Person>> build() {
    return ref.watch(peopleRepositoryProvider).getPeople();
  }

  /// Adds someone (or a pet). The device owner (`self`) is created by the
  /// app, never here. See CLAUDE.md §19.
  Future<void> addPerson({required String name, required String type}) async {
    assert(type != 'self', 'The device owner is not added by hand.');
    final now = DateTime.now();
    await ref
        .read(peopleRepositoryProvider)
        .createPerson(
          Person(
            id: '',
            name: name.trim(),
            type: type,
            createdAt: now,
            updatedAt: now,
          ),
        );
    ref.invalidateSelf();
    await future;
  }
}

/// Everyone except the device owner — the People you can invite to a Quest.
/// See CLAUDE.md §19, §40.
@riverpod
Future<List<Person>> invitablePeople(Ref ref) async {
  final people = await ref.watch(peopleListProvider.future);
  return people.where((p) => p.type != 'self').toList();
}
