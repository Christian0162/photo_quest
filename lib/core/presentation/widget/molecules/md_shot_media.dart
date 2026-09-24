import 'package:flutter/material.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../domain/memories/entities/photo.dart';
import '../atoms/md_local_photo.dart';
import '../atoms/md_looping_video.dart';
import '../atoms/md_shot_kind_badge.dart';

/// Shows any captured shot the right way: a photo, a GIF or boomerang that
/// plays, or a 360° clip on loop — with a small badge saying which. Pass
/// [useThumbnail] where a small still is enough (grids, cards).
class MdShotMedia extends StatelessWidget {
  const MdShotMedia({
    super.key,
    required this.photo,
    this.fit = BoxFit.cover,
    this.semanticLabel,
    this.showBadge = true,
    this.useThumbnail = false,
  });

  final Photo photo;
  final BoxFit fit;
  final String? semanticLabel;
  final bool showBadge;
  final bool useThumbnail;

  @override
  Widget build(BuildContext context) {
    final Widget media = useThumbnail
        ? MdLocalPhoto(
            path: photo.thumbnailPath,
            fit: fit,
            semanticLabel: semanticLabel,
          )
        : photo.isVideo
        ? MdLoopingVideo(
            path: photo.originalPath,
            posterPath: photo.thumbnailPath,
            fit: fit,
            semanticLabel: semanticLabel,
          )
        : MdLocalPhoto(
            path: photo.originalPath,
            fit: fit,
            semanticLabel: semanticLabel,
          );

    if (!showBadge || photo.kind == PhotoKind.photo) return media;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        media,
        Positioned(
          top: AppSpacing.ms,
          left: AppSpacing.ms,
          child: ExcludeSemantics(child: MdShotKindBadge(kind: photo.kind)),
        ),
      ],
    );
  }
}
