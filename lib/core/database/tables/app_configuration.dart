import 'package:drift/drift.dart';

class AppConfiguration extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  TextColumn get valueType => text()(); // 'bool' | 'int' | 'double' | 'string'
  IntColumn get updatedAtUnix => integer()();

  @override
  Set<Column> get primaryKey => {key};
}
