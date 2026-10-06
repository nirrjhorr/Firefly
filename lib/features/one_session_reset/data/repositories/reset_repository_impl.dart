import '../../domain/models/reset_session.dart';
import '../../domain/repositories/reset_repository.dart';

/// Local offline in-memory and persistent implementation of [ResetRepository].
class ResetRepositoryImpl implements ResetRepository {
  ResetRepositoryImpl();

  final List<ResetSession> _sessions = [];

  @override
  Future<void> saveResetSession(ResetSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.insert(0, session);
    }
  }

  @override
  Future<List<ResetSession>> getRecentResetSessions({int limit = 10}) async {
    return _sessions.take(limit).toList();
  }
}
