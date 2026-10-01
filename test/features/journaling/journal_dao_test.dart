import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/core/database/daos/journal_dao.dart';
import 'package:firefly/features/journaling/domain/models/journal_entry.dart';

void main() {
  group('JournalDao & TTL Expiry Engine', () {
    late JournalDao dao;
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    setUp(() {
      dao = JournalDao.inMemory();
    });

    test('CRUD operations: insert, get, update, delete', () async {
      final entry = JournalEntry(
        id: 'entry-test-1',
        title: 'Initial Entry',
        contentEncrypted: 'ZW5jcnlwdGVkMQ==',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );

      await dao.insertEntry(entry);

      final retrieved = await dao.getEntryById('entry-test-1');
      expect(retrieved, isNotNull);
      expect(retrieved!.id, equals('entry-test-1'));
      expect(retrieved.title, equals('Initial Entry'));

      // Update
      final updated = entry.copyWith(title: 'Updated Entry Title');
      await dao.updateEntry(updated);

      final retrievedUpdated = await dao.getEntryById('entry-test-1');
      expect(retrievedUpdated!.title, equals('Updated Entry Title'));

      // Delete
      await dao.deleteEntryById('entry-test-1');
      final afterDelete = await dao.getEntryById('entry-test-1');
      expect(afterDelete, isNull);
    });

    test('purgeExpiredEntries deletes expired entries only when isAutoDeleteEnabled is true', () async {
      final expiredActive = JournalEntry(
        id: 'expired-active',
        title: 'Expired active auto-delete',
        contentEncrypted: 'payload-exp-1',
        ttlDeleteAtUnix: nowUnix - 3600,
        isAutoDeleteEnabled: true,
        createdAtUnix: nowUnix - 7200,
        updatedAtUnix: nowUnix - 7200,
      );

      final expiredDisabled = JournalEntry(
        id: 'expired-disabled',
        title: 'Expired but auto-delete disabled',
        contentEncrypted: 'payload-exp-2',
        ttlDeleteAtUnix: nowUnix - 10,
        isAutoDeleteEnabled: false, // Disabled! Must NOT be purged
        createdAtUnix: nowUnix - 600,
        updatedAtUnix: nowUnix - 600,
      );

      final activeFutureTtl = JournalEntry(
        id: 'active-future-ttl',
        title: 'Expires in 2 hours',
        contentEncrypted: 'payload-active',
        ttlDeleteAtUnix: nowUnix + 7200,
        isAutoDeleteEnabled: true,
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );

      final permanent = JournalEntry(
        id: 'permanent',
        title: 'Permanent entry',
        contentEncrypted: 'payload-perm',
        ttlDeleteAtUnix: null,
        isAutoDeleteEnabled: false,
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );

      await dao.insertEntry(expiredActive);
      await dao.insertEntry(expiredDisabled);
      await dao.insertEntry(activeFutureTtl);
      await dao.insertEntry(permanent);

      final allBefore = await dao.getAllEntries();
      expect(allBefore.length, equals(4));

      final purgedCount = await dao.purgeExpiredEntries(nowUnix);
      expect(purgedCount, equals(1)); // Only expiredActive should be purged

      final allAfter = await dao.getAllEntries();
      expect(allAfter.length, equals(3));
      expect(allAfter.map((e) => e.id), containsAll(['expired-disabled', 'active-future-ttl', 'permanent']));
      expect(allAfter.map((e) => e.id), isNot(contains('expired-active')));
    });

    test('overwriteContentBeforeDelete zeroes out encrypted content', () async {
      final entry = JournalEntry(
        id: 'zero-test',
        title: 'NAND Flash Hygiene Test',
        contentEncrypted: 'c2Vuc2l0aXZlLWRhdGE=',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );

      await dao.insertEntry(entry);
      await dao.overwriteContentBeforeDelete('zero-test');

      final overwritten = await dao.getEntryById('zero-test');
      expect(overwritten!.contentEncrypted, startsWith('00000000'));
    });

    test('watchAllEntries immediately emits current entries to late subscribers', () async {
      final entry1 = JournalEntry(
        id: 'entry-late-1',
        title: 'First',
        contentEncrypted: 'abc',
        createdAtUnix: nowUnix - 10,
        updatedAtUnix: nowUnix - 10,
      );
      await dao.insertEntry(entry1);

      // Late subscriber
      final initialList = await dao.watchAllEntries().first;
      expect(initialList.length, equals(1));
      expect(initialList.first.id, equals('entry-late-1'));
    });

    test('deleteAll removes all entries with optional secure erase', () async {
      await dao.insertEntry(JournalEntry(
        id: 'del-1',
        title: 'One',
        contentEncrypted: 'enc1',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      ));
      await dao.insertEntry(JournalEntry(
        id: 'del-2',
        title: 'Two',
        contentEncrypted: 'enc2',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      ));

      expect((await dao.getAllEntries()).length, equals(2));

      await dao.deleteAll(secureErase: true);
      expect((await dao.getAllEntries()).isEmpty, isTrue);
    });
  });
}
