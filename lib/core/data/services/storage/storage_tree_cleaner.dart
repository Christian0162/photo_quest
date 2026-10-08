/// One item Supabase Storage lists inside a folder.
class StorageEntry {
  const StorageEntry(this.name, {required this.isFolder});

  final String name;
  final bool isFolder;
}

/// Lists one page of [folder]; an empty or short page means the end.
typedef ListStorageFolder = Future<List<StorageEntry>> Function(
  String folder,
  int offset,
);

/// Deletes the given full file paths.
typedef RemoveStorageFiles = Future<void> Function(List<String> paths);

/// Deletes everything under a folder in Supabase Storage.
///
/// Storage has no "delete folder": folders only exist as part of file paths,
/// so every file under the root, at any depth, has to be listed and removed.
/// This walks the whole tree first (so paging isn't thrown off by deletions),
/// then removes the files in batches. If a list or remove call throws, the
/// walk stops and the error is passed on, so a retry can pick up what's left.
class StorageTreeCleaner {
  const StorageTreeCleaner({this.pageSize = 100});

  /// How many entries to list, and how many files to remove, per call.
  final int pageSize;

  /// Returns how many files were removed.
  Future<int> deleteTree(
    String root, {
    required ListStorageFolder list,
    required RemoveStorageFiles remove,
  }) async {
    final files = <String>[];
    final folders = <String>[root];

    while (folders.isNotEmpty) {
      final folder = folders.removeLast();
      var offset = 0;
      while (true) {
        final page = await list(folder, offset);
        for (final entry in page) {
          final path = '$folder/${entry.name}';
          entry.isFolder ? folders.add(path) : files.add(path);
        }
        if (page.length < pageSize) break;
        offset += page.length;
      }
    }

    for (var start = 0; start < files.length; start += pageSize) {
      final end = start + pageSize < files.length
          ? start + pageSize
          : files.length;
      await remove(files.sublist(start, end));
    }
    return files.length;
  }
}
