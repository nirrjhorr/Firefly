import '../../domain/models/awe_prompt.dart';
import '../../domain/models/awe_walk_session.dart';
import '../../domain/repositories/awe_walk_repository.dart';

/// Offline-first in-memory & local implementation of [AweWalkRepository].
class AweWalkRepositoryImpl implements AweWalkRepository {
  AweWalkRepositoryImpl();

  final List<AweWalkSession> _sessions = [];

  @override
  List<AwePrompt> getCuratedPrompts() {
    return AwePrompt.curatedPrompts;
  }

  @override
  Future<void> saveSession(AweWalkSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.insert(0, session);
    }
  }

  @override
  Future<List<AweWalkSession>> getRecentSessions({int limit = 10}) async {
    return _sessions.take(limit).toList();
  }

  @override
  Future<int> getCompletedCount() async {
    return _sessions.where((s) => s.isComplete).length;
  }
}
