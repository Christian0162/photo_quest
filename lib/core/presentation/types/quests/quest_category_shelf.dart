import 'quest_list_item.dart';

/// One shelf on the Quest picker: a category ("For Us", "For Family" …) and
/// its Quests, in the order they were first seen. See CLAUDE.md §33.
class QuestCategoryShelf {
  const QuestCategoryShelf({required this.category, required this.quests});

  final String category;
  final List<QuestListItem> quests;
}
