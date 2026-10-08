import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/config/constant/app_avatars.dart';

/// Every avatar the picker offers must have its picture bundled, and every
/// bundled picture must be one the picker offers.
void main() {
  test('each avatar in the picker has its image file', () {
    for (final id in AppAvatars.ids) {
      expect(
        File(AppAvatars.assetFor(id)!).existsSync(),
        isTrue,
        reason: '$id is missing',
      );
    }
  });

  test('no bundled avatar is left out of the picker', () {
    final files = Directory('assets/images/avatars')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.png'))
        .map(
          (f) => f.path
              .replaceAll(r'\', '/')
              .replaceFirst('assets/images/avatars/', '')
              .replaceFirst('.png', ''),
        )
        .toSet();

    expect(files, AppAvatars.ids.toSet());
  });

  test('ids are unique, and unknown ids have no image', () {
    expect(AppAvatars.ids.toSet(), hasLength(AppAvatars.ids.length));
    expect(AppAvatars.assetFor('avatar_03'), isNull);
    expect(AppAvatars.assetFor(null), isNull);
  });
}
