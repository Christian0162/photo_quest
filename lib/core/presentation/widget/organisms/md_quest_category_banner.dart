import 'package:flutter/material.dart';

import '../../../../config/constant/app_shadows.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../types/display_labels.dart';
import '../molecules/md_photobooth_print.dart';

/// A category's header on Choose a Quest: its name, and an example of that
/// kind of memory as a photobooth print laid on the table at a slight
/// angle (alternating per shelf, like prints tossed down). Falls back to
/// just the name when there's no example photo. See CLAUDE.md §33, §36.
class MdQuestCategoryBanner extends StatelessWidget {
  const MdQuestCategoryBanner({
    super.key,
    required this.category,
    required this.questCount,
    this.index = 0,
    this.today,
  });

  final String category;
  final int questCount;

  /// Position of the shelf, so neighbouring prints tilt opposite ways.
  final int index;

  /// Date written on the print; defaults to today.
  final DateTime? today;

  @override
  Widget build(BuildContext context) {
    final example = questCategoryExample(category);
    final count = questCount == 1 ? '1 quest' : '$questCount quests';

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(category, style: AppTypography.heading2),
          ),
        ),
        Text(count, style: AppTypography.caption),
      ],
    );

    if (example == null) return header;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: AppSpacing.ms),
        Padding(
          // Room for the tilted corners.
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Transform.rotate(
            angle: index.isEven ? -0.012 : 0.012,
            child: DecoratedBox(
              decoration: const BoxDecoration(boxShadow: AppShadows.print),
              child: AspectRatio(
                aspectRatio: 16 / 10.5,
                child: MdPhotoboothPrint(
                  image: ResizeImage(AssetImage(example.asset), width: 640),
                  focus: example.focus,
                  note: example.tagline,
                  date: today ?? DateTime.now(),
                  semanticLabel: 'Example $category photobooth print',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
