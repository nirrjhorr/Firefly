import '../models/worry_dump_entry.dart';

/// Repository interface for storing and managing pre-bed parked worry dumps.
abstract class WorryDumpRepository {
  /// Persists a parked worry entry with application-layer encryption.
  Future<void> saveParkedWorry(WorryDumpEntry entry);

  /// Retrieves all non-expired parked worry entries.
  Future<List<WorryDumpEntry>> getParkedWorries();

  /// Permanently removes a worry entry by ID with cryptographic zeroing.
  Future<void> deleteWorry(String id, {bool secureErase = true});

  /// Automatically purges entries whose 24h TTL has passed.
  Future<int> purgeExpiredWorries();
}
