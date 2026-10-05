import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../check_in/domain/repositories/check_in_repository.dart';
import '../../../check_in/presentation/controllers/check_in_controller.dart';
import '../../domain/data/curated_tiny_steps.dart';
import '../../domain/models/tiny_step.dart';

@immutable
class TinyStepsState {
  const TinyStepsState({
    this.candidates = const [],
    this.energyLevel = 2,
    this.completedStepId,
    this.actualDuration,
    this.isLoading = false,
  });

  final List<TinyStep> candidates;
  final int energyLevel;
  final String? completedStepId;
  final Duration? actualDuration;
  final bool isLoading;

  bool get hasCompleted => completedStepId != null;

  TinyStep? get completedStep {
    if (completedStepId == null) return null;
    try {
      return candidates.firstWhere((step) => step.id == completedStepId);
    } catch (_) {
      return TinyStepsCatalog.getStepById(completedStepId!);
    }
  }

  TinyStepsState copyWith({
    List<TinyStep>? candidates,
    int? energyLevel,
    String? completedStepId,
    Duration? actualDuration,
    bool? isLoading,
    bool clearCompleted = false,
  }) {
    return TinyStepsState(
      candidates: candidates ?? this.candidates,
      energyLevel: energyLevel ?? this.energyLevel,
      completedStepId: clearCompleted
          ? null
          : (completedStepId ?? this.completedStepId),
      actualDuration: clearCompleted
          ? null
          : (actualDuration ?? this.actualDuration),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TinyStepsState &&
          runtimeType == other.runtimeType &&
          listEquals(candidates, other.candidates) &&
          energyLevel == other.energyLevel &&
          completedStepId == other.completedStepId &&
          actualDuration == other.actualDuration &&
          isLoading == other.isLoading;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(candidates),
    energyLevel,
    completedStepId,
    actualDuration,
    isLoading,
  );
}

class TinyStepsController extends StateNotifier<TinyStepsState> {
  TinyStepsController({
    this.checkInRepository,
    Random? random,
    int defaultEnergy = 2,
  }) : _random = random ?? Random(),
       super(TinyStepsState(energyLevel: defaultEnergy, isLoading: true)) {
    _init(defaultEnergy);
  }

  final CheckInRepository? checkInRepository;
  final Random _random;

  Future<void> _init(int fallbackEnergy) async {
    int effectiveEnergy = fallbackEnergy;

    if (checkInRepository != null) {
      try {
        final result = await checkInRepository!.getLatestCheckIn();
        if (result is Ok) {
          final entry = (result as Ok).value;
          if (entry != null &&
              entry.energyLevel >= 1 &&
              entry.energyLevel <= 5) {
            effectiveEnergy = entry.energyLevel;
          }
        }
      } catch (_) {
        // Fall back gracefully to fallbackEnergy on any repository issue
      }
    }

    final initialCandidates = _selectCandidates(effectiveEnergy);
    state = state.copyWith(
      candidates: initialCandidates,
      energyLevel: effectiveEnergy,
      isLoading: false,
    );
  }

  /// Select 3 distinct micro-actions matching the provided energy level.
  List<TinyStep> _selectCandidates(int energy, {List<TinyStep>? exclude}) {
    final matching = TinyStepsCatalog.getStepsForEnergy(energy);
    final pool = List<TinyStep>.from(
      matching.isNotEmpty ? matching : TinyStepsCatalog.allSteps,
    );

    // If we have exclusion and enough pool items, prefer items not currently shown
    if (exclude != null && exclude.isNotEmpty && pool.length > 3) {
      final excludedIds = exclude.map((e) => e.id).toSet();
      final filteredPool = pool
          .where((item) => !excludedIds.contains(item.id))
          .toList();
      if (filteredPool.length >= 3) {
        filteredPool.shuffle(_random);
        return filteredPool.take(3).toList();
      }
    }

    pool.shuffle(_random);
    return pool.take(3).toList();
  }

  /// Shuffles candidates to present 3 alternative options for the current energy level.
  void shuffle() {
    final newCandidates = _selectCandidates(
      state.energyLevel,
      exclude: state.candidates,
    );
    state = state.copyWith(candidates: newCandidates, clearCompleted: true);
  }

  /// Updates energy level filter and refreshes candidates.
  void setEnergyLevel(int energy) {
    final clampedEnergy = energy.clamp(1, 5);
    final newCandidates = _selectCandidates(clampedEnergy);
    state = state.copyWith(
      energyLevel: clampedEnergy,
      candidates: newCandidates,
      clearCompleted: true,
    );
  }

  /// Marks a tiny step as completed.
  void completeStep(String stepId, Duration actualDuration) {
    state = state.copyWith(
      completedStepId: stepId,
      actualDuration: actualDuration,
    );
  }

  /// Resets completion to allow doing another step.
  void resetCompleted() {
    state = state.copyWith(clearCompleted: true);
  }
}

final tinyStepsControllerProvider =
    StateNotifierProvider.autoDispose<TinyStepsController, TinyStepsState>((
      ref,
    ) {
      final checkInRepo = ref.watch(checkInRepositoryProvider);
      return TinyStepsController(checkInRepository: checkInRepo);
    });
