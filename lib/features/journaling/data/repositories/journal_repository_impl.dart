import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart' hide JournalEntry;
import '../../../../core/database/daos/journal_dao.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/security/journal_crypto_service.dart';
import '../../../../core/security/key_manager.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';

/// Implementation of [JournalRepository] providing need-to-know decryption,
/// double encryption with [JournalCryptoService], and automated TTL expiration.
class JournalRepositoryImpl implements JournalRepository {
  JournalRepositoryImpl({
    required JournalCryptoService cryptoService,
    required KeyManager keyManager,
    JournalDao? dao,
    AppDatabase? database,
  })  : _cryptoService = cryptoService,
        _keyManager = keyManager,
        _dao = dao ?? (database != null ? JournalDao.drift(database) : JournalDao.inMemory()) {
    // Safely trigger initial cleanup asynchronously without unhandled errors
    scheduleMicrotask(() async {
      try {
        await purgeExpiredEntries();
      } catch (_) {}
    });
  }

  final JournalCryptoService _cryptoService;
  final KeyManager _keyManager;
  final JournalDao _dao;

  @override
  Stream<List<JournalEntry>> watchEntries() {
    return _dao.watchAllEntries();
  }

  @override
  Future<Result<List<JournalEntry>, Exception>> getEntries() async {
    try {
      final entries = await _dao.getAllEntries();
      return Ok(entries);
    } catch (e) {
      return Err(Exception('Failed to load journal entries: $e'));
    }
  }

  @override
  Future<Result<JournalEntry?, Exception>> getEntryById(
    String id, {
    bool decrypt = false,
  }) async {
    try {
      final entry = await _dao.getEntryById(id);
      if (entry == null) {
        return const Ok(null);
      }

      if (!decrypt) {
        return Ok(entry);
      }

      // If entry has empty encrypted content, return with empty plaintext
      if (entry.contentEncrypted.isEmpty) {
        return Ok(entry.copyWith(contentPlaintext: ''));
      }

      // Need-to-know decryption: decrypt only on demand
      final masterKey = await _keyManager.getOrGenerateDatabaseKey();
      final plaintext = await _cryptoService.decrypt(
        encryptedPayloadBase64: entry.contentEncrypted,
        masterKey: masterKey,
        aad: utf8.encode(entry.id),
      );

      return Ok(entry.copyWith(contentPlaintext: plaintext));
    } catch (e) {
      return Err(Exception('Failed to retrieve or decrypt journal entry: $e'));
    }
  }

  @override
  Future<Result<JournalEntry, Exception>> saveEntry(JournalEntry entry) async {
    try {
      final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      var entryToSave = entry.copyWith(updatedAtUnix: nowUnix);

      // Recompute word count if plaintext is supplied
      if (entry.contentPlaintext != null) {
        final words = entry.contentPlaintext!.trim().isEmpty
            ? 0
            : entry.contentPlaintext!.trim().split(RegExp(r'\s+')).length;
        entryToSave = entryToSave.copyWith(wordCount: words);

        // Encrypt or clear ciphertext
        if (entry.contentPlaintext!.isEmpty) {
          entryToSave = entryToSave.copyWith(contentEncrypted: '');
        } else {
          final masterKey = await _keyManager.getOrGenerateDatabaseKey();
          final encrypted = await _cryptoService.encrypt(
            plaintext: entry.contentPlaintext!,
            masterKey: masterKey,
            aad: utf8.encode(entry.id),
          );
          entryToSave = entryToSave.copyWith(contentEncrypted: encrypted);
        }
      }

      // Store in DAO without persisting transient plaintext
      final persistedEntry = entryToSave.copyWith(clearPlaintext: true);
      await _dao.insertEntry(persistedEntry);

      // Trigger TTL cleanup after write non-fatally
      try {
        await purgeExpiredEntries();
      } catch (_) {}

      return Ok(entryToSave);
    } catch (e) {
      return Err(Exception('Failed to save journal entry: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> deleteEntry(
    String id, {
    bool secureErase = true,
  }) async {
    try {
      await _dao.deleteEntryById(id, secureErase: secureErase);
      return const Ok(null);
    } catch (e) {
      return Err(Exception('Failed to delete journal entry: $e'));
    }
  }

  @override
  Future<Result<int, Exception>> purgeExpiredEntries([int? currentUnixTimestamp]) async {
    try {
      final nowUnix = currentUnixTimestamp ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000);
      final purgedCount = await _dao.purgeExpiredEntries(nowUnix);
      return Ok(purgedCount);
    } catch (e) {
      return Err(Exception('Failed to purge expired journal entries: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> deleteAll({bool secureErase = true}) async {
    try {
      await _dao.deleteAll(secureErase: secureErase);
      return const Ok(null);
    } catch (e) {
      return Err(Exception('Failed to delete all journal entries: $e'));
    }
  }
}

/// Optional provider for [JournalDao], allowing database or test overrides.
final journalDaoProvider = Provider<JournalDao>((ref) {
  return JournalDao.inMemory();
});

/// Riverpod provider for [JournalRepository].
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final cryptoService = ref.watch(journalCryptoServiceProvider);
  final keyMgr = ref.watch(keyManagerProvider);
  final dao = ref.watch(journalDaoProvider);
  return JournalRepositoryImpl(
    cryptoService: cryptoService,
    keyManager: keyMgr,
    dao: dao,
  );
});

/// Riverpod stream provider watching all journal entry summaries.
final journalEntriesStreamProvider = StreamProvider<List<JournalEntry>>((ref) {
  final repo = ref.watch(journalRepositoryProvider);
  return repo.watchEntries();
});
