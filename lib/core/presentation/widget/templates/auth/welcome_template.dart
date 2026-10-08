import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../molecules/common/md_animated_photoquest_logo.dart';

/// The first thing a signed-out person sees. It carries on from the launch
/// reveal (same coral, same prints) so the app feels like one continuous
/// moment, then asks one thing: make an account. Returning people have a
/// quieter way in underneath.
///
/// ```text
/// ╭───────────────────────────╮
/// │        ╱▭╲ ┌─┐ ╱▭╲        │
/// │        Photo Quest        │
/// │ Do something together.    │
/// │ Keep the memory.          │
/// │ ╭───────────────────────╮ │
/// │ │  [ Create account ]   │ │
/// │ │  Log in               │ │
/// ╰─┴───────────────────────┴─╯
/// ```
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
    return Scaffold(
      backgroundColor: AppColors.warmCoral,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.gutter,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const MdAnimatedPhotoQuestLogo(size: 280),
                        Semantics(
                          header: true,
                          child: Text(
                            'Photo Quest',
                            style: AppTypography.display.copyWith(
                              color: AppColors.onCoral,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Do something together.\nKeep the memory.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.onCoral,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter,
                    AppSpacing.lg,
                    AppSpacing.gutter,
                    AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      MdPrimaryButton(
                        label: 'Create account',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
