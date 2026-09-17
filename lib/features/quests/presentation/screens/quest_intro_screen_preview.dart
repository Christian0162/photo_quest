import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/preview/app_widget_preview.dart';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_shot.dart';
import '../view_models/quest_detail_view_model.dart';
import 'quest_intro_screen.dart';

@Preview(name: 'Quest Intro', group: 'screens', size: Size(390, 844))
Widget questIntroScreenPreview() {
  final now = DateTime.now();
  const questId = 'quest-1';
  final quest = Quest(
    id: questId,
    title: 'Anniversary',
    description: 'Celebrate another year together, one shot at a time.',
    category: 'For Us',
    createdAt: now,
    updatedAt: now,
  );
  final shots = [
    QuestShot(
      id: 'shot-1',
      questId: questId,
      position: 0,
      instruction: 'Stand together and smile',
      shotType: 'group',
    ),
    QuestShot(
      id: 'shot-2',
      questId: questId,
      position: 1,
      instruction: 'A close-up of your hands',
      shotType: 'close_up',
    ),
  ];

  return ProviderScope(
    overrides: [
      questDetailProvider(questId)
          .overrideWith((ref) => QuestDetail(quest: quest, shots: shots)),
    ],
    child: const AppWidgetPreview(child: QuestIntroScreen(questId: questId)),
  );
}
