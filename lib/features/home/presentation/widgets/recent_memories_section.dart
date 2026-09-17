import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../memories/domain/entities/memory.dart';

/// Horizontal strip of recent memories on Home, or an inline nudge when
/// there are none yet. See CLAUDE.md §31, §43.
class RecentMemoriesSection extends StatelessWidget {
  const RecentMemoriesSection({
    super.key,
    required this.memories,
    required this.builder,
  });

  final List<Memory> memories;
  final Widget Function(Memory memory) builder;

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Text(
          "Your memories will live here. Ready to make the first one?",
          style: AppTypography.bodyMuted,
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: memories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) => builder(memories[index]),
      ),
    );
  }
}
