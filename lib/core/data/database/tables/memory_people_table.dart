import 'package:drift/drift.dart';

import 'memories_table.dart';
import 'people_table.dart';

/// Join table allowing one Memory to include multiple People.
class MemoryPeople extends Table {
  TextColumn get memoryId => text().references(Memories, #id)();
  TextColumn get personId => text().references(People, #id)();

  @override
  Set<Column> get primaryKey => {memoryId, personId};
}
