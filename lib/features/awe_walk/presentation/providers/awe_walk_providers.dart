import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/awe_walk_repository_impl.dart';
import '../../domain/models/awe_prompt.dart';
import '../../domain/models/awe_walk_phase.dart';
import '../../domain/models/awe_walk_session.dart';
import '../../domain/repositories/awe_walk_repository.dart';

/// Provider for [AweWalkRepository].
final aweWalkRepositoryProvider = Provider<AweWalkRepository>((ref) {
  return AweWalkRepositoryImpl();
});

/// Riverpod StateNotifier controlling the Awe Walk session lifecycle.
class AweWalkNotifier extends StateNotifier<AweWalkSession> {
  AweWalkNotifier(this._repository) : super(AweWalkSession.create());

  final AweWalkRepository _repository;
  Timer? _timer;

  List<AwePrompt> get prompts => _repository.getCuratedPrompts();

  AwePrompt get currentPrompt {
    final list = prompts;
    if (list.isEmpty) {
      return AwePrompt.curatedPrompts.first;
    }
    final index = state.activePromptIndex.clamp(0, list.length - 1);
    return list[index];
  }

  void setDuration(int minutes) {
    if (state.elapsedSeconds == 0) {
      state = state.copyWith(targetDurationMinutes: minutes);
    }
  }

  void startTimer() {
    _timer?.cancel();
    state = state.copyWith(isPaused: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isPaused) {
        final newElapsed = state.elapsedSeconds + 1;
        state = state.copyWith(elapsedSeconds: newElapsed);
        if (state.totalTargetSeconds > 0 &&
            newElapsed >= state.totalTargetSeconds &&
            state.currentPhase != AweWalkPhase.complete &&
            state.currentPhase != AweWalkPhase.gratitude) {
          // Transition smoothly to sensory anchor
          state = state.copyWith(currentPhase: AweWalkPhase.gratitude);
        }
      }
    });
  }

  void pauseTimer() {
    state = state.copyWith(isPaused: true);
  }

  void resumeTimer() {
    state = state.copyWith(isPaused: false);
  }

  void togglePause() {
    if (state.isPaused) {
      resumeTimer();
    } else {
      pauseTimer();
    }
  }

  void nextPhase() {
    switch (state.currentPhase) {
      case AweWalkPhase.preparation:
        state = state.copyWith(currentPhase: AweWalkPhase.vastness);
        if (_timer == null || !_timer!.isActive) {
          startTimer();
        }
        break;
      case AweWalkPhase.vastness:
        state = state.copyWith(currentPhase: AweWalkPhase.smallSelf);
        break;
      case AweWalkPhase.smallSelf:
        state = state.copyWith(currentPhase: AweWalkPhase.gratitude);
        break;
      case AweWalkPhase.gratitude:
        completeWalk();
        break;
      case AweWalkPhase.complete:
        break;
    }
  }

  void previousPhase() {
    switch (state.currentPhase) {
      case AweWalkPhase.preparation:
        break;
      case AweWalkPhase.vastness:
        state = state.copyWith(currentPhase: AweWalkPhase.preparation);
        break;
      case AweWalkPhase.smallSelf:
        state = state.copyWith(currentPhase: AweWalkPhase.vastness);
        break;
      case AweWalkPhase.gratitude:
        state = state.copyWith(currentPhase: AweWalkPhase.smallSelf);
        break;
      case AweWalkPhase.complete:
        state = state.copyWith(currentPhase: AweWalkPhase.gratitude);
        break;
    }
  }

  void nextPrompt() {
    final list = prompts;
    if (state.activePromptIndex < list.length - 1) {
      state = state.copyWith(activePromptIndex: state.activePromptIndex + 1);
    }
  }

  void previousPrompt() {
    if (state.activePromptIndex > 0) {
      state = state.copyWith(activePromptIndex: state.activePromptIndex - 1);
    }
  }

  void markCurrentPromptComplete() {
    final promptId = currentPrompt.id;
    if (!state.completedPromptIds.contains(promptId)) {
      final updated = List<String>.from(state.completedPromptIds)..add(promptId);
      state = state.copyWith(completedPromptIds: updated);
    }
  }

  void setAnchorDetail(String detail) {
    state = state.copyWith(anchorDetail: detail);
  }

  void setRatingShift(int shift) {
    state = state.copyWith(ratingShift: shift);
  }

  Future<void> completeWalk() async {
    _timer?.cancel();
    final completed = state.copyWith(
      currentPhase: AweWalkPhase.complete,
      completedAt: DateTime.now(),
      isPaused: true,
    );
    state = completed;
    await _repository.saveSession(completed);
  }

  void resetSession({int durationMinutes = 10}) {
    _timer?.cancel();
    state = AweWalkSession.create(durationMinutes: durationMinutes);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provider managing active Awe Walk session.
final aweWalkSessionProvider =
    StateNotifierProvider.autoDispose<AweWalkNotifier, AweWalkSession>((ref) {
  final repo = ref.watch(aweWalkRepositoryProvider);
  return AweWalkNotifier(repo);
});
