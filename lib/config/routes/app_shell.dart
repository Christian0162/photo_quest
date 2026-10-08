import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:go_router/go_router.dart';

import '../../core/presentation/widget/atoms/md_fade_slide_in.dart';
import '../../core/presentation/widget/atoms/md_pressable_scale.dart';
import '../../core/presentation/widget/molecules/md_quest_prompt_bar.dart';
import '../../core/utils/app_haptics.dart';
import '../constant/app_colors.dart';
import '../constant/app_motion.dart';
import '../constant/app_shadows.dart';
import '../constant/app_spacing.dart';
import 'app_router.dart';

/// Bottom chrome shared by Home, Quests, Memories and People: one compact
/// charcoal dock, like the body of a camera, with the app's primary action
/// (start a quest) as the coral "+" in the middle:
///
/// ```text
/// ╭──────────────────────────────────╮
/// │  📷    ▢▢    (+)    🖼    👥     │
/// ╰──────────────────────────────────╯
/// ```
///
/// The "+" is not a tab: it opens quest creation. See CLAUDE.md §32, design
/// system §12, §58.
///
/// The dock floats over the page (no bar behind it), tucks away while you
/// scroll down to read, and comes back as soon as you scroll up or switch
/// tabs.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _questsBranch = 1;

  /// Dock slots, left to right. A null [_DockItem.branch] is the "+" action.
  static const _items = [
    _DockItem(
      branch: 0,
      icon: Icons.photo_camera_outlined,
      selectedIcon: Icons.photo_camera_rounded,
      label: 'Home',
    ),
    _DockItem(
      branch: 1,
      icon: Icons.content_copy_outlined,
      selectedIcon: Icons.content_copy_rounded,
      label: 'Quests',
    ),
    _DockItem(
      branch: null,
      icon: Icons.add_rounded,
      selectedIcon: Icons.add_rounded,
      label: 'Make a quest',
    ),
    _DockItem(
      branch: 2,
      icon: Icons.photo_library_outlined,
      selectedIcon: Icons.photo_library_rounded,
      label: 'Memories',
    ),
    _DockItem(
      branch: 3,
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_alt_rounded,
      label: 'People',
    ),
  ];

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _dockShown = true;

  /// The "Start a quest" nudge: shown when the app opens, and it stays until
  /// the user closes it with its X.
  bool _welcomeShown = true;

  void _dismissWelcome() => setState(() => _welcomeShown = false);

  void _openQuests() {
    AppHaptics.tap();
    widget.navigationShell.goBranch(
      AppShell._questsBranch,
      initialLocation:
          widget.navigationShell.currentIndex == AppShell._questsBranch,
    );
  }

  void _onTap(_DockItem item) {
    if (item.branch == null) {
      AppHaptics.tap();
      context.push(AppRoutes.createQuest);
      return;
    }
    AppHaptics.selection();
    setState(() => _dockShown = true);
    widget.navigationShell.goBranch(
      item.branch!,
      initialLocation: item.branch == widget.navigationShell.currentIndex,
    );
  }

  /// How far (or how fast) a sideways swipe must go to change tabs, so a
  /// slip of the thumb while scrolling doesn't.
  static const _swipeDistance = 72.0;
  static const _swipeVelocity = 700.0;

  double _swipeDx = 0;

  /// Swiping left moves to the next tab, right to the previous one. A
  /// sideways shelf under the finger keeps its own swipe.
  void _onSwipeEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final dx = _swipeDx;
    _swipeDx = 0;

    final far = dx.abs() >= _swipeDistance;
    final fast = velocity.abs() >= _swipeVelocity;
    if (!far && !fast) return;

    // The direction the finger travelled, from distance or, failing that,
    // speed.
    final toNext = (dx != 0 ? dx : velocity) < 0;
    final current = widget.navigationShell.currentIndex;
    final target = current + (toNext ? 1 : -1);
    if (target < 0 || target >= widget.navigationShell.route.branches.length) {
      return;
    }

    AppHaptics.selection();
    setState(() => _dockShown = true);
    widget.navigationShell.goBranch(target);
  }

  /// Hides the dock while reading down a page; shows it again on the way
  /// back up. Sideways shelves and chip rows don't count.
  bool _onScroll(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    final shown = switch (notification.direction) {
      ScrollDirection.reverse => false,
      ScrollDirection.forward => true,
      ScrollDirection.idle => _dockShown,
    };
    if (shown != _dockShown) {
      setState(() => _dockShown = shown);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);
    final selectedSlot = AppShell._items.indexWhere(
      (item) => item.branch == widget.navigationShell.currentIndex,
    );

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) => _swipeDx = 0,
            onHorizontalDragUpdate: (details) => _swipeDx += details.delta.dx,
            onHorizontalDragEnd: _onSwipeEnd,
            onHorizontalDragCancel: () => _swipeDx = 0,
            child: NotificationListener<UserScrollNotification>(
              onNotification: _onScroll,
              child: widget.navigationShell,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                // Lifted off the screen edge, on top of any system inset.
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: MdFadeSlideIn(
                  order: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Stays on screen. While the dock is tucked away its
                      // space collapses, so the card glides down to where
                      // the dock was, and back up when the dock returns.
                      AnimatedSize(
                        duration: duration,
                        curve: AppMotion.standard,
                        alignment: Alignment.bottomCenter,
                        child: _welcomeShown
                            ? MdQuestPromptBar(
                                onTap: _openQuests,
                                onClose: _dismissWelcome,
                              )
                            : const SizedBox(width: double.infinity),
                      ),
                      AnimatedAlign(
                        duration: duration,
                        curve: AppMotion.standard,
                        alignment: Alignment.bottomCenter,
                        heightFactor: _dockShown ? 1 : 0,
                        child: AnimatedOpacity(
                          duration: duration,
                          curve: AppMotion.standard,
                          opacity: _dockShown ? 1 : 0,
                          child: ExcludeSemantics(
                            excluding: !_dockShown,
                            child: IgnorePointer(
                              ignoring: !_dockShown,
                              child: Padding(
                                padding: EdgeInsets.only(
                                  top: _welcomeShown ? AppSpacing.ms : 0,
                                ),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: AppColors.dock,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.floating,
                                    ),
                                    boxShadow: AppShadows.floating,
                                  ),
                                  child: SizedBox(
                                    height: AppSpacing.dockHeight,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xs,
                                      ),
                                      child: _DockTabs(
                                        items: AppShell._items,
                                        selectedSlot: selectedSlot,
                                        onTap: _onTap,
                                      ),
                                    ),
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }
}

class _DockItem {
  const _DockItem({
    required this.branch,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  /// The shell branch this opens, or null for the "+" action.
  final int? branch;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// The dock's slots: equal widths with one cream bubble behind the selected
/// icon. On a switch the bubble glides to the new tab, stretching a little
/// mid-flight like a drop of liquid, then settles. Selection is also shown
/// by the filled icon, never by color alone (CLAUDE.md §65); under reduced
/// motion the bubble jumps.
class _DockTabs extends StatefulWidget {
  const _DockTabs({
    required this.items,
    required this.selectedSlot,
    required this.onTap,
  });

  final List<_DockItem> items;
  final int selectedSlot;
  final ValueChanged<_DockItem> onTap;

  @override
  State<_DockTabs> createState() => _DockTabsState();
}

class _DockTabsState extends State<_DockTabs>
    with SingleTickerProviderStateMixin {
  static const _bubbleWidth = 48.0;
  static const _bubbleHeight = 40.0;

  /// How much wider the bubble gets at the middle of its glide.
  static const _stretch = 0.55;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );
  late double _from = widget.selectedSlot.toDouble();
  late double _to = widget.selectedSlot.toDouble();

  double get _progress => Curves.easeInOutCubic.transform(_controller.value);

  /// Where the bubble is right now, in slots.
  double get _position => _from + (_to - _from) * _progress;

  @override
  void didUpdateWidget(_DockTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSlot == oldWidget.selectedSlot) return;

    // Start from wherever the bubble is, so a quick second tap never jumps.
    _from = _position;
    _to = widget.selectedSlot.toDouble();
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
        final slot = constraints.maxWidth / widget.items.length;

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
                      height: _bubbleHeight * (1 - 0.12 * pull),
                      decoration: BoxDecoration(
                        color: AppColors.warmCream,
                        borderRadius: BorderRadius.circular(
                          AppRadius.floating - 6,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            Row(
              children: [
                for (final (index, item) in widget.items.indexed)
                  Expanded(
                    child: item.branch == null
                        ? _DockAction(
                            label: item.label,
                            icon: item.icon,
                            onTap: () => widget.onTap(item),
                          )
                        : _DockTab(
                            icon: item.icon,
                            selectedIcon: item.selectedIcon,
                            label: item.label,
                            selected: widget.selectedSlot == index,
                            onTap: () => widget.onTap(item),
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
                  size: AppIconSizes.md,
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

/// The coral "+": the dock's one primary action. Charcoal plus on coral so
/// it stays readable (CLAUDE.md §65).
class _DockAction extends StatelessWidget {
  const _DockAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  static const _size = 44.0;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: MdPressableScale(
              enabled: true,
              scale: 0.92,
              child: Container(
                width: _size,
                height: _size,
                decoration: const BoxDecoration(
                  color: AppColors.warmCoral,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: AppIconSizes.lg,
                  color: AppColors.onCoral,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
