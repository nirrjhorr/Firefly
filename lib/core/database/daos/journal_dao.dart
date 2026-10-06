import 'dart:async';
import '../../../features/journaling/domain/models/journal_entry.dart';
import '../app_database.dart' hide JournalEntry;
import 'drift_journal_dao.dart';

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
    final copy = List<JournalEntry>.from(_entries);
    copy.sort((a, b) => b.createdAtUnix.compareTo(a.createdAtUnix));
    return copy;
  }

  @override
  Stream<List<JournalEntry>> watchAllEntries() {
    return _streamController.stream;
  }

  @override
  Future<void> overwriteContentBeforeDelete(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      final existing = _entries[index];
      _entries[index] = existing.copyWith(
        contentEncrypted: '0000000000000000000000000000',
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
    final toRemove = _entries
        .where((e) =>
            e.isAutoDeleteEnabled &&
            e.ttlDeleteAtUnix != null &&
            e.ttlDeleteAtUnix! <= currentUnixTimestamp)
        .toList();

    for (final entry in toRemove) {
      await overwriteContentBeforeDelete(entry.id);
      _entries.removeWhere((e) => e.id == entry.id);
    }
    if (toRemove.isNotEmpty) {
      _notify();
    }
    return toRemove.length;
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
