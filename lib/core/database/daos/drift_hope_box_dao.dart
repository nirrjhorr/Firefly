import 'package:drift/drift.dart';

import '../../../features/hope_box/domain/models/hope_box_item.dart';
import '../app_database.dart';
import 'hope_box_dao.dart';

/// Drift SQL database implementation of [HopeBoxDao] targeting the encrypted SQLCipher DB.
class DriftHopeBoxDao implements HopeBoxDao {
  DriftHopeBoxDao(this._db);

  final AppDatabase _db;

  @override
  Future<void> insertItem(HopeBoxItem item) async {
    await _db.customInsert(
      'INSERT OR REPLACE INTO hope_box_items '
      '(id, type, title, content_encrypted, file_path, caption, category, created_at_unix, is_pinned) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(item.id),
        Variable.withString(item.type.name),
        Variable.withString(item.title),
        Variable.withString(item.contentEncrypted),
        Variable.withString(item.filePath ?? ''),
        Variable.withString(item.caption ?? ''),
        Variable.withString(item.category),
        Variable.withInt(item.createdAtUnix),
        Variable.withBool(item.isPinned),
      ],
    );
  }

  @override
  Future<void> updateItem(HopeBoxItem item) => insertItem(item);

  @override
  Future<HopeBoxItem?> getItemById(String id) async {
    final rows = await _db.customSelect(
      'SELECT * FROM hope_box_items WHERE id = ? LIMIT 1',
      variables: [Variable<String>(id)],
    ).get();

    if (rows.isEmpty) return null;
    return _mapRowToItem(rows.first.data);
  }

  @override
  Future<List<HopeBoxItem>> getAllItems() async {
    final rows = await _db.customSelect(
      'SELECT * FROM hope_box_items ORDER BY is_pinned DESC, created_at_unix DESC',
    ).get();

    return rows.map((r) => _mapRowToItem(r.data)).toList();
  }

  @override
  Stream<List<HopeBoxItem>> watchAllItems() {
    return _db.customSelect(
      'SELECT * FROM hope_box_items ORDER BY is_pinned DESC, created_at_unix DESC',
    ).watch().map((rows) => rows.map((r) => _mapRowToItem(r.data)).toList());
  }

  @override
  Future<void> deleteItem(String id) async {
    await _db.customUpdate(
      'DELETE FROM hope_box_items WHERE id = ?',
      variables: [Variable<String>(id)],
    );
  }

  @override
  Future<void> togglePin(String id) async {
    final existing = await getItemById(id);
    if (existing != null) {
      await insertItem(existing.copyWith(isPinned: !existing.isPinned));
    }
  }

  @override
  Future<void> clearAll() async {
    await _db.customUpdate('DELETE FROM hope_box_items');
  }

  HopeBoxItem _mapRowToItem(Map<String, dynamic> data) {
    final filePathStr = data['file_path'] as String?;
    final captionStr = data['caption'] as String?;

    return HopeBoxItem(
      id: data['id'] as String,
      type: HopeBoxItemType.values.byName(data['type'] as String),
      title: (data['title'] as String?) ?? '',
      contentEncrypted: (data['content_encrypted'] as String?) ?? '',
      filePath: (filePathStr != null && filePathStr.isNotEmpty) ? filePathStr : null,
      caption: (captionStr != null && captionStr.isNotEmpty) ? captionStr : null,
      category: (data['category'] as String?) ?? 'General',
      createdAtUnix: data['created_at_unix'] as int,
      isPinned: data['is_pinned'] == 1 || data['is_pinned'] == true,
    );
  }
}
