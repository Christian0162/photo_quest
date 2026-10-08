import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_model/people/add_person_view_model.dart';
import '../../view_model/people/people_list_view_model.dart';
import '../../widget/organisms/people/md_add_person_sheet.dart';
import '../../widget/organisms/common/md_app_scaffold.dart';
import '../../widget/templates/people/people_template.dart';

/// People. Wires [PeopleList] and the add-someone sheet into
/// [PeopleTemplate]. See CLAUDE.md §40.
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  /// Resolves to `(name, type)`, or null if the sheet was dismissed.
  Future<(String, String)?> _askForPerson(BuildContext context) {
    return showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final form = ref.watch(addPersonViewModelProvider);
          final viewModel = ref.read(addPersonViewModelProvider.notifier);
          return MdAddPersonSheet(
            name: form.name,
            type: form.type,
            onNameChanged: viewModel.setName,
            onTypeChanged: viewModel.setType,
            onSubmit: () {
              if (!form.canSubmit) return;
              Navigator.of(context).pop((form.trimmedName, form.type));
            },
          );
        },
      ),
    );
  }

  Future<void> _addPerson(BuildContext context, WidgetRef ref) async {
    final added = await _askForPerson(context);
    if (added == null) return;

    try {
      await ref
          .read(peopleListProvider.notifier)
          .addPerson(name: added.$1, type: added.$2);
    } catch (_) {
      if (!context.mounted) return;
      showAppMessage(
        context,
        "We couldn't add them just now. Please try again.",
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PeopleTemplate(
      people: ref.watch(peopleListProvider),
      onRetry: () => ref.invalidate(peopleListProvider),
      onAddPerson: () => _addPerson(context, ref),
    );
  }
}
