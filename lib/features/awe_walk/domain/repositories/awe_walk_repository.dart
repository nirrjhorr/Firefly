import '../models/awe_prompt.dart';
import '../models/awe_walk_session.dart';

/// Contract for Awe Walk data access, session persistence, and prompt retrieval.
abstract class AweWalkRepository {
  /// Returns curated evidence-based prompts for the walk.
  List<AwePrompt> getCuratedPrompts();

  /// Persists a completed or in-progress session offline.
  Future<void> saveSession(AweWalkSession session);

  /// Retrieves recent Awe Walk sessions.
  Future<List<AweWalkSession>> getRecentSessions({int limit = 10});

  /// Total count of completed awe walks.
  Future<int> getCompletedCount();
}
