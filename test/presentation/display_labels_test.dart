import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/presentation/types/display_labels.dart';

void main() {
  test('stored values are shown as human words', () {
    expect(shotTypeLabel('close_up'), 'Close-up');
    expect(personTypeLabel('family'), 'Family');
    expect(personTypeLabel('self'), 'You');
    expect(questTypeLabel('pair'), 'The two of us');
  });

  test('a memory card names what kind of day it was', () {
    String occasion(String title, [String? category]) =>
        memoryOccasion(title, category).$1;
    expect(occasion('Our Anniversary', 'For Us'), 'Anniversary');
    expect(occasion('Mia turns 30', 'Birthday'), 'Birthday');
    expect(occasion('Family Christmas', 'For Family'), 'Holiday');
    // The title wins over the broader category.
    expect(occasion('Date Night', 'For Us'), 'Date night');
    expect(occasion('Sunday lunch', 'For Family'), 'Family day');
    expect(occasion('Random Day', 'For Life'), 'Good day');
    expect(occasion('Something new'), 'Good day');
  });

  test('the device owner cannot be picked when adding a person', () {
    expect(personTypes.map((t) => t.$1), isNot(contains('self')));
  });

  test('every built-in category has an example photo', () {
    String? photo(String c) => questCategoryExample(c)?.asset.split('/').last;
    expect(photo('For Us'), 'for_us.jpg');
    expect(photo('For Family'), 'for_family.jpg');
    expect(photo('For Friends'), 'for_friends.jpg');
    expect(photo('For Me'), 'for_me.jpg');
    expect(photo('For Life'), 'for_life.jpg');
    // Custom categories from Create Quest map by meaning, not by accident.
    expect(photo('Memory'), 'for_life.jpg');
    expect(photo('Birthday'), 'for_friends.jpg');
    expect(photo('Something new'), isNull);
  });

  test('every example photo is bundled', () {
    for (final c in [
      'For Us',
      'For Family',
      'For Friends',
      'For Me',
      'For Life',
    ]) {
      final asset = questCategoryExample(c)!.asset;
      expect(File(asset).existsSync(), isTrue, reason: asset);
      expect(File('pubspec.yaml').readAsStringSync(), contains(asset));
    }
  });
}
