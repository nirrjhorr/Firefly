import 'dart:async';
import 'package:drift/drift.dart';
import '../../features/journaling/domain/models/journal_entry.dart';
import '../app_database.dart';

/// Data Access Object contract for JournalEntries table.
abstract class JournalDao {
  Future<void> insertEntry(JournalEntry entry);
  Future<void> updateEntry(JournalEntry entry);
  Future<JournalEntry?> getEntryById(String id);
  Future<List<JournalEntry>> getAllEntries();
  Stream<List<JournalEntry>> watchAllEntries();
  Future<void> deleteEntryById(String id, {bool secureErase = true});
  Future<int> purgeExpiredEntries(int currentUnixTimestamp);
  Future<void> overwriteContentBeforeDelete(String id);
  Future<void> deleteAll({bool secureErase = true});

  factory JournalDao.inMemory([List<JournalEntry>? initialEntries]) =>
      InMemoryJournalDao(initialEntries);

  factory JournalDao.drift(AppDatabase db) => DriftJournalDao(db);
}

/// In-memory implementation of [JournalDao] for isolated unit tests,
/// headless runs, and fast ephemeral storage.
class InMemoryJournalDao implements JournalDao {
  InMemoryJournalDao([List<JournalEntry>? initialEntries])
      : _entries = List.from(initialEntries ?? []) {
    _streamController = StreamController<List<JournalEntry>>.broadcast();
  }

  final List<JournalEntry> _entries;
  late final StreamController<List<JournalEntry>> _streamController;

  void _notify() {
    _entries.sort((a, b) => b.createdAtUnix.compareTo(a.createdAtUnix));
    _streamController.add(List.unmodifiable(_entries));
  }

  @override
  Future<void> insertEntry(JournalEntry entry) async {
    _entries.removeWhere((e) => e.id == entry.id);
    _entries.add(entry);
    _notify();
  }

  @override
  Future<void> updateEntry(JournalEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      _entries[index] = entry;
      _notify();
    }
  }

  @override
  Future<JournalEntry?> getEntryById(String id) async {
    try {
      return _entries.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<JournalEntry>> getAllEntries() async {
    final list = List<JournalEntry>.from(_entries);
    list.sort((a, b) => b.createdAtUnix.compareTo(a.createdAtUnix));
    return list;
  }

  @override
  Stream<List<JournalEntry>> watchAllEntries() async* {
    yield await getAllEntries();
    yield* _streamController.stream;
  }

  @override
  Future<void> overwriteContentBeforeDelete(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(
        contentEncrypted: '0000000000000000000000000000',
        contentPlaintext: '',
      );
    }
  }

  @override
  Future<void> deleteEntryById(String id, {bool secureErase = true}) async {
    if (secureErase) {
      await overwriteContentBeforeDelete(id);
    }
    _entries.removeWhere((e) => e.id == id);
    _notify();
  }

  @override
  Future<int> purgeExpiredEntries(int currentUnixTimestamp) async {
    final expired = _entries.where((e) {
      if (e.ttlDeleteAtUnix == null) return false;
      return e.isAutoDeleteEnabled && e.ttlDeleteAtUnix! <= currentUnixTimestamp;
    }).toList();

    for (final entry in expired) {
      await overwriteContentBeforeDelete(entry.id);
    }

    _entries.removeWhere((e) {
      if (e.ttlDeleteAtUnix == null) return false;
      return e.isAutoDeleteEnabled && e.ttlDeleteAtUnix! <= currentUnixTimestamp;
    });

    if (expired.isNotEmpty) {
      _notify();
    }

    return expired.length;
  }

  @override
  Future<void> deleteAll({bool secureErase = true}) async {
    if (secureErase) {
      for (final entry in _entries) {
        await overwriteContentBeforeDelete(entry.id);
      }
    }
    _entries.clear();
    _notify();
  }

  void dispose() {
    _streamController.close();
  }
}

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
        Variable<String>(entry.id),
        Variable<String?>(entry.checkInId),
        Variable<String>(entry.title),
        Variable<String>(entry.contentEncrypted),
        Variable<String>(entry.contentType),
        Variable<int?>(entry.ttlDeleteAtUnix),
        Variable<bool>(entry.isAutoDeleteEnabled),
        Variable<int>(entry.wordCount),
        Variable<int>(entry.createdAtUnix),
        Variable<int>(entry.updatedAtUnix),
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
