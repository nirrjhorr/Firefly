import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/features/journaling/domain/models/journal_entry.dart';

void main() {
  group('JournalEntry Domain Model', () {
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    test('Instantiates with valid defaults and fields', () {
      final entry = JournalEntry(
        id: 'entry-1',
        title: 'Morning reflection',
        contentEncrypted: 'c2VjcmV0LWJsb2I=',
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );

      expect(entry.id, equals('entry-1'));
      expect(entry.title, equals('Morning reflection'));
      expect(entry.contentPlaintext, isNull);
      expect(entry.contentEncrypted, equals('c2VjcmV0LWJsb2I='));
      expect(entry.contentType, equals('text'));
      expect(entry.ttlDeleteAtUnix, isNull);
      expect(entry.isAutoDeleteEnabled, isFalse);
      expect(entry.wordCount, equals(0));
      expect(entry.isExpired, isFalse);
      expect(entry.remainingTtlSeconds, isNull);
      expect(entry.isUnsentLetter, isFalse);
      expect(entry.hasDecryptedContent, isFalse);
    });

    test('TTL calculation and isExpired behavior', () {
      final futureExpiry = nowUnix + 3600; // 1 hour in future
      final pastExpiry = nowUnix - 60; // 1 minute in past

      final activeEntry = JournalEntry(
        id: 'active-1',
        title: 'Expiring soon',
        contentEncrypted: 'xyz',
        ttlDeleteAtUnix: futureExpiry,
        isAutoDeleteEnabled: true,
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );

      expect(activeEntry.isExpired, isFalse);
      expect(activeEntry.remainingTtlSeconds, isNotNull);
      expect(activeEntry.remainingTtlSeconds!, greaterThan(0));
      expect(activeEntry.isUnsentLetter, isTrue);

      final expiredEntry = JournalEntry(
        id: 'expired-1',
        title: 'Already expired',
        contentEncrypted: 'xyz',
        ttlDeleteAtUnix: pastExpiry,
        isAutoDeleteEnabled: true,
        createdAtUnix: nowUnix - 3600,
        updatedAtUnix: nowUnix - 3600,
      );

      expect(expiredEntry.isExpired, isTrue);
      expect(expiredEntry.remainingTtlSeconds, equals(0));
    });

    test('copyWith updates specified fields and clear flags correctly', () {
      final entry = JournalEntry(
        id: 'orig-id',
        title: 'Original Title',
        contentPlaintext: 'Clear secret thoughts',
        contentEncrypted: 'encrypted-base64',
        ttlDeleteAtUnix: nowUnix + 300,
        isAutoDeleteEnabled: true,
        wordCount: 3,
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix,
      );

      final withoutPlaintext = entry.copyWith(clearPlaintext: true);
      expect(withoutPlaintext.contentPlaintext, isNull);
      expect(withoutPlaintext.contentEncrypted, equals('encrypted-base64'));

      final withoutTtl = entry.copyWith(clearTtl: true);
      expect(withoutTtl.ttlDeleteAtUnix, isNull);

      final updated = entry.copyWith(title: 'Updated Title', wordCount: 15);
      expect(updated.title, equals('Updated Title'));
      expect(updated.wordCount, equals(15));
    });

    test('Serialization to and from JSON produces identical model', () {
      final entry = JournalEntry(
        id: 'json-entry',
        checkInId: 'checkin-42',
        title: 'JSON serialization test',
        contentEncrypted: 'ZW5jcnlwdGVkLXN0dWZm',
        contentType: 'voice',
        ttlDeleteAtUnix: nowUnix + 7200,
        isAutoDeleteEnabled: true,
        wordCount: 88,
        createdAtUnix: nowUnix,
        updatedAtUnix: nowUnix + 100,
      );

      final json = entry.toJson();
      final restored = JournalEntry.fromJson(json);

      expect(restored, equals(entry));
      expect(restored.checkInId, equals('checkin-42'));
      expect(restored.contentType, equals('voice'));
      expect(restored.wordCount, equals(88));
    });
  });
}
