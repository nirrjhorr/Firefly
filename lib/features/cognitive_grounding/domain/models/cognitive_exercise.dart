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
    hint: 'Think of any animal, bird, or sea creature starting with this letter',
  ),
  CategoryPrompt(
    id: 'calming_things',
    name: 'Soothing Things',
    hint: 'Think of something comforting, cozy, or peaceful',
  ),
  CategoryPrompt(
    id: 'foods',
    name: 'Foods & Comfort Meals',
    hint: 'Think of a gentle meal, fruit, or comforting snack',
  ),
  CategoryPrompt(
    id: 'nature',
    name: 'Nature & Landscapes',
    hint: 'Think of trees, weather, landforms, or natural wonders',
  ),
  CategoryPrompt(
    id: 'cities_places',
    name: 'Quiet Cities & Places',
    hint: 'Think of a tranquil city, town, country, or sanctuary',
  ),
  CategoryPrompt(
    id: 'trees_plants',
    name: 'Trees & Living Plants',
    hint: 'Think of a tree species, houseplant, or woodland shrub',
  ),
  CategoryPrompt(
    id: 'colors_shades',
    name: 'Colors & Hues',
    hint: 'Think of an earthy tone, pastel shade, or tranquil pigment',
  ),
  CategoryPrompt(
    id: 'textures',
    name: 'Tactile Textures',
    hint: 'Think of a comforting fabric, surface, or physical feel',
  ),
  CategoryPrompt(
    id: 'books_stories',
    name: 'Stories & Tales',
    hint: 'Think of a gentle book, folk tale, or literary world',
  ),
  CategoryPrompt(
    id: 'music_sounds',
    name: 'Music & Acoustic Sounds',
    hint: 'Think of an instrument, acoustic timbre, or natural sound',
  ),
  CategoryPrompt(
    id: 'weather_sky',
    name: 'Sky & Atmospheric Weather',
    hint: 'Think of a cloud formation, breeze, celestial body, or mist',
  ),
  CategoryPrompt(
    id: 'scents_aromas',
    name: 'Scents & Aromas',
    hint: 'Think of a natural scent, spice, baked aroma, or essential oil',
  ),
  CategoryPrompt(
    id: 'household_comforts',
    name: 'Household Comforts',
    hint: 'Think of an object in a home that brings warmth and ease',
  ),
  CategoryPrompt(
    id: 'seasons_times',
    name: 'Seasons & Moments of Day',
    hint: 'Think of a time of day, season, or quiet annual moment',
  ),
  CategoryPrompt(
    id: 'ocean_waters',
    name: 'Ocean & Still Waters',
    hint: 'Think of a tide, bay, stream, sea creature, or pebble shore',
  ),
  CategoryPrompt(
    id: 'garden_flowers',
    name: 'Garden Flowers & Blooms',
    hint: 'Think of a flower, petal color, or garden blossom',
  ),
  CategoryPrompt(
    id: 'hobbies_crafts',
    name: 'Peaceful Hobbies & Crafts',
    hint: 'Think of an unhurried craft, gentle hobby, or pastime',
  ),
  CategoryPrompt(
    id: 'calming_words',
    name: 'Calming Words & Concepts',
    hint: 'Think of a word that evokes serenity, warmth, or clarity',
  ),
  CategoryPrompt(
    id: 'gentle_actions',
    name: 'Gentle Physical Actions',
    hint: 'Think of a soft motion, relaxing movement, or physical release',
  ),
  CategoryPrompt(
    id: 'astronomy_night',
    name: 'Night Sky & Astronomy',
    hint: 'Think of a star, constellation, planet, or nocturnal wonder',
  ),
  CategoryPrompt(
    id: 'birds_song',
    name: 'Birds of Song & Flight',
    hint: 'Think of a songbird, wetland bird, or woodland glider',
  ),
  CategoryPrompt(
    id: 'fruits_berries',
    name: 'Fruits & Orchard Berries',
    hint: 'Think of a ripe orchard fruit, wild berry, or citrus',
  ),
  CategoryPrompt(
    id: 'vegetables_herbs',
    name: 'Garden Herbs & Greens',
    hint: 'Think of a fragrant kitchen herb or nourishing vegetable',
  ),
  CategoryPrompt(
    id: 'warm_drinks',
    name: 'Warm & Soothing Drinks',
    hint: 'Think of a herbal infusion, warm milk, spiced tea, or brew',
  ),
  CategoryPrompt(
    id: 'fabrics_clothing',
    name: 'Soft Fabrics & Garments',
    hint: 'Think of a soft textile, knitwear piece, or cozy blanket',
  ),
  CategoryPrompt(
    id: 'quiet_shelters',
    name: 'Quiet Shelters & Nooks',
    hint: 'Think of an architectural shelter, gazebo, porch, or cabin',
  ),
  CategoryPrompt(
    id: 'natural_elements',
    name: 'Natural Elements & Stones',
    hint: 'Think of a mineral, smooth river rock, clay, or earth material',
  ),
  CategoryPrompt(
    id: 'peaceful_rooms',
    name: 'Peaceful Spaces & Nooks',
    hint: 'Think of a reading corner, sunlit corridor, or quiet room',
  ),
  CategoryPrompt(
    id: 'childhood_nostalgia',
    name: 'Gentle Childhood Memories',
    hint: 'Think of a classic toy, playground game, or childhood joy',
  ),
  CategoryPrompt(
    id: 'positive_virtues',
    name: 'Gentle Virtues & Qualities',
    hint: 'Think of a compassionate attribute or quiet character strength',
  ),
  CategoryPrompt(
    id: 'slow_travel',
    name: 'Slow Travel & Pathways',
    hint: 'Think of a trail, scenic train line, rowboat, or footpath',
  ),
  CategoryPrompt(
    id: 'island_coastal',
    name: 'Island & Coastal Finds',
    hint: 'Think of driftwood, tide pools, sea glass, or lighthouses',
  ),
  CategoryPrompt(
    id: 'mountain_forest',
    name: 'Mountain Valleys & Woods',
    hint: 'Think of alpine meadows, mossy trails, or fir forest sights',
  ),
  CategoryPrompt(
    id: 'rivers_brooks',
    name: 'Rivers, Brooks & Creeks',
    hint: 'Think of flowing water sounds, river plants, or stepping stones',
  ),
  CategoryPrompt(
    id: 'morning_awakenings',
    name: 'Morning Sights & Glances',
    hint: 'Think of dawn light, morning dew, birdsong, or fresh air',
  ),
  CategoryPrompt(
    id: 'evening_twilight',
    name: 'Evening Twilight & Dusk',
    hint: 'Think of lanterns, sunset colors, stars appearing, or quiet hours',
  ),
  CategoryPrompt(
    id: 'winter_comforts',
    name: 'Winter Comforts & Hearth',
    hint: 'Think of wool socks, snowfall, warm stew, or crackling fire',
  ),
  CategoryPrompt(
    id: 'spring_renewals',
    name: 'Spring Sprouts & Breezes',
    hint: 'Think of green shoots, blossoming cherry trees, or spring rain',
  ),
  CategoryPrompt(
    id: 'summer_dapples',
    name: 'Summer Shade & Stillness',
    hint: 'Think of tree canopy shadows, porch swings, or lake breezes',
  ),
  CategoryPrompt(
    id: 'autumn_harvests',
    name: 'Autumn Leaves & Woods',
    hint: 'Think of golden leaves, harvest pumpkins, or crisp autumn air',
  ),
  CategoryPrompt(
    id: 'bakery_hearth',
    name: 'Breads & Bakery Items',
    hint: 'Think of warm crusts, sourdough loaves, or fresh pastries',
  ),
  CategoryPrompt(
    id: 'art_stationery',
    name: 'Art Supplies & Paper',
    hint: 'Think of watercolors, soft graphite pencils, or journals',
  ),
  CategoryPrompt(
    id: 'musical_tempos',
    name: 'Musical Terms & Tempos',
    hint: 'Think of gentle musical styles, acoustic terms, or lullabies',
  ),
  CategoryPrompt(
    id: 'wildflowers_fields',
    name: 'Wildflowers & Meadows',
    hint: 'Think of clover, poppies, field daisies, or wild grasses',
  ),
  CategoryPrompt(
    id: 'forest_wildlife',
    name: 'Woodland Wildlife',
    hint: 'Think of deer, badgers, hedgehogs, squirrels, or owls',
  ),
  CategoryPrompt(
    id: 'marine_beings',
    name: 'Gentle Marine Creatures',
    hint: 'Think of harbor seals, sea turtles, otters, or gentle rays',
  ),
  CategoryPrompt(
    id: 'comfort_scenes',
    name: 'Serene Sceneries',
    hint: 'Think of a quiet clearing, hidden cove, or valley vista',
  ),
  CategoryPrompt(
    id: 'everyday_micro_joys',
    name: 'Everyday Micro-Joys',
    hint: 'Think of clean linen sheets, a warm cat, or a fresh notebook',
  ),
  CategoryPrompt(
    id: 'tactile_warmths',
    name: 'Sensory Warmths',
    hint: 'Think of sunlight on your skin, a hot mug, or smooth wood',
  ),
  CategoryPrompt(
    id: 'sacred_spaces',
    name: 'Peaceful Sanctuaries',
    hint: 'Think of a monastery cloister, botanic garden, or empty chapel',
  ),
  CategoryPrompt(
    id: 'restorative_rituals',
    name: 'Restorative Micro-Rituals',
    hint: 'Think of lighting a candle, brewing tea, or washing your face',
  ),
  CategoryPrompt(
    id: 'timeless_wonders',
    name: 'Quiet Wonders of Nature',
    hint: 'Think of ancient stone circles, geysers, auroras, or redwood trees',
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
