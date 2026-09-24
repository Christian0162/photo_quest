import 'package:flutter/material.dart';

import '../../../../config/constant/app_theme.dart';

/// The phone frame every template preview renders at (`@Preview` only
/// accepts literals and public symbols).
const previewPhoneSize = Size(390, 844);

/// Wraps a template for `flutter widget-preview` with the app's themed
/// [MaterialApp]. Previews feed templates plain sample data from
/// `preview_samples.dart` — no providers or database needed.
class MdAppWidgetPreview extends StatelessWidget {
  const MdAppWidgetPreview({super.key, required this.child});

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
