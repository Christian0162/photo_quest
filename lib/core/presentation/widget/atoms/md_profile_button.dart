import 'package:flutter/material.dart';

import '../../../../config/constant/app_spacing.dart';
import '../../../utils/app_haptics.dart';
import 'md_avatar_image.dart';

/// Your chosen avatar in the corner of Home, opening your profile. Falls
/// back to a plain person icon until an avatar is picked.
class MdProfileButton extends StatelessWidget {
  const MdProfileButton({
    super.key,
    required this.avatarId,
    required this.onTap,
  });

  final String? avatarId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Your profile',
      excludeSemantics: true,
      child: InkResponse(
        radius: AppTouch.minTarget / 2,
        onTap: () {
          AppHaptics.tap();
          onTap();
        },
        // A full-size tap target around a smaller picture.
        child: SizedBox.square(
          dimension: AppTouch.minTarget,
          child: Center(child: MdAvatarImage(avatarId: avatarId, radius: 20)),
        ),
      ),
    );
  }
}
