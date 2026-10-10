import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../../view_model/auth/auth_sheet_view_model.dart';
import '../../atoms/common/md_primary_button.dart';
import '../../atoms/common/md_soft_backdrop.dart';
import '../../atoms/common/md_sticker.dart';
import '../../molecules/common/md_brand_header.dart';
import '../../organisms/auth/md_auth_sheet.dart';
import '../../organisms/common/md_app_scaffold.dart';

/// The way in: the brand on top, and a drawer at the bottom that holds
/// "Create account" and "I already have an account". Choosing one (or
/// dragging the drawer up) lifts it over the page to show that form, while
/// the logo and title stay above it.
class WelcomeTemplate extends StatelessWidget {
  const WelcomeTemplate({
    super.key,
    required this.mode,
    required this.formBuilder,
    required this.onCreateAccount,
    required this.onLogIn,
    required this.onClose,
    required this.onExpandedChanged,
  });

  final AuthSheetMode mode;

  /// The form for [mode], built on the drawer's scroll controller. Only
  /// asked for while the drawer is open.
  final Widget Function(BuildContext context, ScrollController controller)
  formBuilder;

  final VoidCallback onCreateAccount;
  final VoidCallback onLogIn;
  final VoidCallback onClose;
  final ValueChanged<bool> onExpandedChanged;

  /// Handle, two actions and their padding, before the system inset.
  static const _collapsedHeight = 184.0;

  /// Room kept above the open drawer for the brand.
  static const _expandedTopGap = 112.0;

  @override
  Widget build(BuildContext context) {
    final expanded = mode != AuthSheetMode.actions;
    final padding = MediaQuery.paddingOf(context);
    final duration = AppMotion.of(context, AppMotion.medium);

    return MdAppScaffold(
      backgroundColor: AppColors.background,
      overlayStyle: SystemUiOverlayStyle.dark,
      safeArea: false,
      // System back closes the drawer first; only then does it leave the app.
      onBackBlocked: expanded ? onClose : null,
      body: Stack(
        children: [
          const Positioned.fill(child: MdSoftBackdrop()),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: _collapsedHeight + padding.bottom,
            child: AnimatedAlign(
              duration: duration,
              curve: AppMotion.standard,
              alignment: expanded ? Alignment.topCenter : Alignment.center,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.gutter,
                  padding.top + AppSpacing.sm,
                  AppSpacing.gutter,
                  0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MdBrandHeader(
                      logoSize: expanded ? 72 : 240,
                      titleSize: expanded ? 32 : 52,
                      glow: !expanded,
                    ),
                    AnimatedSize(
                      duration: duration,
                      curve: AppMotion.standard,
                      alignment: Alignment.topCenter,
                      child: expanded
                          ? const SizedBox(width: double.infinity)
                          : const _Pitch(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: MdAuthSheet(
              expanded: expanded,
              onExpandedChanged: onExpandedChanged,
              collapsedHeight: _collapsedHeight + padding.bottom,
              expandedTopGap: padding.top + _expandedTopGap,
              builder: (context, scrollController, _) {
                if (expanded) return formBuilder(context, scrollController);
                return MdAuthSheetPage(
                  scrollController: scrollController,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The tagline and what the app does not do, under the brand.
class _Pitch extends StatelessWidget {
  const _Pitch();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.md),
        Text(
          'Do something together.\nKeep the memory.',
          textAlign: TextAlign.center,
          style: AppTypography.heading3.copyWith(color: AppColors.textPrimary),
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
    );
  }
}
