import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widget/template/app_widget_preview.dart';
import '../../../domain/people/entities/person.dart';
import '../../../domain/quests/entities/quest.dart';
import '../../../domain/quests/entities/quest_shot.dart';
import '../../view_model/camera/capture_view_model.dart';
import 'capture_screen.dart';

const _sessionId = 'session-1';

Quest _fakeQuest(DateTime now) => Quest(
  id: 'quest-1',
  title: 'Anniversary',
  category: 'For Us',
  createdAt: now,
  updatedAt: now,
);

List<Person> _fakeParticipants(DateTime now) => [
  Person(
    id: 'p1',
    name: 'Christian',
    type: 'self',
    createdAt: now,
    updatedAt: now,
  ),
  Person(
    id: 'p2',
    name: 'Sam',
    type: 'partner',
    createdAt: now,
    updatedAt: now,
  ),
];

List<QuestShot> _fakeShots() => const [
  QuestShot(
    id: 'shot-1',
    questId: 'quest-1',
    position: 0,
    instruction: 'Stand together and smile',
    shotType: 'group',
  ),
  QuestShot(
    id: 'shot-2',
    questId: 'quest-1',
    position: 1,
    instruction: 'A close-up of your hands',
    shotType: 'close_up',
  ),
];

class _FakeCaptureViewModel extends CaptureViewModel {
  _FakeCaptureViewModel(this._phase);

  final CapturePhase _phase;

  @override
  Future<CaptureState> build(String sessionId) async {
    final now = DateTime.now();
    return CaptureState(
      quest: _fakeQuest(now),
      shots: _fakeShots(),
      memoryId: 'memory-1',
      participants: _fakeParticipants(now),
      currentIndex: 0,
      phase: _phase,
      countdownValue: 2,
    );
  }
}

@Preview(name: 'Capture — instruction', group: 'screens', size: Size(390, 844))
Widget captureScreenInstructionPreview() {
  return ProviderScope(
    overrides: [
      captureViewModelProvider(_sessionId)
          .overrideWith(() => _FakeCaptureViewModel(CapturePhase.instruction)),
    ],
    child: const AppWidgetPreview(child: CaptureScreen(sessionId: _sessionId)),
  );
}

@Preview(name: 'Capture — countdown', group: 'screens', size: Size(390, 844))
Widget captureScreenCountdownPreview() {
  return ProviderScope(
    overrides: [
      captureViewModelProvider(_sessionId)
          .overrideWith(() => _FakeCaptureViewModel(CapturePhase.countdown)),
    ],
    child: const AppWidgetPreview(child: CaptureScreen(sessionId: _sessionId)),
  );
}

@Preview(name: 'Capture — captured', group: 'screens', size: Size(390, 844))
Widget captureScreenCapturedPreview() {
  return ProviderScope(
    overrides: [
      captureViewModelProvider(_sessionId)
          .overrideWith(() => _FakeCaptureViewModel(CapturePhase.captured)),
    ],
    child: const AppWidgetPreview(child: CaptureScreen(sessionId: _sessionId)),
  );
}
