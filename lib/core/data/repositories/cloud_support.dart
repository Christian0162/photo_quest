import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/sharing/entities/shared_memory.dart';
import '../../domain/sharing/entities/shared_quest.dart';
import '../../errors/app_failure.dart';

/// What the cloud repositories have in common: the Supabase client, who is
/// signed in (always taken from the session, never passed in), turning every
/// kind of failure into a [SharingFailure] with copy that is safe to show,
/// signed links for private files, and a few small helpers.
class CloudSupport {
  CloudSupport({
    required SupabaseClient? client,
    String? Function()? currentUserId,
  }) : _client = client,
       _currentUserId = currentUserId ?? (() => client?.auth.currentUser?.id);

  final SupabaseClient? _client;
  final String? Function() _currentUserId;

  static const photosBucket = 'photos';
  static const avatarsBucket = 'avatars';
  static const _signedUrlSeconds = 3600;

  SupabaseClient get db {
    final client = _client;
    if (client == null) {
      throw const SharingFailure(
        SharingFailureKind.notConfigured,
        "Sharing isn't set up in this build yet.",
      );
    }
    return client;
  }

  String get userId {
    final id = _currentUserId();
    if (id == null) {
      throw const SharingFailure(
        SharingFailureKind.unknown,
        'Log in to share your memories.',
      );
    }
    return id;
  }

  /// Turns anything that can go wrong into a [SharingFailure].
  Future<T> guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on SharingFailure {
      rethrow;
    } on PostgrestException catch (error) {
      throw _failureFromPostgrest(error);
    } on SocketException {
      throw _offline;
    } on TimeoutException {
      throw _offline;
    } on http.ClientException {
      throw _offline;
    } on StorageException {
      throw const SharingFailure.unknown(
        "We couldn't upload your photos. Please try again.",
      );
    } on AuthException {
      throw const SharingFailure.unknown(
        'Log in again to share your memories.',
      );
    }
  }

  static const _offline = SharingFailure(
    SharingFailureKind.offline,
    "Can't reach Photo Quest right now. Check your connection and try again.",
  );

  static const _storageFull = SharingFailure(
    SharingFailureKind.storageFull,
    'Your online storage is full. Remove the online copy of a memory to make '
    'room.',
  );

  static SharingFailure _failureFromPostgrest(PostgrestException error) {
    final message = error.message;
    switch (error.code) {
      case 'P0002':
        return const SharingFailure(
          SharingFailureKind.notFound,
          "We couldn't find that.",
        );
      case '55000':
        return const SharingFailure(
          SharingFailureKind.notFound,
          'That invitation is no longer open.',
        );
      case '53400':
        return const SharingFailure(
          SharingFailureKind.questFull,
          'This quest is full. Ask the person who invited you to make room.',
        );
      case '42501' when message.contains('not_friends'):
        return const SharingFailure.unknown(
          "You're not friends with them yet. Add them in People first.",
        );
      case '22023' when message.contains('quest_not_shareable'):
        return const SharingFailure.unknown(
          "A quest you do on your own can't be shared. Pick a pair or group "
          'quest.',
        );
      case '54000' when message.contains('too_many_attempts'):
        return const SharingFailure(
          SharingFailureKind.tooManyTries,
          'Too many tries for now. Please wait a little and try again.',
        );
      case '54000':
        return const SharingFailure(
          SharingFailureKind.tooManyInvites,
          'There are already plenty of invite codes in use. Remove one or '
          'wait for one to expire.',
        );
    }
    return const SharingFailure.unknown();
  }

  /// How much online storage the person has used.
  Future<StorageUsage> storageUsage() => guard(() async {
    final rows =
        await db.rpc<dynamic>('my_storage_usage', params: {}) as List<dynamic>;
    if (rows.isEmpty) return const StorageUsage(usedBytes: 0, quotaBytes: 0);
    final row = rows.first as Map<String, dynamic>;
    return StorageUsage(
      usedBytes: (row['used_bytes'] as num).toInt(),
      quotaBytes: (row['quota_bytes'] as num).toInt(),
    );
  });

  /// Uploads [bytes] to the `photos` bucket. A refused upload is explained as
  /// "storage full" when the person really is at their allowance.
  Future<void> uploadPhoto(
    String path,
    Uint8List bytes, {
    required String? contentType,
  }) async {
    try {
      await db.storage
          .from(photosBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: true),
          );
    } on StorageException {
      StorageUsage? usage;
      try {
        usage = await storageUsage();
      } on Object {
        usage = null;
      }
      if (usage != null && usage.isFull) throw _storageFull;
      rethrow;
    }
  }

  Future<Set<String>> existingIds(
    String table,
    String column,
    String value,
  ) async {
    final rows = await db.from(table).select('id').eq(column, value);
    return {for (final row in rows) row['id'] as String};
  }

  Future<Map<String, String>> profileNames(Iterable<String> ids) async {
    final unique = ids.toSet().toList();
    if (unique.isEmpty) return const {};
    final rows = await db
        .from('profiles')
        .select('id, display_name')
        .inFilter('id', unique);
    return {
      for (final row in rows)
        row['id'] as String: nameOf(row['display_name'] as String?),
    };
  }

  /// Short-lived links for private files, keyed by the file path.
  Future<Map<String, String>> signedUrls(
    String bucket,
    Iterable<String> paths,
  ) async {
    final unique = paths.toSet().toList();
    if (unique.isEmpty) return const {};
    final results = await db.storage
        .from(bucket)
        .createSignedUrlsResult(unique, _signedUrlSeconds);
    return {
      for (final result in results)
        if (result is SignedUrlSuccess) result.path: result.signedUrl,
    };
  }

  /// Turns memory rows (`id`, `title`, `captured_at`, `owner_id`) into cards,
  /// in the same order: who shared each one and a picture from its first
  /// photo.
  Future<List<SharedMemorySummary>> memorySummaries(
    List<Map<String, dynamic>> memoryRows,
  ) async {
    if (memoryRows.isEmpty) return const [];
    final ids = [for (final row in memoryRows) row['id'] as String];
    final names = await profileNames([
      for (final row in memoryRows) row['owner_id'] as String,
    ]);

    final photoRows = await db
        .from('photos')
        .select('memory_id, position, storage_path, thumbnail_path')
        .inFilter('memory_id', ids)
        .order('position', ascending: true);
    final coverPaths = <String, String>{};
    for (final row in photoRows) {
      coverPaths.putIfAbsent(
        row['memory_id'] as String,
        () => (row['thumbnail_path'] ?? row['storage_path']) as String,
      );
    }
    final urls = await signedUrls(photosBucket, coverPaths.values);

    return [
      for (final row in memoryRows)
        SharedMemorySummary(
          id: row['id'] as String,
          title: row['title'] as String,
          capturedAt: DateTime.parse(row['captured_at'] as String).toLocal(),
          ownerName: names[row['owner_id']] ?? 'A friend',
          coverUrl: urls[coverPaths[row['id']]],
        ),
    ];
  }

  static String nameOf(String? displayName) {
    final name = displayName?.trim();
    return name == null || name.isEmpty ? 'A friend' : name;
  }

  static String iso(DateTime time) => time.toUtc().toIso8601String();

  /// Trims [value] and cuts it to [max] characters (the server counts
  /// characters, not bytes).
  static String clamp(String value, int max, {required String fallback}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return fallback;
    return String.fromCharCodes(trimmed.runes.take(max));
  }

  static String? clampOrNull(String? value, int max) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return String.fromCharCodes(trimmed.runes.take(max));
  }
}
