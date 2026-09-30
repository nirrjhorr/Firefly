import '../../../../core/errors/result.dart';
import '../models/check_in_entry.dart';

abstract class CheckInRepository {
  Future<Result<CheckInEntry, Exception>> saveCheckIn(CheckInEntry entry);
  Future<Result<CheckInEntry?, Exception>> getLatestCheckIn();
  Future<Result<List<CheckInEntry>, Exception>> getRecentCheckIns({int limit = 10});
  Future<Result<void, Exception>> deleteCheckIn(String id);
}
