import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widget/template/app_widget_preview.dart';
import '../../../domain/memories/entities/memory.dart';
import '../../view_model/memories/memory_list_view_model.dart';
import 'memories_screen.dart';

@Preview(
  name: 'Memories — with memories',
  group: 'screens',
  size: Size(390, 844),
)
Widget memoriesScreenPreview() {
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
    Memory(
      id: 'memory-3',
      questSessionId: 'session-3',
      title: 'Best Friends',
      capturedAt: now.subtract(const Duration(days: 45)),
      createdAt: now,
      updatedAt: now,
    ),
  ];

  return ProviderScope(
    overrides: [memoryListProvider.overrideWith((ref) => memories)],
    child: const AppWidgetPreview(child: MemoriesScreen()),
  );
}

@Preview(name: 'Memories — empty', group: 'screens', size: Size(390, 844))
Widget memoriesScreenEmptyPreview() {
  return ProviderScope(
    overrides: [memoryListProvider.overrideWith((ref) => const [])],
    child: const AppWidgetPreview(child: MemoriesScreen()),
  );
}
