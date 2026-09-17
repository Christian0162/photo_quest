import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Owns all photo filesystem behavior. Repositories never touch paths
/// directly. See CLAUDE.md §6.
class PhotoStorageService {
  static const _originalsDir = 'photos/originals';
  static const _thumbnailsDir = 'photos/thumbnails';
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

  Future<String> saveThumbnail(String photoId, List<int> bytes) async {
    final dir = await _ensureDir(_thumbnailsDir);
    final file = File(p.join(dir.path, '$photoId.jpg'));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<String> savePhotoStrip(String memoryId, List<int> bytes) async {
    final dir = await _ensureDir(_stripsDir);
    final file = File(p.join(dir.path, '$memoryId.jpg'));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  Future<void> deletePhoto(String photoId) async {
    final originals = await _ensureDir(_originalsDir);
    final thumbnails = await _ensureDir(_thumbnailsDir);
    await _deleteIfExists(File(p.join(originals.path, '$photoId.jpg')));
    await _deleteIfExists(File(p.join(thumbnails.path, '$photoId.jpg')));
  }

  Future<void> deleteMemoryFiles(String memoryId, List<String> photoIds) async {
    for (final id in photoIds) {
      await deletePhoto(id);
    }
    final strips = await _ensureDir(_stripsDir);
    await _deleteIfExists(File(p.join(strips.path, '$memoryId.jpg')));
  }

  Future<String> getPhotoPath(String photoId, {required bool thumbnail}) async {
    final dir = await _ensureDir(thumbnail ? _thumbnailsDir : _originalsDir);
    return p.join(dir.path, '$photoId.jpg');
  }

  Future<void> _deleteIfExists(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }
}
