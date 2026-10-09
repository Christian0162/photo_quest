import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';

/// Shared shell for a step: one big question, optional helper, content.
class MdQuestStepPage extends StatelessWidget {
  const MdQuestStepPage({
    super.key,
    required this.question,
    this.helper,
    required this.children,
  });

  final String question;
  final String? helper;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.lg,
        AppSpacing.gutter,
        AppSpacing.xl,
      ),
      children: [
        Semantics(
          header: true,
          child: Text(question, style: AppTypography.heading1),
        ),
        if (helper != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(helper!, style: AppTypography.bodyMuted),
        ],
        const SizedBox(height: AppSpacing.lg),
        ...children,
      ],
    );
  }
}
