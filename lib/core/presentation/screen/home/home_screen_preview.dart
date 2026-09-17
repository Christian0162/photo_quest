import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widget/template/app_widget_preview.dart';
import '../../../domain/memories/entities/memory.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import 'home_screen.dart';

@Preview(name: 'Home — with memories', group: 'screens', size: Size(390, 844))
Widget homeScreenPreview() {
  final now = DateTime.now();
  final memories = [
    Memory(
      id: 'memory-1',
      questSessionId: 'session-1',
      title: 'Us — Anniversary',
      capturedAt: now.subtract(const Duration(days: 3)),
      createdAt: now,
      updatedAt: now,
    ),
    Memory(
      id: 'memory-2',
      questSessionId: 'session-2',
      title: 'Family Day',
      capturedAt: now.subtract(const Duration(days: 20)),
      createdAt: now,
      updatedAt: now,
    ),
  ];

  return ProviderScope(
    overrides: [memoryListProvider.overrideWith((ref) => memories)],
    child: const AppWidgetPreview(child: HomeScreen()),
  );
}

@Preview(name: 'Home — empty', group: 'screens', size: Size(390, 844))
Widget homeScreenEmptyPreview() {
  return ProviderScope(
    overrides: [memoryListProvider.overrideWith((ref) => const [])],
    child: const AppWidgetPreview(child: HomeScreen()),
  );
}
