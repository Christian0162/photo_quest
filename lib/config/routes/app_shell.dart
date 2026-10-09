import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:go_router/go_router.dart';

import '../../core/presentation/widget/atoms/md_fade_slide_in.dart';
import '../../core/presentation/widget/molecules/md_quest_prompt_bar.dart';
import '../../core/utils/app_haptics.dart';
import '../constant/app_colors.dart';
import '../constant/app_motion.dart';
import '../constant/app_shadows.dart';
import '../constant/app_spacing.dart';
import 'app_router.dart';

/// Bottom chrome shared by Home, Memories and People: the quest prompt
/// floating over a charcoal dock of three tabs, like the body of a camera:
///
/// ```text
/// ╭────────────────────────────────────╮
/// │ (✦) Start a quest              (+) │
/// ╰────────────────────────────────────╯
/// ╭────────────────────────────────────╮
/// │     (⌂)        ▢        👥         │
/// ╰────────────────────────────────────╯
/// ```
///
/// The prompt is the app's primary action (start a quest). It tucks away
/// while you scroll down to read, and comes back as soon as you scroll up
/// or switch tabs. See CLAUDE.md §32, design system §12, §58.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.photo_library_outlined, Icons.photo_library_rounded, 'Memories'),
    (Icons.people_outline_rounded, Icons.people_alt_rounded, 'People'),
  ];

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _promptShown = true;

  void _goTo(int index) {
    AppHaptics.selection();
    setState(() => _promptShown = true);
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  /// Hides the prompt while reading down a page; shows it again on the way
  /// back up. Sideways shelves and chip rows don't count.
  bool _onScroll(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final shown = switch (notification.direction) {
      ScrollDirection.reverse => false,
      ScrollDirection.forward => true,
      ScrollDirection.idle => _promptShown,
    };
    if (shown != _promptShown) {
      setState(() => _promptShown = shown);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);

    return Scaffold(
      body: NotificationListener<UserScrollNotification>(
        onNotification: _onScroll,
        child: widget.navigationShell,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppSpacing.ms),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Rises into place on first show; collapses its space and
              // slides down behind the dock while hidden, so the page gets
              // the room back smoothly.
              MdFadeSlideIn(
                order: 2,
                child: ClipRect(
                  child: AnimatedAlign(
                    duration: duration,
                    curve: AppMotion.standard,
                    alignment: Alignment.topCenter,
                    heightFactor: _promptShown ? 1 : 0,
                    child: AnimatedSlide(
                      duration: duration,
                      curve: AppMotion.standard,
                      offset: _promptShown ? Offset.zero : const Offset(0, 0.4),
                      child: AnimatedOpacity(
                        duration: duration,
                        curve: AppMotion.standard,
                        opacity: _promptShown ? 1 : 0,
                        child: Padding(
                          // Room for the bar's shadow inside the clip.
                          padding: const EdgeInsets.only(
                            top: AppSpacing.md,
                            bottom: AppSpacing.sm,
                          ),
                          child: ExcludeSemantics(
                            excluding: !_promptShown,
                            child: IgnorePointer(
                              ignoring: !_promptShown,
                              child: MdQuestPromptBar(
                                onTap: () {
                                  AppHaptics.tap();
                                  context.push(AppRoutes.quests);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.dock,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: AppShadows.floating,
                ),
                child: SizedBox(
                  height: AppSpacing.dockHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: _DockTabs(
                      destinations: AppShell._destinations,
                      currentIndex: widget.navigationShell.currentIndex,
                      onTap: _goTo,
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

/// The dock's tabs: equal slots with one cream bubble behind the selected
/// icon. On a switch the bubble glides to the new tab, stretching a little
/// mid-flight like a drop of liquid, then settles. Selection is also shown
/// by the filled icon, never by color alone (CLAUDE.md §65); under reduced
/// motion the bubble jumps.
class _DockTabs extends StatefulWidget {
  const _DockTabs({
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
  });

  final List<(IconData, IconData, String)> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<_DockTabs> createState() => _DockTabsState();
}

class _DockTabsState extends State<_DockTabs>
    with SingleTickerProviderStateMixin {
  static const _bubbleWidth = 56.0;

  /// How much wider the bubble gets at the middle of its glide.
  static const _stretch = 0.55;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late double _from = widget.currentIndex.toDouble();
  late double _to = widget.currentIndex.toDouble();

  double get _progress => Curves.easeInOutCubic.transform(_controller.value);

  /// Where the bubble is right now, in tab slots.
  double get _position => _from + (_to - _from) * _progress;

  @override
  void didUpdateWidget(_DockTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex == oldWidget.currentIndex) return;

    // Start from wherever the bubble is, so a quick second tap never jumps.
    _from = _position;
    _to = widget.currentIndex.toDouble();
    if (AppMotion.reduced(context)) {
      _controller.value = 1;
    } else {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final slot = constraints.maxWidth / widget.destinations.length;

        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                // Stretches on the way, back to round on arrival.
                final pull =
                    math.sin(math.pi * _progress) *
                    (_to - _from).abs().clamp(0, 1);
                final width = _bubbleWidth * (1 + _stretch * pull);
                return Positioned(
                  left: slot * (_position + 0.5) - width / 2,
                  top: 0,
                  bottom: 0,
                  width: width,
                  child: Center(
                    child: Container(
                      height: AppTouch.minTarget * (1 - 0.12 * pull),
                      decoration: BoxDecoration(
                        color: AppColors.warmCream,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                );
              },
            ),
            Row(
              children: [
                for (final (index, (icon, selectedIcon, label))
                    in widget.destinations.indexed)
                  Expanded(
                    child: _DockTab(
                      icon: icon,
                      selectedIcon: selectedIcon,
                      label: label,
                      selected: widget.currentIndex == index,
                      onTap: () => widget.onTap(index),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// One tab's icon and tap target. The bubble behind it lives in
/// [_DockTabs].
class _DockTab extends StatelessWidget {
  const _DockTab({
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
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox.expand(
            child: Center(
              // The icon fills in as the bubble arrives underneath it.
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.medium),
                switchInCurve: AppMotion.standard,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: Tween(begin: 0.7, end: 1.0).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  key: ValueKey(selected),
                  size: AppIconSizes.lg,
                  color: selected
                      ? AppColors.textPrimary
                      : AppColors.onDockMuted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
