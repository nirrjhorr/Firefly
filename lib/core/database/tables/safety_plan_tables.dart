import 'package:drift/drift.dart';

class SafetyPlans extends Table {
  TextColumn get id => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAtUnix => integer()();
  IntColumn get lastReviewedAtUnix => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SafetyPlanContacts extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text().references(
        SafetyPlans,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get name => text()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get relationship => text()();
  IntColumn get displayOrder => integer()();
  BoolColumn get isProfessional => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class SafetyPlanWarnings extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text().references(
        SafetyPlans,
        #id,
        onDelete: KeyAction.cascade,
      )();
  TextColumn get warningText => text()();
  IntColumn get displayOrder => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class SafetyPlanSteps extends Table {
  TextColumn get id => text()();
  TextColumn get planId => text().references(
        SafetyPlans,
        #id,
        onDelete: KeyAction.cascade,
      )();
  IntColumn get stepNumber => integer()();
  TextColumn get stepTitle => text()();
  TextColumn get stepContent => text()();
  // 'internal_coping' | 'distraction_contact' | 'support_contact' |
  // 'professional_contact' | 'environment_safety' | 'reasons_to_live'
  TextColumn get stepType => text()();

  @override
  Set<Column> get primaryKey => {id};
}
