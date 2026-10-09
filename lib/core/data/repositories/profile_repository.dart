import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/auth/entities/user_profile.dart';
import '../../errors/app_failure.dart';
import '../services/storage/storage_tree_cleaner.dart';

/// Source of truth for the signed-in person's profile and avatar.
///
/// Whose profile is always taken from the Supabase session, never passed in,
/// so a caller can't ask for someone else's. Row Level Security and the
/// `avatars` storage policies enforce the same rule on the server.
class ProfileRepository {
  ProfileRepository(this._client, {StorageTreeCleaner? cleaner})
    : _cleaner = cleaner ?? const StorageTreeCleaner();

  final SupabaseClient? _client;
  final StorageTreeCleaner _cleaner;

  static const _avatarBucket = 'avatars';
  static const _photosBucket = 'photos';
  static const _signedUrlSeconds = 3600;

  SupabaseClient get _db {
    final client = _client;
    if (client == null) throw const ProfileFailure();
    return client;
  }

  String get _userId {
    final id = _db.auth.currentUser?.id;
    if (id == null) throw const ProfileFailure();
    return id;
  }

  Future<UserProfile> getMyProfile() => _guard(() async {
    final id = _userId;
    final row = await _db
        .from('profiles')
        .select('id, display_name, avatar_path')
        .eq('id', id)
        .maybeSingle();
    return UserProfile(
      id: id,
      displayName: row?['display_name'] as String?,
      avatarPath: row?['avatar_path'] as String?,
    );
  });

  Future<void> updateDisplayName(String name) => _guard(() async {
    final trimmed = name.trim();
    await _db
        .from('profiles')
        .update({'display_name': trimmed.isEmpty ? null : trimmed})
        .eq('id', _userId);
  });

  /// Uploads [bytes] as the new avatar, points the profile at it, and removes
  /// the previous file. Returns the new storage path.
  Future<String> replaceAvatar(
    Uint8List bytes, {
    required String extension,
    String? previousPath,
  }) => _guard(() async {
    final id = _userId;
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$id/avatar_$stamp.$extension';
    await _db.storage
        .from(_avatarBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: _mimeType(extension)),
        );
    await _db.from('profiles').update({'avatar_path': path}).eq('id', id);
    if (previousPath != null && previousPath != path) {
      // Best effort: a leftover file is harmless, a failed save is not.
      try {
        await _db.storage.from(_avatarBucket).remove([previousPath]);
      } on StorageException {
        return path;
      }
    }
    return path;
  });

  /// Deletes the signed-in person's account and everything they own online.
  ///
  /// Storage files are not removed by database cascades, so they go first:
  /// everything under `<user id>/` in the `photos` and `avatars` buckets.
  /// Only then is the account deleted, which removes every row by cascade.
  /// If anything fails before the account is gone, the account is untouched
  /// and the whole thing can simply be tried again.
  Future<void> deleteMyAccount() async {
    try {
      final id = _userId;
      for (final bucket in const [_photosBucket, _avatarBucket]) {
        final files = _db.storage.from(bucket);
        await _cleaner.deleteTree(
          id,
          list: (folder, offset) async {
            final items = await files.list(
              path: folder,
              searchOptions: SearchOptions(
                limit: _cleaner.pageSize,
                offset: offset,
              ),
            );
            // Folders come back without an id; files have one.
            return [
              for (final item in items)
                StorageEntry(item.name, isFolder: item.id == null),
            ];
          },
          remove: (paths) async {
            await files.remove(paths);
          },
        );
      }
      await _db.rpc<void>('delete_my_account');
    } on AppFailure {
      rethrow;
    } on Exception {
      throw const ProfileFailure(
        "We couldn't delete your account. Nothing was lost, so please try "
        'again.',
      );
    }
    // The account is gone; forget the saved session on this phone. If this
    // fails there is nothing left to protect, so it is not an error.
    try {
      await _db.auth.signOut(scope: SignOutScope.local);
    } on Exception {
      return;
    }
  }

  /// A short-lived link for the private avatar. `null` when there is no avatar
  /// or the link can't be made.
  Future<String?> avatarUrl(String? path) async {
    if (path == null) return null;
    try {
      return await _db.storage
          .from(_avatarBucket)
          .createSignedUrl(path, _signedUrlSeconds);
    } on StorageException {
      return null;
    }
  }

  static String _mimeType(String extension) => switch (extension) {
    'png' => 'image/png',
    'webp' => 'image/webp',
    _ => 'image/jpeg',
  };

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppFailure {
      rethrow;
    } on StorageException {
      throw const ProfileFailure(
        "We couldn't save your photo. Please try a smaller picture.",
      );
    } on PostgrestException {
      throw const ProfileFailure();
    } on AuthException {
      throw const ProfileFailure();
    } on Exception {
      throw const ProfileFailure();
    }
  }
}
