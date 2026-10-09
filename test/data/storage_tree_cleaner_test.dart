import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/data/services/storage/storage_tree_cleaner.dart';

/// An in-memory Storage bucket: a set of full file paths, listed one folder
/// level at a time and in pages, like the real thing.
class _FakeBucket {
  _FakeBucket(Iterable<String> paths) : files = {...paths};

  final Set<String> files;
  final removeBatches = <List<String>>[];

  Future<List<StorageEntry>> list(
    String folder,
    int offset,
    int pageSize,
  ) async {
    final prefix = '$folder/';
    final children = <String, bool>{};
    for (final path in files.where((p) => p.startsWith(prefix))) {
      final rest = path.substring(prefix.length);
      final slash = rest.indexOf('/');
      final name = slash == -1 ? rest : rest.substring(0, slash);
      children[name] = slash != -1;
    }
    final names = children.keys.toList()..sort();
    return [
      for (final name in names.skip(offset).take(pageSize))
        StorageEntry(name, isFolder: children[name]!),
    ];
  }

  Future<void> remove(List<String> paths) async {
    removeBatches.add(paths);
    files.removeAll(paths);
  }
}

void main() {
  const me = 'user-1';

  test('removes every file under the root, at any depth', () async {
    final bucket = _FakeBucket([
      '$me/memory-a/1.jpg',
      '$me/memory-a/2.jpg',
      '$me/memory-b/clip.mp4',
      '$me/memory-b/deeper/3.jpg',
      '$me/top.jpg',
    ]);
    const cleaner = StorageTreeCleaner(pageSize: 100);

    final removed = await cleaner.deleteTree(
      me,
      list: (folder, offset) => bucket.list(folder, offset, 100),
      remove: bucket.remove,
    );

    expect(removed, 5);
    expect(bucket.files, isEmpty);
  });

  test('never touches another person\'s files', () async {
    final bucket = _FakeBucket([
      '$me/memory-a/1.jpg',
      'someone-else/memory-z/9.jpg',
      '$me-2/memory-a/1.jpg',
    ]);
    const cleaner = StorageTreeCleaner();

    await cleaner.deleteTree(
      me,
      list: (folder, offset) => bucket.list(folder, offset, 100),
      remove: bucket.remove,
    );

    expect(bucket.files, {
      'someone-else/memory-z/9.jpg',
      '$me-2/memory-a/1.jpg',
    });
  });

  test(
    'pages through folders bigger than one page and removes in batches',
    () async {
      final bucket = _FakeBucket([
        for (var i = 0; i < 25; i++)
          '$me/memory-a/photo-${i.toString().padLeft(2, '0')}.jpg',
      ]);
      const cleaner = StorageTreeCleaner(pageSize: 10);

      final removed = await cleaner.deleteTree(
        me,
        list: (folder, offset) => bucket.list(folder, offset, 10),
        remove: bucket.remove,
      );

      expect(removed, 25);
      expect(bucket.files, isEmpty);
      expect(bucket.removeBatches.map((b) => b.length), [10, 10, 5]);
    },
  );

  test('an empty folder is fine', () async {
    final bucket = _FakeBucket([]);
    final removed = await const StorageTreeCleaner().deleteTree(
      me,
      list: (folder, offset) => bucket.list(folder, offset, 100),
      remove: bucket.remove,
    );

    expect(removed, 0);
    expect(bucket.removeBatches, isEmpty);
  });

  test(
    'a failing remove stops and reports, leaving a retry possible',
    () async {
      final bucket = _FakeBucket([
        for (var i = 0; i < 25; i++)
          '$me/m/photo-${i.toString().padLeft(2, '0')}.jpg',
      ]);
      var calls = 0;

      await expectLater(
        const StorageTreeCleaner(pageSize: 10).deleteTree(
          me,
          list: (folder, offset) => bucket.list(folder, offset, 10),
          remove: (paths) async {
            calls++;
            if (calls == 2) throw StateError('network dropped');
            await bucket.remove(paths);
          },
        ),
        throwsStateError,
      );
      expect(
        bucket.files.length,
        15,
        reason: 'only the first batch was removed',
      );

      // Retrying finishes the job.
      await const StorageTreeCleaner(pageSize: 10).deleteTree(
        me,
        list: (folder, offset) => bucket.list(folder, offset, 10),
        remove: bucket.remove,
      );
      expect(bucket.files, isEmpty);
    },
  );

  test('a failing list stops before anything is removed', () async {
    final bucket = _FakeBucket(['$me/m/1.jpg']);

    await expectLater(
      const StorageTreeCleaner().deleteTree(
        me,
        list: (folder, offset) async => throw StateError('offline'),
        remove: bucket.remove,
      ),
      throwsStateError,
    );
    expect(bucket.files, {'$me/m/1.jpg'});
  });
}
