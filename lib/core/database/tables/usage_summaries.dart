import 'package:drift/drift.dart';

class UsageSummaries extends Table {
  TextColumn get id => text()();
  TextColumn get featureKey => text()(); // 'check_in' | 'breathing' | 'journal' | 'tiny_steps'
  IntColumn get sessionCount => integer().withDefault(const Constant(0))();
  IntColumn get totalDurationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get lastUsedAtUnix => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
