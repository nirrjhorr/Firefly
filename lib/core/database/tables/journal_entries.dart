import 'package:drift/drift.dart';
import 'mood_check_ins.dart';

class JournalEntries extends Table {
  TextColumn get id => text()();
  TextColumn get checkInId => text().nullable().references(
        MoodCheckIns,
        #id,
        onDelete: KeyAction.setNull,
      )();
  TextColumn get title => text().withDefault(const Constant(''))();
  // content_encrypted: application-layer AES-GCM encrypted payload
  // Double encryption layer on top of SQLCipher for defense-in-depth
  TextColumn get contentEncrypted => text()();
  TextColumn get contentType => text().withDefault(const Constant('text'))(); // 'text' | 'voice'
  IntColumn get ttlDeleteAtUnix => integer().nullable()(); // null = keep forever
  BoolColumn get isAutoDeleteEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get wordCount => integer().withDefault(const Constant(0))();
  IntColumn get createdAtUnix => integer()();
  IntColumn get updatedAtUnix => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
