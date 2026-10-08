/// What the Account screen shows about the signed-in person.
class AccountData {
  const AccountData({
    required this.email,
    this.displayName,
    this.avatarPath,
    this.avatarUrl,
  });

  final String email;
  final String? displayName;

  final String? avatarPath;

  final String? avatarUrl;

  /// The name to greet them with: their display name, else the part of the
  /// email before the @.
  String get greetingName {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final local = email.split('@').first;
    return local.isEmpty ? 'friend' : local;
  }

  AccountData copyWith({
    Object? displayName = _keep,
    String? avatarPath,
    String? avatarUrl,
  }) => AccountData(
    email: email,
    displayName: identical(displayName, _keep)
        ? this.displayName
        : displayName as String?,
    avatarPath: avatarPath ?? this.avatarPath,
    avatarUrl: avatarUrl ?? this.avatarUrl,
  );
}

const _keep = Object();

/// The display name being typed on the Account screen, before it is saved.
class AccountNameDraft {
  const AccountNameDraft({this.text, this.saving = false});

  final String? text;
  final bool saving;

  AccountNameDraft copyWith({Object? text = _keep, bool? saving}) =>
      AccountNameDraft(
        text: identical(text, _keep) ? this.text : text as String?,
        saving: saving ?? this.saving,
      );
}
