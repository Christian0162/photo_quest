import 'package:flutter/material.dart';

import '../../../../config/constant/app_avatars.dart';
import '../../../../config/constant/app_colors.dart';
import '../../../../config/constant/app_spacing.dart';
import '../../../../config/constant/app_typography.dart';
import '../../../utils/app_haptics.dart';
import '../atoms/md_avatar_image.dart';
import '../atoms/md_primary_button.dart';
import '../organisms/md_app_scaffold.dart';

/// Profile settings: your name and the avatar you show, picked from
/// categories to explore (animals, travel, food…). Both save together with
/// one button. See CLAUDE.md §40, §54A.
class ProfileSettingsTemplate extends StatefulWidget {
  const ProfileSettingsTemplate({
    super.key,
    required this.name,
    required this.avatarId,
    required this.saving,
    required this.onSave,
  });

  /// The name saved so far, empty if there isn't one yet.
  final String name;
  final String? avatarId;
  final bool saving;
  final void Function(String name, String? avatarId) onSave;

  /// The longest name that fits comfortably in memories and Settings.
  static const nameLimit = 30;

  @override
  State<ProfileSettingsTemplate> createState() =>
      _ProfileSettingsTemplateState();
}

class _ProfileSettingsTemplateState extends State<ProfileSettingsTemplate> {
  late final _name = TextEditingController(text: widget.name);
  late String? _avatarId = widget.avatarId;

  /// Which category is open; starts on the one the current avatar is in.
  late AvatarCategory _category = AppAvatars.categoryOf(widget.avatarId);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MdAppScaffold(
      showAppBar: true,
      bottomAction: MdPrimaryButton(
        label: 'Save',
        icon: Icons.check_rounded,
        loading: widget.saving,
        onPressed: () => widget.onSave(_name.text, _avatarId),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.gutter,
          0,
          AppSpacing.gutter,
          AppSpacing.xxl,
        ),
        children: [
          Semantics(
            header: true,
            child: Text('Profile settings', style: AppTypography.heading1),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(child: MdAvatarImage(avatarId: _avatarId, radius: 48)),
          const SizedBox(height: AppSpacing.lg),
          const Text('Your name', style: AppTypography.label),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _name,
            enabled: !widget.saving,
            maxLength: ProfileSettingsTemplate.nameLimit,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'What should we call you?',
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Pick your avatar', style: AppTypography.label),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final category in AppAvatars.categories)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(category.label),
                      selected: category == _category,
                      onSelected: (_) {
                        AppHaptics.selection();
                        setState(() => _category = category);
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.ms,
            runSpacing: AppSpacing.ms,
            children: [
              for (final id in _category.ids)
                _AvatarChoice(
                  id: id,
                  selected: id == _avatarId,
                  onTap: widget.saving
                      ? null
                      : () {
                          AppHaptics.selection();
                          setState(() => _avatarId = id);
                        },
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One avatar in the picker. The chosen one gets a check as well as an
/// outline, so it never relies on color alone.
class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.id,
    required this.selected,
    required this.onTap,
  });

  final String id;
  final bool selected;
  final VoidCallback? onTap;

  static const _size = 68.0;

  /// "ice-cream" becomes "Ice cream", for screen readers.
  String get _label {
    final name = id.split('/').last.replaceAll('-', ' ');
    return '${name[0].toUpperCase()}${name.substring(1)} avatar';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: _label,
      excludeSemantics: true,
      child: InkResponse(
        radius: _size / 2 + AppSpacing.xs,
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: _size,
              height: _size,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: AppColors.textPrimary, width: 2)
                    : null,
              ),
              child: MdAvatarImage(avatarId: id, radius: _size / 2),
            ),
            if (selected)
              const Positioned(
                right: -2,
                bottom: -2,
                child: CircleAvatar(
                  radius: 11,
                  backgroundColor: AppColors.textPrimary,
                  child: Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: AppColors.onCamera,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
