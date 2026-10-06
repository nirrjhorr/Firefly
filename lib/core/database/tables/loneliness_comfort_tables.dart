import 'package:drift/drift.dart';

/// Drift table representing user custom reach-out contacts.
class ReachOutContactsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get relationship => text().withDefault(const Constant(''))();
  BoolColumn get isSafetyPlanContact => boolean().withDefault(const Constant(false))();
  IntColumn get displayOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAtUnix => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Drift table representing "Guess vs. Reality" cognitive reframing experiments.
class SocialPredictionExperimentsTable extends Table {
  TextColumn get id => text()();
  TextColumn get contactId => text()();
  TextColumn get contactName => text()();
  TextColumn get predictedOutcome => text()(); // 'warm' | 'neutral' | 'wontRespond'
  IntColumn get predictedAtUnix => integer()();
  TextColumn get actualOutcome => text().nullable()(); // null or outcome
  IntColumn get completedAtUnix => integer().nullable()();
  TextColumn get messageSnippet => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Index> get customIndices => [
        Index(
          'idx_experiments_contact',
          'CREATE INDEX IF NOT EXISTS idx_experiments_contact ON social_prediction_experiments_table (contact_id)',
        ),
      ];
}
