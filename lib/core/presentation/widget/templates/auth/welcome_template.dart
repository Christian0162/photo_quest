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

  static const _logoSize = 240.0;

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      backgroundColor: AppColors.background,
      overlayStyle: SystemUiOverlayStyle.dark,
      body: Stack(
        children: [
          // Button-coral washed into a soft pink, fading to near white.
          Positioned.fill(
            child: ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.warmCoral.withValues(alpha: 0.24),
                      AppColors.warmCoral.withValues(alpha: 0.10),
                      AppColors.background,
                    ],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _LogoGlow(
                          // The logo's canvas has empty margin around the
                          // prints; trim its layout height so the title sits
                          // right under them (painting still overflows).
                          child: const Align(
                            heightFactor: 0.64,
                            child: MdAnimatedPhotoQuestLogo(
                              size: _logoSize,
                              loop: true,
                              duration: Duration(milliseconds: 3200),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Semantics(
                          header: true,
                          // Scales down rather than wrapping on narrow phones or large text.
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Photo Quest',
                              style: AppTypography.hero,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Do something together.\nKeep the memory.',
                          textAlign: TextAlign.center,
                          style: AppTypography.heading3.copyWith(
                            color: AppColors.textPrimary,
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
                              color: AppColors.softPeach,
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
                              color: AppColors.paper,
                              delay: Duration(milliseconds: 1200),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Pinned to the bottom, so the actions are always in the same
              // thumb-reach spot whatever the screen height.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  AppSpacing.md,
                  AppSpacing.gutter,
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MdPrimaryButton(
                      label: 'Create account',
                      flat: true,
                      foregroundColor: Colors.white,
                      onPressed: onCreateAccount,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: onLogIn,
                      child: const Text('I already have an account'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A soft peach glow behind the logo, so the print sits in warm light
/// instead of floating on flat cream.
class _LogoGlow extends StatelessWidget {
  const _LogoGlow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The glow spills past the logo without taking layout space, so the
    // title sits right under the print.
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: OverflowBox(
              minWidth: 0,
              minHeight: 0,
              maxWidth: WelcomeTemplate._logoSize * 1.3,
              maxHeight: WelcomeTemplate._logoSize * 1.3,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.softPeach,
                      AppColors.softPeach.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
