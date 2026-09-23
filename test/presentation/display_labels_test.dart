import 'package:flutter_test/flutter_test.dart';
import 'package:photoquest/core/presentation/types/display_labels.dart';

void main() {
  test('stored values are shown as human words', () {
    expect(shotTypeLabel('close_up'), 'Close-up');
    expect(personTypeLabel('family'), 'Family');
    expect(personTypeLabel('self'), 'You');
    expect(questTypeLabel('pair'), 'The two of us');
  });

  test('the device owner cannot be picked when adding a person', () {
    expect(personTypes.map((t) => t.$1), isNot(contains('self')));
  });
}
