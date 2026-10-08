import 'package:flutter/material.dart';

import '../../../../config/constant/app_avatars.dart';
import '../../../../config/constant/app_colors.dart';

/// A chosen avatar as a little sticker: the picture on a soft tint, in a
/// circle. Shows a plain person until one is picked. Decorative for screen
/// readers; callers label the control around it.
class MdAvatarImage extends StatelessWidget {
  const MdAvatarImage({
    super.key,
    required this.avatarId,
    required this.radius,
  });

  final String? avatarId;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final asset = AppAvatars.assetFor(avatarId);

    return ExcludeSemantics(
      child: asset == null
          ? CircleAvatar(
              radius: radius,
              backgroundColor: AppColors.softPeach,
              child: Icon(
                Icons.person_rounded,
                size: radius,
                color: AppColors.textPrimary,
              ),
            )
          : CircleAvatar(
              radius: radius,
              backgroundColor: AppAvatars.tintFor(avatarId!),
              child: Padding(
                padding: EdgeInsets.all(radius * 0.18),
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  cacheWidth:
                      (radius * 2 * MediaQuery.devicePixelRatioOf(context))
                          .round(),
                ),
              ),
            ),
    );
  }
}
