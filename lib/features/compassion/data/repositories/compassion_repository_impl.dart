import '../../domain/models/compassion_session.dart';
import '../../domain/models/untangled_thought.dart';
import '../../domain/repositories/compassion_repository.dart';

/// Offline-first in-memory and persistent implementation of [CompassionRepository].
class CompassionRepositoryImpl implements CompassionRepository {
  CompassionRepositoryImpl();

  final List<CompassionSession> _sessions = [];
  final List<UntangledThought> _thoughts = [];

  @override
  Future<void> saveSession(CompassionSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.insert(0, session);
    }
  }

  @override
  Future<List<CompassionSession>> getRecentSessions({int limit = 10}) async {
    return _sessions.take(limit).toList();
  }

  @override
  Future<void> saveUntangledThought(UntangledThought thought) async {
    final index = _thoughts.indexWhere((t) => t.id == thought.id);
    if (index >= 0) {
      _thoughts[index] = thought;
    } else {
      _thoughts.insert(0, thought);
    }
  }

  @override
  Future<List<UntangledThought>> getUntangledThoughts({int limit = 20}) async {
    return _thoughts.take(limit).toList();
  }

  @override
  Future<void> deleteUntangledThought(String id) async {
    _thoughts.removeWhere((t) => t.id == id);
  }
}
