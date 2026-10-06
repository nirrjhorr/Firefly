import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/reset_repository_impl.dart';
import '../../domain/models/reset_distress_anchor.dart';
import '../../domain/models/reset_phase.dart';
import '../../domain/models/reset_session.dart';
import '../../domain/repositories/reset_repository.dart';

/// Provider for [ResetRepository].
final resetRepositoryProvider = Provider<ResetRepository>((ref) {
  return ResetRepositoryImpl();
});

/// Riverpod StateNotifier controlling the 5-step One-Session Reset journey.
class ResetSessionNotifier extends StateNotifier<ResetSession> {
  ResetSessionNotifier(this._repository) : super(ResetSession.create());

  final ResetRepository _repository;

  void selectAnchor(ResetDistressAnchor anchor) {
    state = state.copyWith(
      anchor: anchor,
      selectedTechnique: anchor.suggestedTechniqueName,
    );
  }

  void nextPhase() {
    switch (state.currentPhase) {
      case ResetPhase.anchor:
        if (state.anchor == null) {
          selectAnchor(ResetDistressAnchor.generalDistress);
        }
        state = state.copyWith(currentPhase: ResetPhase.regulate);
        break;
      case ResetPhase.regulate:
        state = state.copyWith(currentPhase: ResetPhase.reframe);
        break;
      case ResetPhase.reframe:
        state = state.copyWith(currentPhase: ResetPhase.commit);
        break;
      case ResetPhase.commit:
        state = state.copyWith(currentPhase: ResetPhase.complete);
        break;
      case ResetPhase.complete:
        break;
    }
  }

  void previousPhase() {
    switch (state.currentPhase) {
      case ResetPhase.anchor:
        break;
      case ResetPhase.regulate:
        state = state.copyWith(currentPhase: ResetPhase.anchor);
        break;
      case ResetPhase.reframe:
        state = state.copyWith(currentPhase: ResetPhase.regulate);
        break;
      case ResetPhase.commit:
        state = state.copyWith(currentPhase: ResetPhase.reframe);
        break;
      case ResetPhase.complete:
        state = state.copyWith(currentPhase: ResetPhase.commit);
        break;
    }
  }

  void setReframe(String reflection) {
    state = state.copyWith(reframeReflection: reflection);
  }

  void setCommitment(String commitment) {
    state = state.copyWith(microCommitment: commitment);
  }

  Future<void> completeSession(String effectivenessRating) async {
    final completed = state.copyWith(
      effectivenessRating: effectivenessRating,
      completedAt: DateTime.now(),
      currentPhase: ResetPhase.complete,
    );
    state = completed;
    await _repository.saveResetSession(completed);
  }

  void restart() {
    state = ResetSession.create();
  }
}

/// Provider managing active One-Session Reset state.
final resetSessionProvider =
    StateNotifierProvider<ResetSessionNotifier, ResetSession>((ref) {
  final repo = ref.watch(resetRepositoryProvider);
  return ResetSessionNotifier(repo);
});
