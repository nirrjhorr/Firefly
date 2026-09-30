import 'package:drift/drift.dart';

class MoodCheckIns extends Table {
  TextColumn get id => text()();
  TextColumn get moodCategory => text()(); // 'anxious' | 'low' | 'overwhelmed' | 'lonely' | 'calm'
  IntColumn get energyLevel => integer().check(energyLevel.isBetweenValues(1, 5))();
  IntColumn get anxietyLevel => integer().check(anxietyLevel.isBetweenValues(1, 5))();
  IntColumn get lonelinessLevel => integer().check(lonelinessLevel.isBetweenValues(1, 5))();
  TextColumn get affectLabels => text().nullable()(); // JSON array of selected emotion words
  TextColumn get suggestedAction => text().nullable()(); // Serialized ActionSuggestion JSON
  IntColumn get createdAtUnix => integer()();
  IntColumn get updatedAtUnix => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [];

  @override
  List<Index> get customIndices => [
        Index(
          'mood_check_ins_created_at',
          'CREATE INDEX IF NOT EXISTS mood_check_ins_created_at ON mood_check_ins (created_at_unix DESC)',
        ),
      ];
}
