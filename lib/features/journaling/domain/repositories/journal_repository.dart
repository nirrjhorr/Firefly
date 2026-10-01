import '../../../../core/errors/result.dart';
import '../models/journal_entry.dart';

/// Contract for Journal and Unsent Letters data storage, encryption, and lifecycle operations.
abstract class JournalRepository {
  /// Watches all journal entries reactively.
  /// Emits entries with encrypted payloads only (contentPlaintext remains null for memory safety).
  Stream<List<JournalEntry>> watchEntries();

  /// Retrieves all entries without decrypting payloads (need-to-know pattern).
  Future<Result<List<JournalEntry>, Exception>> getEntries();

  /// Retrieves a specific entry by [id].
  /// When [decrypt] is true, decrypts `contentEncrypted` into `contentPlaintext`.
  Future<Result<JournalEntry?, Exception>> getEntryById(String id, {bool decrypt = false});

  /// Saves or updates a journal entry.
  /// If `contentPlaintext` is provided, double-encrypts it before persistence.
  /// Automatically triggers TTL cleanup after saving.
  Future<Result<JournalEntry, Exception>> saveEntry(JournalEntry entry);

  /// Deletes an entry with cryptographic erasure of stored content.
  Future<Result<void, Exception>> deleteEntry(String id, {bool secureErase = true});

  /// Purges all entries whose TTL expiration timestamp is at or before [currentUnixTimestamp].
  /// Defaults to `DateTime.now().millisecondsSinceEpoch ~/ 1000`.
  Future<Result<int, Exception>> purgeExpiredEntries([int? currentUnixTimestamp]);

  /// Deletes all journal entries with secure erasure.
  Future<Result<void, Exception>> deleteAll();
}
