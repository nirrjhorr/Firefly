import '../../domain/models/brain_dump_item.dart';
import '../../domain/models/focus_priority.dart';
import '../../domain/models/focus_session.dart';
import '../../domain/repositories/focus_repository.dart';

/// Offline-first repository implementation managing Focus & Mental Organisation data.
class FocusRepositoryImpl implements FocusRepository {
  FocusRepositoryImpl();

  final List<FocusPriority> _priorities = [];
  final List<BrainDumpItem> _brainDumpItems = [];
  final List<FocusSession> _sessions = [];

  @override
  Future<List<FocusPriority>> getPriorities() async {
    return List.unmodifiable(_priorities);
  }

  @override
  Future<void> savePriority(FocusPriority priority) async {
    final index = _priorities.indexWhere((p) => p.id == priority.id);
    if (index >= 0) {
      _priorities[index] = priority;
    } else {
      // Enforce hard ceiling of 3 priorities
      if (_priorities.length < 3) {
        _priorities.add(priority);
      } else {
        // Replace oldest or last incomplete
        _priorities[2] = priority.copyWith(orderIndex: 2);
      }
    }
  }

  @override
  Future<void> togglePriorityCompletion(String id) async {
    final index = _priorities.indexWhere((p) => p.id == id);
    if (index >= 0) {
      final current = _priorities[index];
      final isNowCompleted = !current.isCompleted;
      _priorities[index] = current.copyWith(
        isCompleted: isNowCompleted,
        completedAt: isNowCompleted ? DateTime.now() : null,
      );
    }
  }

  @override
  Future<void> deletePriority(String id) async {
    _priorities.removeWhere((p) => p.id == id);
    // Re-index remaining priorities
    for (int i = 0; i < _priorities.length; i++) {
      _priorities[i] = _priorities[i].copyWith(orderIndex: i);
    }
  }

  @override
  Future<void> clearPriorities() async {
    _priorities.clear();
  }

  @override
  Future<List<BrainDumpItem>> getBrainDumpItems() async {
    return List.unmodifiable(_brainDumpItems);
  }

  @override
  Future<void> addBrainDumpItem(BrainDumpItem item) async {
    final index = _brainDumpItems.indexWhere((b) => b.id == item.id);
    if (index >= 0) {
      _brainDumpItems[index] = item;
    } else {
      _brainDumpItems.insert(0, item);
    }
  }

  @override
  Future<void> toggleParkBrainDumpItem(String id) async {
    final index = _brainDumpItems.indexWhere((b) => b.id == id);
    if (index >= 0) {
      final current = _brainDumpItems[index];
      _brainDumpItems[index] = current.copyWith(isParked: !current.isParked);
    }
  }

  @override
  Future<void> deleteBrainDumpItem(String id) async {
    _brainDumpItems.removeWhere((b) => b.id == id);
  }

  @override
  Future<void> clearBrainDumpItems() async {
    _brainDumpItems.clear();
  }

  @override
  Future<List<FocusSession>> getRecentSessions({int limit = 10}) async {
    return _sessions.take(limit).toList();
  }

  @override
  Future<void> saveSession(FocusSession session) async {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.insert(0, session);
    }
  }
}
