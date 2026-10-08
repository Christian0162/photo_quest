import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/common/md_sticker.dart';
import '../../molecules/common/md_animated_photoquest_logo.dart';
import '../../organisms/common/md_app_scaffold.dart';

class WelcomeTemplate extends StatelessWidget {
  const WelcomeTemplate({
    super.key,
    required this.onCreateAccount,
    required this.onLogIn,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      backgroundColor: AppColors.warmCoral,
      overlayStyle: SystemUiOverlayStyle.dark,
      bottomActionSheet: true,
      bottomAction: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MdPrimaryButton(label: 'Create account', onPressed: onCreateAccount),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onLogIn,
            child: const Text('I already have an account'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MdAnimatedPhotoQuestLogo(
                size: 240,
                loop: true,
                duration: Duration(milliseconds: 3200),
              ),
              Semantics(
                header: true,
                child: Text(
                  'Photo Quest',
                  style: AppTypography.hero.copyWith(color: AppColors.onCoral),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Do something together.\nKeep the memory.',
                textAlign: TextAlign.center,
                style: AppTypography.heading3.copyWith(
                  color: AppColors.onCoral,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  MdSticker(
                    label: 'No feed',
                    tilt: -0.07,
                    sway: true,
                    color: AppColors.paper,
                    delay: Duration(milliseconds: 900),
                  ),
                  MdSticker(
                    label: 'No likes',
                    tilt: 0.05,
                    sway: true,
                    delay: Duration(milliseconds: 1050),
                  ),
                  MdSticker(
                    label: 'Just your people',
                    tilt: -0.03,
                    sway: true,
                    color: AppColors.softPeach,
                    delay: Duration(milliseconds: 1200),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
