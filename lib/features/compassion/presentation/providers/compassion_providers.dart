import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/compassion_repository_impl.dart';
import '../../domain/models/compassion_exercise_type.dart';
import '../../domain/models/compassion_session.dart';
import '../../domain/models/self_compassion_component.dart';
import '../../domain/models/untangled_thought.dart';
import '../../domain/repositories/compassion_repository.dart';

/// Provider for [CompassionRepository].
final compassionRepositoryProvider = Provider<CompassionRepository>((ref) {
  return CompassionRepositoryImpl();
});

/// Immutable UI state for Self-Compassion exercises.
class CompassionState {
  const CompassionState({
    required this.exerciseType,
    required this.currentStep,
    required this.session,
    this.selectedComponent = SelfCompassionComponent.mindfulness,
    this.triggerInput = '',
    this.criticInput = '',
    this.reframeInput = '',
    this.isCompleted = false,
  });

  factory CompassionState.initial({
    CompassionExerciseType exerciseType =
        CompassionExerciseType.selfCompassionBreak,
  }) {
    return CompassionState(
      exerciseType: exerciseType,
      currentStep: 0,
      session: CompassionSession.create(exerciseType: exerciseType),
      selectedComponent: SelfCompassionComponent.mindfulness,
    );
  }

  final CompassionExerciseType exerciseType;
  final int currentStep;
  final CompassionSession session;
  final SelfCompassionComponent selectedComponent;
  final String triggerInput;
  final String criticInput;
  final String reframeInput;
  final bool isCompleted;

  int get totalSteps => 3;

  bool get isLastStep => currentStep >= totalSteps - 1;
  bool get hasPreviousStep => currentStep > 0 && !isCompleted;

  CompassionState copyWith({
    CompassionExerciseType? exerciseType,
    int? currentStep,
    CompassionSession? session,
    SelfCompassionComponent? selectedComponent,
    String? triggerInput,
    String? criticInput,
    String? reframeInput,
    bool? isCompleted,
  }) {
    return CompassionState(
      exerciseType: exerciseType ?? this.exerciseType,
      currentStep: currentStep ?? this.currentStep,
      session: session ?? this.session,
      selectedComponent: selectedComponent ?? this.selectedComponent,
      triggerInput: triggerInput ?? this.triggerInput,
      criticInput: criticInput ?? this.criticInput,
      reframeInput: reframeInput ?? this.reframeInput,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Controller managing the Self-Compassion and Thought Untangler flow.
class CompassionNotifier extends StateNotifier<CompassionState> {
  CompassionNotifier(this._repository) : super(CompassionState.initial());

  final CompassionRepository _repository;

  void selectExercise(CompassionExerciseType type) {
    state = CompassionState.initial(exerciseType: type);
  }

  void nextStep() {
    if (state.isLastStep) {
      completeSession();
      return;
    }

    final nextIndex = state.currentStep + 1;
    SelfCompassionComponent component;
    if (nextIndex == 1) {
      component = SelfCompassionComponent.commonHumanity;
    } else if (nextIndex == 2) {
      component = SelfCompassionComponent.selfKindness;
    } else {
      component = SelfCompassionComponent.mindfulness;
    }

    state = state.copyWith(
      currentStep: nextIndex,
      selectedComponent: component,
    );
  }

  void previousStep() {
    if (!state.hasPreviousStep) return;
    final prevIndex = state.currentStep - 1;
    SelfCompassionComponent component;
    if (prevIndex == 1) {
      component = SelfCompassionComponent.commonHumanity;
    } else if (prevIndex == 2) {
      component = SelfCompassionComponent.selfKindness;
    } else {
      component = SelfCompassionComponent.mindfulness;
    }

    state = state.copyWith(
      currentStep: prevIndex,
      selectedComponent: component,
    );
  }

  void updateTriggerInput(String text) {
    state = state.copyWith(triggerInput: text);
  }

  void updateCriticInput(String text) {
    state = state.copyWith(criticInput: text);
  }

  void updateReframeInput(String text) {
    state = state.copyWith(reframeInput: text);
  }

  void setPreDistress(int rating) {
    state = state.copyWith(
      session: state.session.copyWith(preDistressRating: rating),
    );
  }

  void setPostDistress(int rating) {
    state = state.copyWith(
      session: state.session.copyWith(postDistressRating: rating),
    );
  }

  Future<void> completeSession() async {
    UntangledThought? thought;
    if (state.exerciseType == CompassionExerciseType.thoughtUntangler &&
        (state.criticInput.isNotEmpty || state.reframeInput.isNotEmpty)) {
      thought = UntangledThought.create(
        triggerContext: state.triggerInput,
        harshCriticVoice: state.criticInput,
        commonHumanityPerspective:
            'Difficulty is shared by countless humans. I am not uniquely flawed.',
        compassionateFriendReframe: state.reframeInput,
      );
      await _repository.saveUntangledThought(thought);
    }

    final completedSession = state.session.copyWith(
      completedAt: DateTime.now(),
      untangledThought: thought,
    );

    await _repository.saveSession(completedSession);

    state = state.copyWith(
      isCompleted: true,
      session: completedSession,
    );
  }

  void reset() {
    state = CompassionState.initial(exerciseType: state.exerciseType);
  }
}

/// Riverpod controller provider.
final compassionNotifierProvider =
    StateNotifierProvider<CompassionNotifier, CompassionState>((ref) {
  final repo = ref.watch(compassionRepositoryProvider);
  return CompassionNotifier(repo);
});
