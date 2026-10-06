import '../models/compassion_session.dart';
import '../models/untangled_thought.dart';

/// Contract for persisting and retrieving self-compassion sessions and untangled thoughts.
abstract class CompassionRepository {
  Future<void> saveSession(CompassionSession session);
  Future<List<CompassionSession>> getRecentSessions({int limit = 10});
  Future<void> saveUntangledThought(UntangledThought thought);
  Future<List<UntangledThought>> getUntangledThoughts({int limit = 20});
  Future<void> deleteUntangledThought(String id);
}
