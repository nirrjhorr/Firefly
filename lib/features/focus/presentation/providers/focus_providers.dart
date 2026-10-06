import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/focus_repository_impl.dart';
import '../../domain/models/brain_dump_item.dart';
import '../../domain/models/focus_mode.dart';
import '../../domain/models/focus_priority.dart';
import '../../domain/models/focus_session.dart';
import '../../domain/repositories/focus_repository.dart';

/// Provider for [FocusRepository].
final focusRepositoryProvider = Provider<FocusRepository>((ref) {
  return FocusRepositoryImpl();
});

/// Immutable UI state for Focus & Mental Organisation.
class FocusState {
  const FocusState({
    required this.mode,
    required this.priorities,
    required this.activePriorityIndex,
    required this.brainDumpItems,
    required this.brainDumpInput,
    required this.session,
    this.isTimerRunning = false,
  });

  factory FocusState.initial({FocusMode mode = FocusMode.threePriorities}) {
    return FocusState(
      mode: mode,
      priorities: const [],
      activePriorityIndex: 0,
      brainDumpItems: const [],
      brainDumpInput: '',
      session: FocusSession.create(durationMinutes: 15),
      isTimerRunning: false,
    );
  }

  final FocusMode mode;
  final List<FocusPriority> priorities;
  final int activePriorityIndex;
  final List<BrainDumpItem> brainDumpItems;
  final String brainDumpInput;
  final FocusSession session;
  final bool isTimerRunning;

  bool get canAddPriority => priorities.length < 3;
  int get remainingPrioritySlots => 3 - priorities.length;
  FocusPriority? get activePriority =>
      priorities.isNotEmpty && activePriorityIndex < priorities.length
          ? priorities[activePriorityIndex]
          : null;

  FocusState copyWith({
    FocusMode? mode,
    List<FocusPriority>? priorities,
    int? activePriorityIndex,
    List<BrainDumpItem>? brainDumpItems,
    String? brainDumpInput,
    FocusSession? session,
    bool? isTimerRunning,
  }) {
    return FocusState(
      mode: mode ?? this.mode,
      priorities: priorities ?? this.priorities,
      activePriorityIndex: activePriorityIndex ?? this.activePriorityIndex,
      brainDumpItems: brainDumpItems ?? this.brainDumpItems,
      brainDumpInput: brainDumpInput ?? this.brainDumpInput,
      session: session ?? this.session,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
    );
  }
}

/// Controller managing Focus, Three Priorities, Brain Dump, and Timer state.
class FocusNotifier extends StateNotifier<FocusState> {
  FocusNotifier(this._repository) : super(FocusState.initial()) {
    _loadInitialData();
  }

  final FocusRepository _repository;
  Timer? _tickerTimer;

  Future<void> _loadInitialData() async {
    final priorities = await _repository.getPriorities();
    final brainDumps = await _repository.getBrainDumpItems();
    state = state.copyWith(
      priorities: priorities,
      brainDumpItems: brainDumps,
    );
  }

  void setMode(FocusMode mode) {
    state = state.copyWith(mode: mode);
  }

  // ---------------------------------------------------------------------------
  // Three Priorities Logic (Rule of 3)
  // ---------------------------------------------------------------------------

  Future<bool> addPriority(String title) async {
    if (title.trim().isEmpty || !state.canAddPriority) return false;

    final newPriority = FocusPriority.create(
      title: title.trim(),
      orderIndex: state.priorities.length,
    );

    await _repository.savePriority(newPriority);
    final updated = await _repository.getPriorities();
    state = state.copyWith(
      priorities: updated,
      activePriorityIndex: state.priorities.isEmpty ? 0 : state.activePriorityIndex,
    );
    return true;
  }

  Future<void> togglePriority(String id) async {
    await _repository.togglePriorityCompletion(id);
    final updated = await _repository.getPriorities();
    state = state.copyWith(priorities: updated);
  }

  Future<void> deletePriority(String id) async {
    await _repository.deletePriority(id);
    final updated = await _repository.getPriorities();
    final newActiveIndex = state.activePriorityIndex >= updated.length
        ? (updated.isEmpty ? 0 : updated.length - 1)
        : state.activePriorityIndex;
    state = state.copyWith(
      priorities: updated,
      activePriorityIndex: newActiveIndex,
    );
  }

