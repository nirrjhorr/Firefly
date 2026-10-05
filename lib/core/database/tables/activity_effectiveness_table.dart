import 'package:drift/drift.dart';

class ActivityEffectivenessLogs extends Table {
  TextColumn get id => text()();
  TextColumn get activityId => text()();
  TextColumn get stateAtStart => text()();
  IntColumn get rating => integer().check(rating.isBetweenValues(-2, 2))();
  IntColumn get durationSeconds => integer()();
  IntColumn get timestampUnix => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Index> get customIndices => [
        Index(
          'idx_activity_effectiveness_activity',
          'CREATE INDEX IF NOT EXISTS idx_activity_effectiveness_activity ON activity_effectiveness_logs (activity_id)',
        ),
        Index(
          'idx_activity_effectiveness_state',
          'CREATE INDEX IF NOT EXISTS idx_activity_effectiveness_state ON activity_effectiveness_logs (state_at_start)',
        ),
      ];
}
