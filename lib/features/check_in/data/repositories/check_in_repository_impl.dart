import '../../../../core/database/app_database.dart';
import '../../../../core/errors/result.dart';
import '../../domain/models/check_in_entry.dart';
import '../../domain/repositories/check_in_repository.dart';

class CheckInRepositoryImpl implements CheckInRepository {
  CheckInRepositoryImpl({AppDatabase? database}) : _db = database;

  final AppDatabase? _db;
  final List<CheckInEntry> _inMemoryEntries = [];

  @override
  Future<Result<CheckInEntry, Exception>> saveCheckIn(CheckInEntry entry) async {
    try {
      _inMemoryEntries.removeWhere((e) => e.id == entry.id);
      _inMemoryEntries.insert(0, entry);
      return Ok(entry);
    } catch (e) {
      return Err(Exception('Failed to save check-in: $e'));
    }
  }

  @override
  Future<Result<CheckInEntry?, Exception>> getLatestCheckIn() async {
    try {
      if (_inMemoryEntries.isEmpty) {
        return const Ok(null);
      }
      return Ok(_inMemoryEntries.first);
    } catch (e) {
      return Err(Exception('Failed to load latest check-in: $e'));
    }
  }

  @override
  Future<Result<List<CheckInEntry>, Exception>> getRecentCheckIns({
    int limit = 10,
  }) async {
    try {
      final entries = _inMemoryEntries.take(limit).toList();
      return Ok(entries);
    } catch (e) {
      return Err(Exception('Failed to load check-ins: $e'));
    }
  }

  @override
  Future<Result<void, Exception>> deleteCheckIn(String id) async {
    try {
      _inMemoryEntries.removeWhere((e) => e.id == id);
      return const Ok(null);
    } catch (e) {
      return Err(Exception('Failed to delete check-in: $e'));
    }
  }
}
