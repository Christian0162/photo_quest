import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../../domain/memories/enum/memory_filter.dart';

/// When a filter has nothing in it — "This day" on a day with no history.
class MdEmptyMemoryFilter extends StatelessWidget {
  const MdEmptyMemoryFilter({super.key, required this.filter});

  final MemoryFilter filter;

  @override
  Widget build(BuildContext context) {
    final (title, message) = switch (filter) {
      MemoryFilter.thisDay => (
        'Nothing on this day yet',
        'Make today one you’ll look back on next year.',
      ),
      MemoryFilter.thisMonth => (
        'No memories this month yet',
        'There’s still time to make one.',
      ),
      MemoryFilter.allJourney => ('', ''),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTypography.journal),
        const SizedBox(height: AppSpacing.xs),
        Text(message, style: AppTypography.bodyMuted),
      ],
    );
  }
}
