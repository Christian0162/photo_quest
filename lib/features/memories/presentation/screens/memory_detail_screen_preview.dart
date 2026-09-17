import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/preview/app_widget_preview.dart';
import '../../../people/domain/entities/person.dart';
import '../../domain/entities/memory.dart';
import '../view_models/memory_detail_view_model.dart';
import 'memory_detail_screen.dart';

@Preview(name: 'Memory Detail', group: 'screens', size: Size(390, 844))
Widget memoryDetailScreenPreview() {
  final now = DateTime.now();
  const memoryId = 'memory-1';
  final memory = Memory(
    id: memoryId,
    questSessionId: 'session-1',
    title: 'Us — Anniversary',
    note: 'Rainy day, but the best kind of memory.',
    capturedAt: now.subtract(const Duration(days: 3)),
    createdAt: now,
    updatedAt: now,
  );
  final people = [
    Person(
      id: 'p1',
      name: 'Christian',
      type: 'self',
      createdAt: now,
      updatedAt: now,
    ),
    Person(
      id: 'p2',
      name: 'Jamie',
      type: 'partner',
      createdAt: now,
      updatedAt: now,
    ),
  ];

  return ProviderScope(
    overrides: [
      memoryDetailProvider(memoryId).overrideWith(
        (ref) => MemoryDetail(
          memory: memory,
          photos: const [],
          people: people,
          questId: 'quest-1',
        ),
      ),
    ],
    child: const AppWidgetPreview(
      child: MemoryDetailScreen(memoryId: memoryId),
    ),
  );
}
