import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Owns all photo filesystem behavior. Repositories never touch paths
/// directly. See CLAUDE.md §6.
class PhotoStorageService {
  static const _originalsDir = 'photos/originals';
  static const _thumbnailsDir = 'photos/thumbnails';
  static const _motionDir = 'photos/motion';
  static const _videosDir = 'photos/videos';
  static const _stripsDir = 'photos/strips';

  Future<Directory> _ensureDir(String relativePath) async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, relativePath));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<String> saveOriginal(String photoId, List<int> bytes) async {
    final dir = await _ensureDir(_originalsDir);
    final file = File(p.join(dir.path, '$photoId.jpg'));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Saves a still thumbnail — or, for animations and clips, the poster
  /// frame.
  Future<String> saveThumbnail(String photoId, List<int> bytes) async {
    final dir = await _ensureDir(_thumbnailsDir);
    final file = File(p.join(dir.path, '$photoId.jpg'));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  /// Saves a GIF or boomerang.
  Future<String> saveAnimation(String photoId, List<int> gifBytes) async {
    final dir = await _ensureDir(_motionDir);
    final file = File(p.join(dir.path, '$photoId.gif'));
    await file.writeAsBytes(gifBytes);
    return file.path;
  }

  /// Moves a just-recorded clip from the camera's temporary [sourcePath]
  /// into app storage.
  Future<String> saveVideo(String photoId, String sourcePath) async {
    final dir = await _ensureDir(_videosDir);
    final target = p.join(dir.path, '$photoId.mp4');
    final source = File(sourcePath);
    await source.copy(target);
    await _deleteIfExists(source);
    return target;
  }

  /// Deletes a temporary camera file that won't be kept (e.g. a clip
  /// that was too short).
  Future<void> discardTemporary(String path) => _deleteIfExists(File(path));

  /// Saves the printed keepsake (strip, grid or polaroid) for a memory.
  /// Each save gets a new file name, so screens never show a stale cached
  /// image of an earlier design; older versions are removed.
  Future<String> savePhotoStrip(String memoryId, List<int> bytes) async {
    final dir = await _ensureDir(_stripsDir);
    final previous = await _stripsFor(memoryId);
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final file = File(p.join(dir.path, '$memoryId-$stamp.jpg'));
    await file.writeAsBytes(bytes);
    for (final old in previous) {
      await _deleteIfExists(old);
    }
    return file.path;
  }

  /// The latest keepsake for [memoryId], or null if none exists yet.
  Future<String?> findPhotoStrip(String memoryId) async {
    final strips = await _stripsFor(memoryId);
    if (strips.isEmpty) return null;
    final dated = [for (final file in strips) (file, await file.lastModified())]
      ..sort((a, b) => b.$2.compareTo(a.$2));
    return dated.first.$1.path;
  }

  Future<void> deletePhoto(String photoId) async {
    for (final (dir, extension) in [
      (_originalsDir, 'jpg'),
      (_thumbnailsDir, 'jpg'),
      (_motionDir, 'gif'),
      (_videosDir, 'mp4'),
    ]) {
      final folder = await _ensureDir(dir);
      await _deleteIfExists(File(p.join(folder.path, '$photoId.$extension')));
    }
  }

  Future<void> deleteMemoryFiles(String memoryId, List<String> photoIds) async {
    for (final id in photoIds) {
      await deletePhoto(id);
    }
    for (final strip in await _stripsFor(memoryId)) {
      await _deleteIfExists(strip);
    }
  }

  Future<String> getPhotoPath(String photoId, {required bool thumbnail}) async {
    final dir = await _ensureDir(thumbnail ? _thumbnailsDir : _originalsDir);
    return p.join(dir.path, '$photoId.jpg');
  }

  /// Every keepsake file for [memoryId]: `<id>.jpg` from before versioned
  /// names, and `<id>-<stamp>.jpg`.
  Future<List<File>> _stripsFor(String memoryId) async {
    final dir = await _ensureDir(_stripsDir);
    return [
      await for (final entity in dir.list())
        if (entity is File &&
            (p.basename(entity.path) == '$memoryId.jpg' ||
                p.basename(entity.path).startsWith('$memoryId-')))
          entity,
    ];
  }

  Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
