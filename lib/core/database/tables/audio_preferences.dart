import 'package:drift/drift.dart';

class AudioPreferences extends Table {
  TextColumn get id => text()();
  TextColumn get soundscapeId => text()(); // maps to assets/audio/<id>.mp3
  RealColumn get volume => real().withDefault(const Constant(0.7))();
  BoolColumn get isGaplessLoop => boolean().withDefault(const Constant(true))();
  IntColumn get lastUsedAtUnix => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
