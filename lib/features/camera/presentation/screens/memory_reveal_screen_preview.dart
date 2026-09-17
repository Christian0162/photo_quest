import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/preview/app_widget_preview.dart';
import '../view_models/memory_reveal_view_model.dart';
import 'memory_reveal_screen.dart';

const _sessionId = 'session-1';

@Preview(name: 'Memory Reveal', group: 'screens', size: Size(390, 844))
Widget memoryRevealScreenPreview() {
  return ProviderScope(
    overrides: [
      memoryRevealProvider(_sessionId).overrideWith(
        (ref) => const MemoryRevealResult(
          memoryId: 'memory-1',
          // No file exists at this path in the preview environment; the
          // strip image area will render empty rather than crash.
          stripPath: 'preview-photo-strip.jpg',
        ),
      ),
    ],
    child: const AppWidgetPreview(
      child: MemoryRevealScreen(sessionId: _sessionId),
    ),
  );
}
