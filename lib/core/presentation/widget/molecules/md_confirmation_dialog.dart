import 'package:flutter/material.dart';

import '../../../../config/constant/app_spacing.dart';
import '../atoms/primary_button.dart';

/// Asks for explicit confirmation before an action that loses something
/// ("Leave quest?"). The safe choice is the primary button. Resolves to
/// `true` only when the person confirms. See design system §45.
Future<bool> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: cancelLabel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            const SizedBox(height: AppSpacing.sm),
            SecondaryButton(
              label: confirmLabel,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
