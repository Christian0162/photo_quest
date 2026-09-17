import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/empty_states/empty_state.dart';
import '../../../../core/widgets/loading/loading_indicator.dart';
import '../../data/repositories/people_repository_provider.dart';
import '../../domain/entities/person.dart';
import '../view_models/people_list_view_model.dart';
import '../widgets/person_avatar.dart';

/// The people (and pets) memories can be organized around. Private, not a
/// social directory. See CLAUDE.md §40.
class PeopleScreen extends ConsumerWidget {
  const PeopleScreen({super.key});

  Future<void> _addPerson(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    var type = 'family';

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add a Person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'self', child: Text('Me')),
                  DropdownMenuItem(value: 'partner', child: Text('Partner')),
                  DropdownMenuItem(value: 'family', child: Text('Family')),
                  DropdownMenuItem(value: 'friend', child: Text('Friend')),
                  DropdownMenuItem(value: 'pet', child: Text('Pet')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => type = value ?? type),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: nameController.text.trim().isEmpty
                  ? null
                  : () => Navigator.of(context).pop(true),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (created != true || nameController.text.trim().isEmpty) return;

    final now = DateTime.now();
    await ref
        .read(peopleRepositoryProvider)
        .createPerson(
          Person(
            id: '',
            name: nameController.text.trim(),
            type: type,
            createdAt: now,
            updatedAt: now,
          ),
        );
    ref.invalidate(peopleListProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        actions: [
          IconButton(
            onPressed: () => _addPerson(context, ref),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
      ),
      body: people.when(
        loading: () => const LoadingIndicator(),
        error: (error, stack) => const EmptyState(
          icon: Icons.error_outline_rounded,
          title: "Couldn't load your people",
          message: 'Please try again in a moment.',
        ),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.people_alt_rounded,
              title: 'No one here yet',
              message: 'Add the people (and pets) your memories are about.',
              action: FilledButton(
                onPressed: () => _addPerson(context, ref),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.warmCoral,
                ),
                child: const Text('Add a Person'),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final person = list[index];
              return ListTile(
                leading: PersonAvatar(person: person, radius: 22),
                title: Text(person.name, style: AppTypography.body),
                subtitle: Text(person.type, style: AppTypography.bodyMuted),
              );
            },
          );
        },
      ),
    );
  }
}
