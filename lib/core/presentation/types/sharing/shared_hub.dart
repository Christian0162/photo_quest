import '../../../domain/sharing/entities/shared_memory.dart';
import '../../../domain/sharing/entities/shared_quest.dart';

/// Everything shared with me, in one place: invitations to answer, quests I'm
/// taking part in, and memories friends gave me a code for.
class SharedHub {
  const SharedHub({
    required this.invitations,
    required this.quests,
    required this.memories,
  });

  final List<SharedQuestSummary> invitations;
  final List<SharedQuestSummary> quests;
  final List<SharedMemorySummary> memories;

  bool get isEmpty => invitations.isEmpty && quests.isEmpty && memories.isEmpty;
}
