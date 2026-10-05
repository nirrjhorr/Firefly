import 'package:drift/drift.dart';

class Activities extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get category => text()(); // Mapped to ActivityCategory enum name
  IntColumn get energyRequired => integer().check(energyRequired.isBetweenValues(1, 5))();
  TextColumn get targetStatesJson => text()(); // Serialized List<String> of target states
  TextColumn get guidanceType => text()(); // Mapped to GuidanceType enum name
  TextColumn get evidenceLevel => text()(); // Mapped to EvidenceLevel enum name
  TextColumn get route => text()();
  IntColumn get durationMinutes => integer().nullable()();
  TextColumn get instructionsJson => text().nullable()(); // Serialized List<String>
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get createdAtUnix => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Index> get customIndices => [
        Index(
          'idx_activities_category',
          'CREATE INDEX IF NOT EXISTS idx_activities_category ON activities (category)',
        ),
        Index(
          'idx_activities_energy',
          'CREATE INDEX IF NOT EXISTS idx_activities_energy ON activities (energy_required)',
        ),
      ];
}
