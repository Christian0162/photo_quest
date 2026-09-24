import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import '../molecules/app_widget_preview.dart';
import 'settings_template.dart';

@Preview(name: 'Settings', group: 'templates', size: previewPhoneSize)
Widget settingsTemplatePreview() =>
    AppWidgetPreview(child: SettingsTemplate(onOpenLicenses: () {}));
