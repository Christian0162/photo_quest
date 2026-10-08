import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/constant/app_colors.dart';
import '../../../../../config/constant/app_motion.dart';
import '../../../../../config/constant/app_spacing.dart';
import '../../../../../config/constant/app_typography.dart';
import '../../atoms/common/md_round_icon_button.dart';
import '../../molecules/common/md_animated_photoquest_logo.dart';

/// The frame every account screen shares: a coral band with the Photo Quest
/// mark, and a cream sheet rising over it that holds the form.
///
/// ```text
/// ╭──────────────────────────────╮
/// │ (←)          ✦               │  coral band, the mark
/// │          ╱▭╲ ┌─┐ ╱▭╲        │
/// │ ╭──────────────────────────╮ │
/// │ │ Welcome back             │ │  cream sheet
/// │ │ Log in to pick up…       │ │
/// │ │ [ form fields ]          │ │
/// ╰─┴──────────────────────────┴─╯
/// ```
///
/// The band folds down while the keyboard is open so the form keeps the room.
/// While [busy] the mark plays its looping "developing" animation, so the
/// brand — not a spinner — says something is happening. The primary action is
/// pinned by the scaffold, not here.
class MdAuthLayout extends StatelessWidget {
  const MdAuthLayout({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.busy = false,
    this.onBack,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool busy;

  /// Shows a back button on the band.
  final VoidCallback? onBack;

  /// A quiet row of links under the form (e.g. "New here? Create account").
  final Widget? footer;

  static const _bandHeight = 184.0;
  static const _bandHeightCompact = 88.0;
  static const _logoSize = 132.0;
  static const _logoSizeCompact = 64.0;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.viewInsetsOf(context).bottom > 0;
    final duration = AppMotion.of(context, AppMotion.short);
    final onBack = this.onBack;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: ColoredBox(
        color: AppColors.warmCoral,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              AnimatedContainer(
                duration: duration,
                curve: AppMotion.standard,
                height: compact ? _bandHeightCompact : _bandHeight,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    OverflowBox(
                      maxHeight: _logoSize,
                      child: MdAnimatedPhotoQuestLogo(
                        size: compact ? _logoSizeCompact : _logoSize,
                        playing: busy,
                        loop: true,
                      ),
                    ),
                    if (onBack != null)
                      Positioned(
                        left: AppSpacing.sm,
                        top: AppSpacing.sm,
                        child: MdRoundIconButton(
                          icon: Icons.arrow_back_rounded,
                          tooltip: 'Back',
                          onPressed: onBack,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                    child: AutofillGroup(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.gutter,
                          AppSpacing.xl,
                          AppSpacing.gutter,
                          AppSpacing.lg,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Semantics(
                              header: true,
                              child: Text(title, style: AppTypography.heading1),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(subtitle!, style: AppTypography.bodyMuted),
                            ],
                            const SizedBox(height: AppSpacing.lg),
                            for (final (index, child) in children.indexed) ...[
                              if (index > 0)
                                const SizedBox(height: AppSpacing.md),
                              child,
                            ],
                            if (footer != null) ...[
                              const SizedBox(height: AppSpacing.lg),
                              footer!,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
