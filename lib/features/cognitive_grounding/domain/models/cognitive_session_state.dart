import 'cognitive_exercise.dart';

/// Immutable session state for cognitive grounding.
class CognitiveSessionState {
  const CognitiveSessionState({
    required this.exerciseType,
    this.currentLetterIndex = 0,
    this.activeCategoryIndex = 0,
    this.currentCount = 100,
    this.activeCountingConfigIndex = 0,
    this.activeChainIndex = 0,
    this.activeChainStep = 0,
    this.completedSteps = 0,
    this.isCompleted = false,
  });

  final CognitiveExerciseType exerciseType;
  final int currentLetterIndex;
  final int activeCategoryIndex;
  final int currentCount;
  final int activeCountingConfigIndex;
  final int activeChainIndex;
  final int activeChainStep;
  final int completedSteps;
  final bool isCompleted;

  String get currentLetter {
    if (currentLetterIndex < 0 || currentLetterIndex >= 26) return 'A';
    return String.fromCharCode(65 + currentLetterIndex);
  }

  CategoryPrompt get activeCategory {
    final idx = activeCategoryIndex % kOfflineCognitiveCategories.length;
    return kOfflineCognitiveCategories[idx];
  }

  CountingConfig get activeCountingConfig {
    final idx = activeCountingConfigIndex % kCountingConfigs.length;
    return kCountingConfigs[idx];
  }

  List<String> get activeChain {
    final idx = activeChainIndex % kWordAssociationChains.length;
    return kWordAssociationChains[idx];
  }

  String get currentWord {
    final chain = activeChain;
    if (activeChainStep < 0 || activeChainStep >= chain.length) {
      return chain.first;
    }
    return chain[activeChainStep];
  }

  double get progressFraction {
    switch (exerciseType) {
      case CognitiveExerciseType.alphabetCategories:
        return (currentLetterIndex / 26.0).clamp(0.0, 1.0);
      case CognitiveExerciseType.backwardCounting:
        final start = activeCountingConfig.startNumber;
        final remaining = currentCount.clamp(0, start);
        return ((start - remaining) / start).clamp(0.0, 1.0);
      case CognitiveExerciseType.wordAssociation:
        return (activeChainStep / activeChain.length).clamp(0.0, 1.0);
      case CognitiveExerciseType.memorySequence:
        return (completedSteps / 5.0).clamp(0.0, 1.0);
    }
  }

  CognitiveSessionState copyWith({
    CognitiveExerciseType? exerciseType,
    int? currentLetterIndex,
    int? activeCategoryIndex,
    int? currentCount,
    int? activeCountingConfigIndex,
    int? activeChainIndex,
    int? activeChainStep,
    int? completedSteps,
    bool? isCompleted,
  }) {
    return CognitiveSessionState(
      exerciseType: exerciseType ?? this.exerciseType,
      currentLetterIndex: currentLetterIndex ?? this.currentLetterIndex,
      activeCategoryIndex: activeCategoryIndex ?? this.activeCategoryIndex,
      currentCount: currentCount ?? this.currentCount,
      activeCountingConfigIndex: activeCountingConfigIndex ?? this.activeCountingConfigIndex,
      activeChainIndex: activeChainIndex ?? this.activeChainIndex,
      activeChainStep: activeChainStep ?? this.activeChainStep,
      completedSteps: completedSteps ?? this.completedSteps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
