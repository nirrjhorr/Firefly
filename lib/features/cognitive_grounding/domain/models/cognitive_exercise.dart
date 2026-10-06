/// Types of non-clinical cognitive working memory interruption exercises.
enum CognitiveExerciseType {
  alphabetCategories,
  backwardCounting,
  wordAssociation,
  memorySequence;

  String get displayName {
    switch (this) {
      case CognitiveExerciseType.alphabetCategories:
        return 'Alphabet Categories';
      case CognitiveExerciseType.backwardCounting:
        return 'Backward Counting';
      case CognitiveExerciseType.wordAssociation:
        return 'Word Associations';
      case CognitiveExerciseType.memorySequence:
        return 'Calm Sequence';
    }
  }

  String get description {
    switch (this) {
      case CognitiveExerciseType.alphabetCategories:
        return 'Find a word for each letter to gently redirect racing thoughts.';
      case CognitiveExerciseType.backwardCounting:
        return 'Step backward through numbers to occupy working memory.';
      case CognitiveExerciseType.wordAssociation:
        return 'Follow a tranquil chain of related words at your own pace.';
      case CognitiveExerciseType.memorySequence:
        return 'Hold a brief soothing pattern in mind without time limits.';
    }
  }

  String get iconKey {
    switch (this) {
      case CognitiveExerciseType.alphabetCategories:
        return 'textformat.abc';
      case CognitiveExerciseType.backwardCounting:
        return 'number';
      case CognitiveExerciseType.wordAssociation:
        return 'link';
      case CognitiveExerciseType.memorySequence:
        return 'sparkles';
    }
  }

  static CognitiveExerciseType fromString(String value) {
    return CognitiveExerciseType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => CognitiveExerciseType.alphabetCategories,
    );
  }
}

/// Offline curated categories for the Alphabet Categories exercise.
class CategoryPrompt {
  const CategoryPrompt({
    required this.id,
    required this.name,
    required this.hint,
  });

  final String id;
  final String name;
  final String hint;
}

const List<CategoryPrompt> kOfflineCognitiveCategories = [
  CategoryPrompt(
    id: 'animals',
    name: 'Animals & Creatures',
    hint: 'Think of any animal starting with this letter',
  ),
  CategoryPrompt(
    id: 'calming_things',
    name: 'Soothing Things',
    hint: 'Think of something comforting or peaceful',
  ),
  CategoryPrompt(
    id: 'foods',
    name: 'Foods & Drinks',
    hint: 'Think of a fruit, meal, or comfort food',
  ),
  CategoryPrompt(
    id: 'nature',
    name: 'Nature & Landscape',
    hint: 'Think of trees, weather, geography, or plants',
  ),
  CategoryPrompt(
    id: 'cities_places',
    name: 'Cities & Places',
    hint: 'Think of a city, town, country, or quiet spot',
  ),
];

/// Configuration for backward counting steps.
class CountingConfig {
  const CountingConfig({
    required this.startNumber,
    required this.stepDown,
    required this.name,
  });

  final int startNumber;
  final int stepDown;
  final String name;
}

const List<CountingConfig> kCountingConfigs = [
  CountingConfig(startNumber: 100, stepDown: 7, name: 'From 100 by 7s (Medium focus)'),
  CountingConfig(startNumber: 50, stepDown: 3, name: 'From 50 by 3s (Gentle focus)'),
  CountingConfig(startNumber: 30, stepDown: 2, name: 'From 30 by 2s (Soft focus)'),
];

/// Curated calming word association stems.
const List<List<String>> kWordAssociationChains = [
  ['Ocean', 'Breeze', 'Warmth', 'Sunlight', 'Coast', 'Horizon', 'Peace'],
  ['Forest', 'Pine', 'Moss', 'Raindrop', 'Cedar', 'Stream', 'Stillness'],
  ['Library', 'Paper', 'Teacup', 'Rain on glass', 'Blanket', 'Quiet', 'Shelter'],
  ['Mountain', 'Dawn', 'Clear sky', 'Crisp air', 'Solitude', 'Stones', 'Sanctuary'],
];
