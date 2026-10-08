import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../types/display_labels.dart';
import '../../atoms/common/md_primary_button.dart';

/// The body of the "Add someone" sheet: a name and who they are to you,
/// as a friendly sheet instead of a cramped dialog. Holds no state — the
/// screen owns the form. See CLAUDE.md §40, design system §20.
class MdAddPersonSheet extends StatelessWidget {
  const MdAddPersonSheet({
    super.key,
    required this.name,
    required this.type,
    required this.onNameChanged,
    required this.onTypeChanged,
    required this.onSubmit,
  });

  final String name;
  final String type;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();

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
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(labelText: 'Their name'),
                onChanged: onNameChanged,
                onSubmitted: (_) => onSubmit(),
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
                      selected: type == value,
                      showCheckmark: false,
                      onSelected: (_) => onTypeChanged(value),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              MdPrimaryButton(
                label: trimmed.isEmpty ? 'Add' : 'Add $trimmed',
                onPressed: trimmed.isEmpty ? null : onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
