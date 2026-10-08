import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_router.dart';
import '../../view_model/homes/profile_view_model.dart';
import '../../widget/templates/settings_template.dart';

/// Settings. Design lives in [SettingsTemplate]. See CLAUDE.md §56.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsTemplate(
      name: ref.watch(selfPersonProvider).value?.name,
      avatarId: ref.watch(avatarSettingProvider).value,
      onOpenProfile: () => context.push(AppRoutes.profileSettings),
      onOpenLicenses: () =>
          showLicensePage(context: context, applicationName: 'Photo Quest'),
    );
  }
}
