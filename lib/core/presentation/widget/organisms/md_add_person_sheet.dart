import 'package:flutter/material.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../types/display_labels.dart';
import '../atoms/md_primary_button.dart';

/// Asks for a name + relationship as a friendly sheet instead of a cramped
/// dialog. Resolves to `(name, type)`, or null if dismissed. See CLAUDE.md
/// §40, design system §20.
Future<(String, String)?> showAddPersonSheet(BuildContext context) {
  return showModalBottomSheet<(String, String)>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _AddPersonSheet(),
  );
}

class _AddPersonSheet extends StatefulWidget {
  const _AddPersonSheet();

  @override
  State<_AddPersonSheet> createState() => _AddPersonSheetState();
}

class _AddPersonSheetState extends State<_AddPersonSheet> {
  final _nameController = TextEditingController();
  String _type = 'family';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop((name, _type));
  }

  @override
  Widget build(BuildContext context) {
    final name = _nameController.text.trim();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            0,
            AppSpacing.gutter,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add someone', style: AppTypography.heading2),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Their name'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Who are they to you?', style: AppTypography.label),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final (value, label, icon) in personTypes)
                    ChoiceChip(
                      avatar: Icon(icon, size: AppIconSizes.sm),
                      label: Text(label),
                      selected: _type == value,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _type = value),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              MdPrimaryButton(
                label: name.isEmpty ? 'Add' : 'Add $name',
                onPressed: name.isEmpty ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
