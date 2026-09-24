import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../view_model/people/people_list_view_model.dart';
import '../../widget/organisms/add_person_sheet.dart';
import '../../widget/organisms/app_scaffold.dart';
import '../../widget/templates/people_template.dart';

/// People. Wires [PeopleList] and the add-someone sheet into
/// [PeopleTemplate]. See CLAUDE.md §40.
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  Future<void> _addPerson(BuildContext context, WidgetRef ref) async {
    final added = await showAddPersonSheet(context);
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
