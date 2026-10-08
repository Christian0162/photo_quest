import 'package:flutter/material.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';

/// A picture from a short-lived web link (a memory a friend shared). Shows a
/// soft placeholder while it loads and a quiet "can't show this" tile if it
/// fails, never an exception. GIFs and boomerangs move on their own. See
/// CLAUDE.md §42, §43.
class MdNetworkPhoto extends StatelessWidget {
  const MdNetworkPhoto({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.semanticLabel,
  });

  final String url;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const ColoredBox(color: AppColors.sunken),
      errorBuilder: (context, error, stack) => const ColoredBox(
        color: AppColors.sunken,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: AppIconSizes.lg,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
