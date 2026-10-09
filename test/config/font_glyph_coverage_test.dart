import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The bundled Outfit/Inter fonts are the Latin subset. A character outside
/// it (e.g. "→") renders as a missing-glyph box on device, so UI copy must
/// stay inside it — use an Icon for arrows and symbols instead. See
/// CLAUDE.md §29.
void main() {
  bool covered(int code) =>
      (code >= 0x20 && code < 0x7f) ||
      (code >= 0xa0 && code <= 0xff) ||
      const {
        0x2013, 0x2014, // – —
        0x2018, 0x2019, 0x201c, 0x201d, // ‘ ’ “ ”
        0x2022, 0x2026, // • …
        0x20ac, // €
      }.contains(code);

  test('UI copy only uses characters the bundled fonts can draw', () {
    final problems = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'));

    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trimLeft();
        if (line.startsWith('//')) continue;
        final bad = line.runes.where((c) => c > 0x7f && !covered(c));
        if (bad.isNotEmpty) {
          problems.add(
            '${file.path}:${i + 1} ${String.fromCharCodes(bad.toSet())}',
          );
        }
      }
    }

    expect(problems, isEmpty, reason: 'Use an Icon instead of these glyphs.');
  });
}
