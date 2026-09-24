import 'package:flutter/material.dart';

import '../molecules/bottom_action_bar.dart';

/// The one page shell every template is built on: an optional app bar, safe
/// area insets, an optional pinned bottom action, and back-button
/// interception. Templates fill the slots instead of re-assembling a
/// [Scaffold] each time. See CLAUDE.md §25, §66.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.showAppBar = false,
    this.title,
    this.leading,
    this.actions,
    this.bottomAction,
    this.backgroundColor,
    this.safeArea = true,
    this.onBackBlocked,
  });

  final Widget body;

  /// Shows the themed app bar (with a back button when the route can pop).
  final bool showAppBar;
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;

  /// Pinned under the body in a [BottomActionBar], so the primary action is
  /// always one thumb away and rides above the keyboard.
  final Widget? bottomAction;
  final Color? backgroundColor;

  /// Keeps the body clear of notches and system bars when there's no app
  /// bar. Off for edge-to-edge screens like the photobooth.
  final bool safeArea;

  /// When set, system back is blocked and this runs instead — for flows
  /// that should confirm before leaving.
  final VoidCallback? onBackBlocked;

  @override
  Widget build(BuildContext context) {
    Widget content = body;
    if (bottomAction != null) {
      content = Column(
        children: [
          Expanded(child: content),
          BottomActionBar(child: bottomAction!),
        ],
      );
    }
    if (safeArea && !showAppBar) {
      // The bottom action bar handles its own bottom inset.
      content = SafeArea(bottom: bottomAction == null, child: content);
    }

    final scaffold = Scaffold(
      backgroundColor: backgroundColor,
      appBar: showAppBar
          ? AppBar(
              title: title == null ? null : Text(title!),
              leading: leading,
              actions: actions,
            )
          : null,
      body: content,
    );

    final onBackBlocked = this.onBackBlocked;
    if (onBackBlocked == null) return scaffold;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBackBlocked();
      },
      child: scaffold,
    );
  }
}

/// Shows a short, friendly message at the bottom of the current screen.
/// Copy should be human, never a raw error. See CLAUDE.md §42, §57.
///
/// Pass [actionLabel] + [onAction] to offer a way back, e.g. "Undo" after
/// removing something. A new message replaces the current one instead of
/// queueing behind it.
void showAppMessage(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction),
      ),
    );
}
