import '../routing/app_routes.dart';
import 'models/action_suggestion.dart';
import 'models/affect_state.dart';

/// Pure, deterministic recommendation engine for Firefly.
/// Zero IO, zero cloud dependency, evaluates in < 1ms.
abstract final class RecommendationEngine {
  static ActionSuggestion evaluate(AffectState state) {
    final mood = state.moodCategory.toLowerCase().trim();

    // Priority 1: High Anxiety -> Cyclic Sighing Breathing
    if (state.anxietyLevel >= 4) {
      return ActionSuggestion(
        actionType: ActionType.breathing,
        title: 'Slowing down with breath',
        body:
            'Your anxiety is elevated. A 2-minute cyclic sighing breath can gently reset your nervous system.',
        route: AppRoutes.breathe,
        durationMinutes: 2,
        alternativeSuggestions: [
          _groundingSuggestion,
          _soundscapeSuggestion,
          _tinyStepsSuggestion,
          _journalingSuggestion,
        ],
      );
    }

    // Priority 2: Low / Heavy Mood + Low Energy -> Tiny Steps (Behavioral Activation)
    if ((mood == 'low' || mood == 'heavy') && state.energyLevel <= 2) {
      return ActionSuggestion(
        actionType: ActionType.tinySteps,
        title: 'One tiny, gentle step',
        body:
            'When energy is low, starting small is enough. Pick one tiny, doable action for the next 2 minutes.',
        route: AppRoutes.tinySteps,
        durationMinutes: 2,
        alternativeSuggestions: [
          _breathingSuggestion,
          _journalingSuggestion,
          _groundingSuggestion,
        ],
      );
    }

    // Priority 3: High Loneliness -> Loneliness Comfort
    if (state.lonelinessLevel >= 4) {
      return const ActionSuggestion(
        actionType: ActionType.lonelinessComfort,
        title: 'Holding space for connection',
        body:
            'Loneliness can feel heavy. Here are soft, low-pressure ways to feel anchored and reach out.',
        route: AppRoutes.loneliness,
        durationMinutes: 3,
        alternativeSuggestions: [
          _hopeBoxSuggestion,
          _breathingSuggestion,
          _journalingSuggestion,
          _tinyStepsSuggestion,
        ],
      );
    }

    // Priority 4: Overwhelmed -> 5-4-3-2-1 Sensory Grounding
    if (mood == 'overwhelmed') {
      return _groundingSuggestion.copyWithAlternatives([
        _breathingSuggestion,
        _journalingSuggestion,
        _tinyStepsSuggestion,
      ]);
    }

    // Priority 5: Moderate Anxiety or Lower Energy -> Expressive Journaling
    if (state.anxietyLevel >= 2 || state.energyLevel <= 3) {
      return ActionSuggestion(
        actionType: ActionType.journaling,
        title: 'Offload your thoughts',
        body:
            'Putting thoughts onto paper frees up cognitive bandwidth. Write freely with zero judgment.',
        route: AppRoutes.journal,
        durationMinutes: 3,
        alternativeSuggestions: [
          _breathingSuggestion,
          _tinyStepsSuggestion,
          _groundingSuggestion,
        ],
      );
    }

    // Priority 6: Default Balanced State -> Mindful Tiny Step
    return ActionSuggestion(
      actionType: ActionType.tinySteps,
      title: 'Carry this steady moment forward',
      body:
          'You are feeling balanced. A small mindful action can help sustain this gentle rhythm.',
      route: AppRoutes.tinySteps,
      durationMinutes: 2,
      alternativeSuggestions: [
        _breathingSuggestion,
        _journalingSuggestion,
        _groundingSuggestion,
      ],
    );
  }

  static const _breathingSuggestion = ActionSuggestion(
    actionType: ActionType.breathing,
    title: 'Slowing down with breath',
    body:
        'A 2-minute cyclic sighing breath can gently reset your nervous system.',
    route: AppRoutes.breathe,
    durationMinutes: 2,
  );

  static const _tinyStepsSuggestion = ActionSuggestion(
    actionType: ActionType.tinySteps,
    title: 'One tiny, gentle step',
    body: 'A single, very small, doable action to ease momentum.',
    route: AppRoutes.tinySteps,
    durationMinutes: 2,
  );

  static const _journalingSuggestion = ActionSuggestion(
    actionType: ActionType.journaling,
    title: 'Offload your thoughts',
    body: 'Externalize what is on your mind in private, encrypted space.',
    route: AppRoutes.journal,
    durationMinutes: 3,
  );

  static const _groundingSuggestion = ActionSuggestion(
    actionType: ActionType.grounding,
    title: '5-4-3-2-1 Sensory Grounding',
    body:
        'When everything feels too much, return your focus to your immediate senses, one by one.',
    route: '${AppRoutes.breathe}?mode=grounding',
    durationMinutes: 2,
  );

  static const _soundscapeSuggestion = ActionSuggestion(
    actionType: ActionType.soundscape,
    title: 'Sound Sanctuary',
    body:
        'Immerse in offline nature recordings or restorative brown noise for calming rest.',
    route: AppRoutes.soundscapes,
    durationMinutes: 10,
  );

  static const _hopeBoxSuggestion = ActionSuggestion(
    actionType: ActionType.hopeBox,
    title: 'Visit Your Hope Box',
    body:
        'Revisit personal memories, comforting notes, and reasons worth holding onto.',
    route: AppRoutes.hopeBox,
    durationMinutes: 3,
  );
}

extension on ActionSuggestion {
  ActionSuggestion copyWithAlternatives(List<ActionSuggestion> alternatives) {
    return ActionSuggestion(
      actionType: actionType,
      title: title,
      body: body,
      route: route,
      durationMinutes: durationMinutes,
      alternativeSuggestions: alternatives,
    );
  }
}
