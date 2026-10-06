import '../models/brain_dump_item.dart';
import '../models/focus_priority.dart';
import '../models/focus_session.dart';

/// Repository interface governing Focus & Mental Organisation data.
/// Strictly offline and zero-knowledge.
abstract interface class FocusRepository {
  /// Retrieves the current active priorities (up to 3).
  Future<List<FocusPriority>> getPriorities();

  /// Saves or updates a priority. Enforces a maximum of 3 items.
  Future<void> savePriority(FocusPriority priority);

  /// Toggles the completion state of a priority by [id].
  Future<void> togglePriorityCompletion(String id);

  /// Deletes a priority by [id].
  Future<void> deletePriority(String id);

  /// Clears all priorities.
  Future<void> clearPriorities();

  /// Retrieves all unparked or recent brain dump items.
  Future<List<BrainDumpItem>> getBrainDumpItems();

  /// Adds a new brain dump item.
  Future<void> addBrainDumpItem(BrainDumpItem item);

  /// Toggles the parked state of a brain dump item by [id].
  Future<void> toggleParkBrainDumpItem(String id);

  /// Deletes a brain dump item by [id].
  Future<void> deleteBrainDumpItem(String id);

  /// Clears all brain dump items.
  Future<void> clearBrainDumpItems();

  /// Retrieves completed focus sessions.
  Future<List<FocusSession>> getRecentSessions();

  /// Persists a completed or updated focus session.
  Future<void> saveSession(FocusSession session);
}
