import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../../../../core/widgets/preview/app_widget_preview.dart';
import 'settings_screen.dart';

@Preview(name: 'Settings', group: 'screens', size: Size(390, 844))
Widget settingsScreenPreview() {
  return const AppWidgetPreview(child: SettingsScreen());
}
