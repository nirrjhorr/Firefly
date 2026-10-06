import 'package:drift/drift.dart';

/// Drift table representing Hope Box vault items.
/// Double encryption on content_encrypted with SQLCipher underlying encryption.
class HopeBoxItems extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // 'reason' | 'text' | 'photo' | 'voice' | 'audio'
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get contentEncrypted => text().withDefault(const Constant(''))();
  TextColumn get filePath => text().nullable()();
  TextColumn get caption => text().nullable()();
  TextColumn get category => text().withDefault(const Constant('General'))();
  IntColumn get createdAtUnix => integer()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Index> get customIndices => [
        Index(
          'idx_hope_box_type',
          'CREATE INDEX IF NOT EXISTS idx_hope_box_type ON hope_box_items (type)',
        ),
        Index(
          'idx_hope_box_pinned',
          'CREATE INDEX IF NOT EXISTS idx_hope_box_pinned ON hope_box_items (is_pinned)',
        ),
      ];
}
