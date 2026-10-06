import '../models/reset_session.dart';

/// Contract for saving and reading completed Single-Session Intervention resets.
abstract class ResetRepository {
  Future<void> saveResetSession(ResetSession session);
  Future<List<ResetSession>> getRecentResetSessions({int limit = 10});
}
