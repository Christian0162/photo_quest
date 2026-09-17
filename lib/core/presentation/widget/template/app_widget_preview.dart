import 'package:flutter/material.dart';

import '../../../../config/constant/app_theme.dart';

/// Wraps a screen for `flutter widget-preview` with the app's themed
/// [MaterialApp]. Each `*_preview.dart` file wraps this in its own
/// `ProviderScope` with the specific providers it needs to override, since
/// Riverpod 3's `Override` type isn't part of the public API surface to
/// name here directly. See CLAUDE.md §61 (reuse existing abstractions).
class AppWidgetPreview extends StatelessWidget {
  const AppWidgetPreview({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: child,
    );
  }
}
