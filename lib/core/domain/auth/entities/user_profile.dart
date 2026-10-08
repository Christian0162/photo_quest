/// The signed-in person's public-to-themselves profile (`profiles` row).
class UserProfile {
  const UserProfile({required this.id, this.displayName, this.avatarPath});

  final String id;
  final String? displayName;

  /// Path inside the private `avatars` bucket, e.g. `<user id>/avatar_1.jpg`.
  final String? avatarPath;
}
