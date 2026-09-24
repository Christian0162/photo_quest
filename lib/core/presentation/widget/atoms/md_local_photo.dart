import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_motion.dart';
import '../../../../config/constant/app_spacing.dart';

/// Displays a photo stored on the device. Decodes at display size (never the
/// full original), fades in once decoded, and shows a gentle placeholder if
/// the file is missing or corrupted instead of a broken-image error. See
/// CLAUDE.md §42, §46.
class LocalPhoto extends StatelessWidget {
  const LocalPhoto({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.decodeWidth,
    this.semanticLabel,
    this.placeholderIcon = Icons.photo_rounded,
  });

  final String? path;
  final BoxFit fit;

  /// Which part of the photo stays in view when [fit] crops it.
  final Alignment alignment;

  /// Logical width to decode at. Defaults to the laid-out width.
  final double? decodeWidth;
  final String? semanticLabel;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    final path = this.path;
    if (path == null || path.isEmpty) {
      return PhotoPlaceholder(icon: placeholderIcon);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        // Use the box's longer side so a cover crop never has to upscale.
        final width =
            decodeWidth ??
            (constraints.maxHeight.isFinite &&
                    constraints.maxHeight > constraints.maxWidth
                ? constraints.maxHeight
                : constraints.maxWidth);
        final cacheWidth = width.isFinite ? (width * dpr).round() : null;

        return Image.file(
          File(path),
          fit: fit,
          alignment: alignment,
          // Cover fills its box; contain sizes to the photo so shadows and
          // borders hug the picture itself.
          width: fit == BoxFit.cover ? double.infinity : null,
          height: fit == BoxFit.cover ? double.infinity : null,
          cacheWidth: cacheWidth,
          semanticLabel: semanticLabel,
          excludeFromSemantics: semanticLabel == null,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            if (wasSynchronouslyLoaded) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: AppMotion.of(context, AppMotion.short),
              child: child,
            );
          },
          errorBuilder: (context, error, stack) =>
              PhotoPlaceholder(icon: Icons.broken_image_outlined),
        );
      },
    );
  }
}

/// Soft peach stand-in for a photo that isn't there (yet).
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    this.icon = Icons.photo_rounded,
    this.color = AppColors.softPeach,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Center(
        child: Icon(icon, size: AppIconSizes.xl, color: AppColors.textMuted),
      ),
    );
  }
}
