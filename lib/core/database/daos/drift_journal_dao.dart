import 'dart:async';
import 'package:drift/drift.dart';

import '../../../features/journaling/domain/models/journal_entry.dart';
import '../app_database.dart' hide JournalEntry;
import 'journal_dao.dart';

/// Drift SQL database implementation of [JournalDao].
class DriftJournalDao implements JournalDao {
  DriftJournalDao(this._db);

  final AppDatabase _db;

  @override
  Future<void> insertEntry(JournalEntry entry) async {
    await _db.customInsert(
      'INSERT OR REPLACE INTO journal_entries '
      '(id, check_in_id, title, content_encrypted, content_type, ttl_delete_at_unix, is_auto_delete_enabled, word_count, created_at_unix, updated_at_unix) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(entry.id),
        Variable.withString(entry.checkInId ?? ''),
        Variable.withString(entry.title),
        Variable.withString(entry.contentEncrypted),
        Variable.withString(entry.contentType),
        Variable.withInt(entry.ttlDeleteAtUnix ?? 0),
        Variable.withBool(entry.isAutoDeleteEnabled),
        Variable.withInt(entry.wordCount),
        Variable.withInt(entry.createdAtUnix),
        Variable.withInt(entry.updatedAtUnix),
      ],
    );
  }

  @override
  Future<void> updateEntry(JournalEntry entry) => insertEntry(entry);

  @override
  Future<JournalEntry?> getEntryById(String id) async {
    final rows = await _db.customSelect(
      'SELECT * FROM journal_entries WHERE id = ? LIMIT 1',
      variables: [Variable<String>(id)],
    ).get();

    if (rows.isEmpty) return null;
    return _mapRowToEntry(rows.first.data);
  }

  @override
  Future<List<JournalEntry>> getAllEntries() async {
    final rows = await _db.customSelect(
      'SELECT * FROM journal_entries ORDER BY created_at_unix DESC',
    ).get();

    return rows.map((r) => _mapRowToEntry(r.data)).toList();
  }

  @override
  Stream<List<JournalEntry>> watchAllEntries() {
    return _db.customSelect(
      'SELECT * FROM journal_entries ORDER BY created_at_unix DESC',
    ).watch().map((rows) => rows.map((r) => _mapRowToEntry(r.data)).toList());
  }

  @override
  Future<void> overwriteContentBeforeDelete(String id) async {
    await _db.customUpdate(
      "UPDATE journal_entries SET content_encrypted = '0000000000000000000000000000' WHERE id = ?",
      variables: [Variable<String>(id)],
    );
  }

  @override
  Future<void> deleteEntryById(String id, {bool secureErase = true}) async {
    if (secureErase) {
      await overwriteContentBeforeDelete(id);
    }
    await _db.customUpdate(
      'DELETE FROM journal_entries WHERE id = ?',
      variables: [Variable<String>(id)],
    );
  }

  @override
  Future<int> purgeExpiredEntries(int currentUnixTimestamp) async {
    // Zero out content first for flash hygiene
    await _db.customUpdate(
      "UPDATE journal_entries SET content_encrypted = '0000000000000000000000000000' "
      "WHERE (is_auto_delete_enabled = 1 OR is_auto_delete_enabled = TRUE) AND ttl_delete_at_unix IS NOT NULL AND ttl_delete_at_unix <= ?",
      variables: [Variable<int>(currentUnixTimestamp)],
    );

    return await _db.customUpdate(
      'DELETE FROM journal_entries WHERE (is_auto_delete_enabled = 1 OR is_auto_delete_enabled = TRUE) AND ttl_delete_at_unix IS NOT NULL AND ttl_delete_at_unix <= ?',
      variables: [Variable<int>(currentUnixTimestamp)],
    );
  }

  @override
  Future<void> deleteAll({bool secureErase = true}) async {
    if (secureErase) {
      await _db.customUpdate(
        "UPDATE journal_entries SET content_encrypted = '0000000000000000000000000000'",
      );
    }
    await _db.customUpdate('DELETE FROM journal_entries');
  }

  JournalEntry _mapRowToEntry(Map<String, dynamic> row) {
    return JournalEntry(
      id: row['id'] as String,
      checkInId: row['check_in_id'] as String?,
      title: (row['title'] as String?) ?? '',
      contentEncrypted: (row['content_encrypted'] as String?) ?? '',
      contentType: (row['content_type'] as String?) ?? 'text',
      ttlDeleteAtUnix: row['ttl_delete_at_unix'] as int?,
      isAutoDeleteEnabled: (row['is_auto_delete_enabled'] is bool)
          ? row['is_auto_delete_enabled'] as bool
          : ((row['is_auto_delete_enabled'] as int?) == 1),
      wordCount: (row['word_count'] as int?) ?? 0,
      createdAtUnix: row['created_at_unix'] as int,
      updatedAtUnix: row['updated_at_unix'] as int,
    );
  }
}
