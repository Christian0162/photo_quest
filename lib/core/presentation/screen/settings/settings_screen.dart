import 'package:flutter/material.dart';

import '../../widget/template/settings_template.dart';

/// Settings. Design lives in [SettingsTemplate]. See CLAUDE.md §56.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsTemplate(
      onOpenLicenses: () =>
          showLicensePage(context: context, applicationName: 'Photo Quest'),
    );
  }
}
