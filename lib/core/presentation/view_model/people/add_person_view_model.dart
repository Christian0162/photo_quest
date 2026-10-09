import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../types/people/add_person_draft.dart';

part 'add_person_view_model.g.dart';

/// The in-progress "Add someone" form. Lives only while the sheet is open,
/// so the next one starts blank.
@riverpod
class AddPersonViewModel extends _$AddPersonViewModel {
  @override
  AddPersonDraft build() => const AddPersonDraft();

  void setName(String name) => state = state.copyWith(name: name);

  void setType(String type) => state = state.copyWith(type: type);
}
