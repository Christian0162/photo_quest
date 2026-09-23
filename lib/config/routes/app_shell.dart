import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constant/app_colors.dart';
import '../constant/app_motion.dart';
import '../constant/app_shadows.dart';
import '../constant/app_spacing.dart';
import '../constant/app_typography.dart';
import 'app_router.dart';

/// Bottom navigation shell shared by Home, Memories and People, with the
/// primary Quest action raised in the center: `Home  Memories  [+]  People`.
/// See CLAUDE.md §32, design system §12.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.photo_library_outlined, Icons.photo_library_rounded, 'Memories'),
    (Icons.people_outline_rounded, Icons.people_alt_rounded, 'People'),
  ];

  @override
  Widget build(BuildContext context) {
    Widget destination(int index) {
      final (icon, selectedIcon, label) = _destinations[index];
      return Expanded(
        child: _NavDestination(
          icon: icon,
          selectedIcon: selectedIcon,
          label: label,
          selected: navigationShell.currentIndex == index,
          onTap: () => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.paper,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
          boxShadow: AppShadows.floating,
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                destination(0),
                destination(1),
                Expanded(
                  child: Center(
                    child: _CreateQuestButton(
                      onTap: () => context.push(AppRoutes.quests),
                    ),
                  ),
                ),
                destination(2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDestination extends StatelessWidget {
  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.short);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: AppTouch.minTarget,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Selected = filled icon + pill + bold label, never color alone.
            AnimatedContainer(
              duration: duration,
              curve: AppMotion.standard,
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                color: selected ? AppColors.softPeach : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                size: AppIconSizes.lg,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                color: selected ? AppColors.textPrimary : AppColors.textMuted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The raised center action. Coral with charcoal content for contrast
/// (CLAUDE.md §28, §65).
class _CreateQuestButton extends StatelessWidget {
  const _CreateQuestButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Start a quest',
      child: Semantics(
        button: true,
        label: 'Start a quest',
        excludeSemantics: true,
        child: Material(
          color: AppColors.warmCoral,
          shape: const CircleBorder(),
          elevation: 0,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(
                Icons.add_rounded,
                size: AppIconSizes.xl,
                color: AppColors.onCoral,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