  void setActivePriorityIndex(int index) {
    if (index >= 0 && index < state.priorities.length) {
      state = state.copyWith(activePriorityIndex: index);
    }
  }

  Future<void> clearPriorities() async {
    await _repository.clearPriorities();
    state = state.copyWith(priorities: const [], activePriorityIndex: 0);
  }

  // ---------------------------------------------------------------------------
  // Brain Dump Logic
  // ---------------------------------------------------------------------------

  void setBrainDumpInput(String text) {
    state = state.copyWith(brainDumpInput: text);
  }

  Future<void> addBrainDumpItem(String text) async {
    if (text.trim().isEmpty) return;
    final item = BrainDumpItem.create(rawText: text.trim());
    await _repository.addBrainDumpItem(item);
    final updated = await _repository.getBrainDumpItems();
    state = state.copyWith(
      brainDumpItems: updated,
      brainDumpInput: '',
    );
  }

  Future<bool> promoteBrainDumpToPriority(String id) async {
    if (!state.canAddPriority) return false;
    final itemIndex = state.brainDumpItems.indexWhere((b) => b.id == id);
    if (itemIndex < 0) return false;

    final item = state.brainDumpItems[itemIndex];
    final success = await addPriority(item.rawText);
    if (success) {
      await _repository.deleteBrainDumpItem(id);
      final updatedDumps = await _repository.getBrainDumpItems();
      state = state.copyWith(brainDumpItems: updatedDumps);
      return true;
    }
    return false;
  }

  Future<void> toggleParkBrainDump(String id) async {
    await _repository.toggleParkBrainDumpItem(id);
    final updated = await _repository.getBrainDumpItems();
    state = state.copyWith(brainDumpItems: updated);
  }

  Future<void> deleteBrainDumpItem(String id) async {
    await _repository.deleteBrainDumpItem(id);
    final updated = await _repository.getBrainDumpItems();
    state = state.copyWith(brainDumpItems: updated);
  }

  // ---------------------------------------------------------------------------
  // Serene Focus Companion (Timer) Logic
  // ---------------------------------------------------------------------------

  void selectDuration(int minutes) {
    _tickerTimer?.cancel();
    final newSession = FocusSession.create(
      durationMinutes: minutes,
      priorityId: state.activePriority?.id,
      priorityTitle: state.activePriority?.title,
      ambientSoundId: state.session.ambientSoundId,
    );
    state = state.copyWith(
      session: newSession,
      isTimerRunning: false,
    );
  }

  void selectAmbientSound(String? soundId) {
    state = state.copyWith(
      session: state.session.copyWith(ambientSoundId: soundId),
    );
  }

  void toggleTimer() {
    if (state.isTimerRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    if (state.session.remainingSeconds <= 0) {
      selectDuration(state.session.durationMinutes);
    }
    _tickerTimer?.cancel();
    state = state.copyWith(
      isTimerRunning: true,
      session: state.session.copyWith(isPaused: false),
    );
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.session.remainingSeconds > 1) {
        state = state.copyWith(
          session: state.session.copyWith(
            remainingSeconds: state.session.remainingSeconds - 1,
          ),
        );
      } else {
        _completeTimer();
      }
    });
  }

  void pauseTimer() {
    _tickerTimer?.cancel();
    state = state.copyWith(
      isTimerRunning: false,
      session: state.session.copyWith(isPaused: true),
    );
  }

  void resetTimer() {
    _tickerTimer?.cancel();
    state = state.copyWith(
      isTimerRunning: false,
      session: FocusSession.create(
        durationMinutes: state.session.durationMinutes,
        priorityId: state.activePriority?.id,
        priorityTitle: state.activePriority?.title,
        ambientSoundId: state.session.ambientSoundId,
      ),
    );
  }

  void _completeTimer() {
    _tickerTimer?.cancel();
    final completed = state.session.copyWith(
      remainingSeconds: 0,
      isCompleted: true,
      isPaused: false,
      completedAt: DateTime.now(),
    );
    _repository.saveSession(completed);
    state = state.copyWith(
      isTimerRunning: false,
      session: completed,
    );
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    super.dispose();
  }
}

/// Riverpod provider for [FocusNotifier].
final focusNotifierProvider =
    StateNotifierProvider<FocusNotifier, FocusState>((ref) {
  final repository = ref.watch(focusRepositoryProvider);
  return FocusNotifier(repository);
});
