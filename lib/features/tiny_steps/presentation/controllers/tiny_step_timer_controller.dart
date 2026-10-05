import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/tiny_step.dart';
import '../../domain/data/curated_tiny_steps.dart';

@immutable
class TinyStepTimerState {
  const TinyStepTimerState({
    required this.step,
    this.elapsed = Duration.zero,
    this.isRunning = false,
  });

  final TinyStep step;
  final Duration elapsed;
  final bool isRunning;

  bool get isTargetReached {
    final target = step.targetDuration;
    if (target == null) return false;
    return elapsed >= target;
  }

  Duration? get remaining {
    final target = step.targetDuration;
    if (target == null) return null;
    final diff = target - elapsed;
    return diff.isNegative ? Duration.zero : diff;
  }

  TinyStepTimerState copyWith({
    TinyStep? step,
    Duration? elapsed,
    bool? isRunning,
  }) {
    return TinyStepTimerState(
      step: step ?? this.step,
      elapsed: elapsed ?? this.elapsed,
      isRunning: isRunning ?? this.isRunning,
    );
  }
}

class TinyStepTimerController extends StateNotifier<TinyStepTimerState> {
  TinyStepTimerController(TinyStep step)
    : super(TinyStepTimerState(step: step));

  Timer? _timer;
  DateTime? _lastTick;

  void start() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _lastTick = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 100), _onTick);
  }

  void pause() {
    if (!state.isRunning) return;
    _timer?.cancel();
    _timer = null;
    _updateElapsed();
    state = state.copyWith(isRunning: false);
  }

  void _onTick(Timer timer) {
    _updateElapsed();
  }

  void _updateElapsed() {
    if (!state.isRunning || _lastTick == null) return;
    final now = DateTime.now();
    final diff = now.difference(_lastTick!);
    _lastTick = now;
    state = state.copyWith(elapsed: state.elapsed + diff);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final tinyStepTimerControllerProvider = StateNotifierProvider.family
    .autoDispose<TinyStepTimerController, TinyStepTimerState, String>((
      ref,
      stepId,
    ) {
      final step = TinyStepsCatalog.getStepById(stepId);
      if (step == null) throw Exception('Tiny step not found');
      return TinyStepTimerController(step);
    });
