import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:app.firefly/core/database/daos/journal_dao.dart';
import 'package:app.firefly/core/security/journal_crypto_service.dart';
import 'package:app.firefly/core/security/key_manager.dart';
import 'package:app.firefly/features/journaling/data/repositories/journal_repository_impl.dart';
import 'package:app.firefly/features/journaling/domain/models/journal_entry.dart';
import 'package:app.firefly/features/journaling/domain/repositories/journal_repository.dart';

class MockKeyManager extends Mock implements KeyManager {}

void main() {
  group('JournalRepository & Need-To-Know Decryption', () {
    late JournalCryptoService cryptoService;
    late MockKeyManager mockKeyManager;
    late InMemoryJournalDao dao;
    late JournalRepositoryImpl repository;

    const testMasterKey = 'dGhpcy1pcy1hLXNlY3VyZS0yNTYtYml0LW1hc3Rlci1rZXk=';
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    setUp(() {
      cryptoService = JournalCryptoService();
      mockKeyManager = MockKeyManager();
      when(() => mockKeyManager.getOrGenerateDatabaseKey())
          .thenAnswer((_) async => testMasterKey);

      dao = InMemoryJournalDao();
      repository = JournalRepositoryImpl(
        cryptoService: cryptoService,
        keyManager: mockKeyManager,
        dao: dao,
      );
    });

    test('saveEntry encrypts plaintext, computes word count, and persists encrypted payload', () async {
      const plaintext = 'This is an unsent letter to myself.';

      final entry = JournalEntry(
        id: 'entry-save-1',
        title: 'Unsent letter',
        contentPlaintext: plaintext,
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );

      final saveResult = await repository.saveEntry(entry);
      expect(saveResult.isOk, isTrue);

      final saved = saveResult.unwrap();
      expect(saved.wordCount, equals(7));
      expect(saved.contentEncrypted, isNotEmpty);
      expect(saved.contentEncrypted, isNot(equals(plaintext)));

      // In the underlying DAO, plaintext must NOT be persisted
      final rawDaoEntry = await dao.getEntryById('entry-save-1');
      expect(rawDaoEntry, isNotNull);
      expect(rawDaoEntry!.contentPlaintext, isNull);
      expect(rawDaoEntry.contentEncrypted, equals(saved.contentEncrypted));
    });

    test('saveEntry recalculates word count and updates timestamp when editing existing entry', () async {
      final initialEntry = JournalEntry(
        id: 'entry-edit-1',
        title: 'Draft',
        contentPlaintext: 'Short note',
        wordCount: 2,
        createdAtUnix: nowUnix - 500,
        updatedAtUnix: nowUnix - 500,
      );
      await repository.saveEntry(initialEntry);

      // Edit with longer text
      final updatedEntry = initialEntry.copyWith(
        contentPlaintext: 'Now this entry has considerably more words than before.',
      );
      final saveResult = await repository.saveEntry(updatedEntry);
      expect(saveResult.isOk, isTrue);

      final saved = saveResult.unwrap();
      expect(saved.wordCount, equals(9));
      expect(saved.updatedAtUnix, greaterThanOrEqualTo(nowUnix));
    });

    test('saveEntry handles clearing content to empty string', () async {
      final entry = JournalEntry(
        id: 'entry-empty-content',
        title: 'Empty Content Entry',
        contentPlaintext: '',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );

      final saveResult = await repository.saveEntry(entry);
      expect(saveResult.isOk, isTrue);

      final saved = saveResult.unwrap();
      expect(saved.wordCount, equals(0));
      expect(saved.contentEncrypted, equals(''));

      final retrieved = await repository.getEntryById('entry-empty-content', decrypt: true);
      expect(retrieved.isOk, isTrue);
      expect(retrieved.unwrap()!.contentPlaintext, equals(''));
    });

    test('Need-to-know decryption: getEntries() returns encrypted entries without plaintext in memory', () async {
      final entry = JournalEntry(
        id: 'entry-ntk-1',
        title: 'Confidential Journal',
        contentPlaintext: 'My private inner thoughts.',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );

      await repository.saveEntry(entry);

      final listResult = await repository.getEntries();
      expect(listResult.isOk, isTrue);

      final entries = listResult.unwrap();
      expect(entries.length, equals(1));
      expect(entries.first.contentPlaintext, isNull);
      expect(entries.first.contentEncrypted, isNotEmpty);
      expect(entries.first.hasDecryptedContent, isFalse);
    });

    test('Need-to-know decryption: getEntryById(decrypt: false) leaves plaintext null, decrypt: true restores plaintext', () async {
      const sensitiveText = 'Deep vulnerable confession.';
      final entry = JournalEntry(
        id: 'entry-decrypt-1',
        title: 'Confession',
        contentPlaintext: sensitiveText,
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );

      await repository.saveEntry(entry);

      // Without decrypt flag
      final getWithoutDecrypt = await repository.getEntryById('entry-decrypt-1', decrypt: false);
      expect(getWithoutDecrypt.isOk, isTrue);
      expect(getWithoutDecrypt.unwrap()!.contentPlaintext, isNull);

      // With decrypt flag
      final getWithDecrypt = await repository.getEntryById('entry-decrypt-1', decrypt: true);
      expect(getWithDecrypt.isOk, isTrue);
      expect(getWithDecrypt.unwrap()!.contentPlaintext, equals(sensitiveText));
    });

    test('Automated TTL cleanup removes expired entries upon saveEntry', () async {
      // Create an expired entry directly in the DAO
      final expired = JournalEntry(
        id: 'expired-entry',
        title: 'Expired unsent letter',
        contentEncrypted: 'payload',
        ttlDeleteAtUnix: nowUnix - 100,
        isAutoDeleteEnabled: true,
        createdAtUnix: nowUnix - 1000,
        updatedAtUnix: nowUnix - 1000,
      );
      await dao.insertEntry(expired);

      final daoBefore = await dao.getAllEntries();
      expect(daoBefore.length, equals(1));

      // Saving a new entry triggers automatic purge
      final newEntry = JournalEntry(
        id: 'new-active-entry',
        title: 'Active note',
        contentPlaintext: 'Still relevant.',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );
      await repository.saveEntry(newEntry);

      final daoAfter = await dao.getAllEntries();
      expect(daoAfter.length, equals(1));
      expect(daoAfter.first.id, equals('new-active-entry'));
      expect(daoAfter.any((e) => e.id == 'expired-entry'), isFalse);
    });

    test('deleteEntry removes entry with secureErase option', () async {
      final entry = JournalEntry(
        id: 'to-delete',
        title: 'To be wiped',
        contentPlaintext: 'Burn this letter immediately.',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );
      await repository.saveEntry(entry);

      final delResult = await repository.deleteEntry('to-delete', secureErase: true);
      expect(delResult.isOk, isTrue);

      final fetched = await repository.getEntryById('to-delete');
      expect(fetched.unwrap(), isNull);
    });

    test('watchEntries emits updated list stream reactively', () async {
      final stream = repository.watchEntries();
      final history = <List<JournalEntry>>[];
      final sub = stream.listen(history.add);

      await pumpEventQueue();

      final entry = JournalEntry(
        id: 'stream-repo-entry',
        title: 'Stream reflection',
        contentPlaintext: 'Reflecting on growth.',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );
      await repository.saveEntry(entry);
      await pumpEventQueue();

      expect(history.last.any((e) => e.id == 'stream-repo-entry'), isTrue);

      await repository.deleteEntry('stream-repo-entry');
      await pumpEventQueue();

      expect(history.last.any((e) => e.id == 'stream-repo-entry'), isFalse);

      await sub.cancel();
    });

    test('Riverpod providers instantiate and observe stream', () async {
      final container = ProviderContainer(
        overrides: [
          journalDaoProvider.overrideWithValue(dao),
          keyManagerProvider.overrideWithValue(mockKeyManager),
        ],
      );
      addTearDown(container.dispose);

      final repo = container.read(journalRepositoryProvider);
      expect(repo, isA<JournalRepository>());

      final streamState = container.read(journalEntriesStreamProvider);
      expect(streamState, isNotNull);
    });
  });
}
