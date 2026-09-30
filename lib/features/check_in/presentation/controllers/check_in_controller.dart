import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/recommendation_engine/models/action_suggestion.dart';
import '../../../../core/recommendation_engine/models/affect_state.dart';
import '../../../../core/recommendation_engine/recommendation_engine.dart';
import '../../../../shared/widgets/mood_tile.dart';
import '../../data/repositories/check_in_repository_impl.dart';
import '../../domain/models/check_in_entry.dart';
import '../../domain/repositories/check_in_repository.dart';

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  return CheckInRepositoryImpl();
});

class CheckInState {
  const CheckInState({
    this.selectedMood = MoodCategory.here,
    this.energyLevel = 3,
    this.anxietyLevel = 2,
    this.lonelinessLevel = 2,
    this.isSubmitting = false,
    this.lastSubmittedEntry,
    this.activeSuggestion,
    this.errorMessage,
  });

  final MoodCategory selectedMood;
  final int energyLevel;
  final int anxietyLevel;
  final int lonelinessLevel;
  final bool isSubmitting;
  final CheckInEntry? lastSubmittedEntry;
  final ActionSuggestion? activeSuggestion;
  final String? errorMessage;

  CheckInState copyWith({
    MoodCategory? selectedMood,
    int? energyLevel,
    int? anxietyLevel,
    int? lonelinessLevel,
    bool? isSubmitting,
    CheckInEntry? lastSubmittedEntry,
    ActionSuggestion? activeSuggestion,
    String? errorMessage,
  }) {
    return CheckInState(
      selectedMood: selectedMood ?? this.selectedMood,
      energyLevel: energyLevel ?? this.energyLevel,
      anxietyLevel: anxietyLevel ?? this.anxietyLevel,
      lonelinessLevel: lonelinessLevel ?? this.lonelinessLevel,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      lastSubmittedEntry: lastSubmittedEntry ?? this.lastSubmittedEntry,
      activeSuggestion: activeSuggestion ?? this.activeSuggestion,
      errorMessage: errorMessage,
    );
  }
}

class CheckInController extends StateNotifier<CheckInState> {
  CheckInController(this._repository) : super(const CheckInState()) {
    _loadLatest();
  }

  final CheckInRepository _repository;

  Future<void> _loadLatest() async {
    final result = await _repository.getLatestCheckIn();
    if (result is Ok<CheckInEntry?, Exception> && result.value != null) {
      final entry = result.value!;
      state = state.copyWith(
        lastSubmittedEntry: entry,
        activeSuggestion: entry.suggestedAction,
      );
    }
  }

  void setMood(MoodCategory mood) {
    state = state.copyWith(selectedMood: mood);
  }

  void setEnergy(int energy) {
    state = state.copyWith(energyLevel: energy);
  }

  void setAnxiety(int anxiety) {
    state = state.copyWith(anxietyLevel: anxiety);
  }

  void setLoneliness(int loneliness) {
    state = state.copyWith(lonelinessLevel: loneliness);
  }

  Future<ActionSuggestion> submitCheckIn() async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final affectState = AffectState(
      moodCategory: state.selectedMood.name,
      energyLevel: state.energyLevel,
      anxietyLevel: state.anxietyLevel,
      lonelinessLevel: state.lonelinessLevel,
    );

    final suggestion = RecommendationEngine.evaluate(affectState);
    final nowUnix = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final entry = CheckInEntry(
      id: 'checkin-${DateTime.now().millisecondsSinceEpoch}',
      moodCategory: state.selectedMood.name,
      energyLevel: state.energyLevel,
      anxietyLevel: state.anxietyLevel,
      lonelinessLevel: state.lonelinessLevel,
      suggestedAction: suggestion,
      createdAtUnix: nowUnix,
      updatedAtUnix: nowUnix,
    );

    final result = await _repository.saveCheckIn(entry);
    switch (result) {
      case Ok():
        state = state.copyWith(
          isSubmitting: false,
          lastSubmittedEntry: entry,
          activeSuggestion: suggestion,
        );
      case Err(error: final err):
        state = state.copyWith(
          isSubmitting: false,
          activeSuggestion: suggestion,
          errorMessage: err.toString(),
        );
    }

    return suggestion;
  }

  void resetForNewCheckIn() {
    state = state.copyWith(
      activeSuggestion: null,
      selectedMood: MoodCategory.here,
      energyLevel: 3,
      anxietyLevel: 2,
      lonelinessLevel: 2,
      errorMessage: null,
    );
  }
}

final checkInControllerProvider =
    StateNotifierProvider<CheckInController, CheckInState>((ref) {
  final repository = ref.watch(checkInRepositoryProvider);
  return CheckInController(repository);
});
