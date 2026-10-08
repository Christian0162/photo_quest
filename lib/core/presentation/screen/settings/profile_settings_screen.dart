import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../view_model/homes/profile_view_model.dart';
import '../../widget/molecules/md_empty_state.dart';
import '../../widget/organisms/md_app_scaffold.dart';
import '../../widget/templates/profile_settings_template.dart';

/// Edit your name and avatar. Wires [ProfileEditor] into
/// [ProfileSettingsTemplate]. See CLAUDE.md §40.
class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final person = ref.watch(selfPersonProvider);
    final avatar = ref.watch(avatarSettingProvider);
    final editor = ref.watch(profileEditorProvider);

    ref.listen(profileEditorProvider, (previous, next) {
      if (next.hasError) {
        showAppMessage(context, "That didn't save. Please try again.");
      }
    });

    // Wait for the saved values, so the fields start filled in.
    if (person.isLoading || avatar.isLoading) {
      return const MdAppScaffold(showAppBar: true, body: SizedBox.shrink());
    }
    if (person.hasError || avatar.hasError) {
      return MdAppScaffold(
        showAppBar: true,
        body: MdEmptyState.error(
          title: "We couldn't open your profile",
          onRetry: () {
            ref.invalidate(selfPersonProvider);
            ref.invalidate(avatarSettingProvider);
          },
        ),
      );
    }

    return ProfileSettingsTemplate(
      name: person.value?.name ?? '',
      avatarId: avatar.value,
      saving: editor.isLoading,
      onSave: (name, avatarId) async {
        final saved = await ref
            .read(profileEditorProvider.notifier)
            .save(name: name, avatarId: avatarId);
        if (saved && context.mounted) context.pop();
      },
    );
  }
}
