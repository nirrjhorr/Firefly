import '../routing/app_routes.dart';
import 'models/action_suggestion.dart';
import 'models/affect_state.dart';

/// Pure, deterministic recommendation engine for Firefly.
/// Zero IO, zero cloud dependency, evaluates in < 1ms.
abstract final class RecommendationEngine {
  static ActionSuggestion evaluate(
    AffectState state, {
    Map<String, double>? personalAffinities,
    Map<String, String>? personalizedReasons,
  }) {
    final mood = state.moodCategory.toLowerCase().trim();
    ActionSuggestion base;

    // Priority 1: High Anxiety -> Cyclic Sighing Breathing
    if (state.anxietyLevel >= 4) {
      base = const ActionSuggestion(
        actionType: ActionType.breathing,
        title: 'Slowing down with breath',
        body:
            'Your anxiety is elevated. A 2-minute cyclic sighing breath can gently reset your nervous system.',
        route: AppRoutes.breathe,
        durationMinutes: 2,
        alternativeSuggestions: [
          _groundingSuggestion,
          _resetSuggestion,
          _soundscapeSuggestion,
          _tinyStepsSuggestion,
          _journalingSuggestion,
        ],
      );
    }
    // Priority 2: Low / Heavy Mood + Low Energy -> Tiny Steps (Behavioral Activation)
    else if ((mood == 'low' || mood == 'heavy') && state.energyLevel <= 2) {
      base = const ActionSuggestion(
        actionType: ActionType.tinySteps,
        title: 'One tiny, gentle step',
        body:
            'When energy is low, starting small is enough. Pick one tiny, doable action for the next 2 minutes.',
        route: AppRoutes.tinySteps,
        durationMinutes: 2,
        alternativeSuggestions: [
          _breathingSuggestion,
          _compassionSuggestion,
          _journalingSuggestion,
          _groundingSuggestion,
        ],
      );
    }
    // Priority 3: High Loneliness -> Loneliness Comfort
    else if (state.lonelinessLevel >= 4) {
      base = const ActionSuggestion(
        actionType: ActionType.lonelinessComfort,
        title: 'Holding space for connection',
        body:
            'Loneliness can feel heavy. Here are soft, low-pressure ways to feel anchored and reach out.',
        route: AppRoutes.loneliness,
        durationMinutes: 3,
        alternativeSuggestions: [
          _hopeBoxSuggestion,
          _compassionSuggestion,
          _breathingSuggestion,
          _journalingSuggestion,
          _tinyStepsSuggestion,
        ],
      );
    }
    // Priority 4: Overwhelmed -> 5-4-3-2-1 Sensory Grounding
    else if (mood == 'overwhelmed') {
      base = _groundingSuggestion.copyWithAlternatives([
        _breathingSuggestion,
        _focusSuggestion,
        _resetSuggestion,
        _journalingSuggestion,
        _tinyStepsSuggestion,
      ]);
    }
    // Priority 5: Scattered / Mind Racing -> Focus & Three Priorities
    else if (mood == 'scattered' || mood == 'racing') {
      base = _focusSuggestion.copyWithAlternatives([
        _groundingSuggestion,
        _breathingSuggestion,
        _journalingSuggestion,
        _tinyStepsSuggestion,
      ]);
    }
    // Priority 6: Moderate Anxiety or Lower Energy -> Expressive Journaling
    else if (state.anxietyLevel >= 2 || state.energyLevel <= 3) {
      base = const ActionSuggestion(
        actionType: ActionType.journaling,
        title: 'Offload your thoughts',
        body:
            'Putting thoughts onto paper frees up cognitive bandwidth. Write freely with zero judgment.',
        route: AppRoutes.journal,
        durationMinutes: 3,
        alternativeSuggestions: [
          _breathingSuggestion,
          _focusSuggestion,
          _tinyStepsSuggestion,
          _groundingSuggestion,
        ],
      );
    }
    // Priority 7: Default Balanced State -> Mindful Tiny Step
    else {
      base = const ActionSuggestion(
        actionType: ActionType.tinySteps,
        title: 'Carry this steady moment forward',
        body:
            'You are feeling balanced. A small mindful action can help sustain this gentle rhythm.',
        route: AppRoutes.tinySteps,
        durationMinutes: 2,
        alternativeSuggestions: [
          _breathingSuggestion,
          _focusSuggestion,
          _journalingSuggestion,
          _groundingSuggestion,
        ],
      );
    }

    if (personalAffinities == null || personalAffinities.isEmpty) {
      return base;
    }

    return _applyPersonalization(
      base,
      personalAffinities: personalAffinities,
      personalizedReasons: personalizedReasons,
    );
  }

  static ActionSuggestion _applyPersonalization(
    ActionSuggestion base, {
    required Map<String, double> personalAffinities,
    Map<String, String>? personalizedReasons,
  }) {
    double getScore(ActionSuggestion s) {
      return personalAffinities[s.actionType.name] ??
          personalAffinities[s.route] ??
          0.0;
    }

    String? getReason(ActionSuggestion s) {
      return personalizedReasons?[s.actionType.name] ??
          personalizedReasons?[s.route];
    }

    // Decorate base suggestion with personal affinity if positive
    final baseScore = getScore(base);
    final baseReason = getReason(base) ??
        (baseScore > 0.25 ? 'Previously helped you feel more settled' : null);

    ActionSuggestion currentPrimary = base.copyWith(
      affinityScore: baseScore > 0 ? baseScore : null,
      personalizedReason: baseReason,
    );

    // Decorate alternatives
    final decoratedAlternatives = base.alternativeSuggestions.map((alt) {
      final score = getScore(alt);
      final reason = getReason(alt) ??
          (score > 0.25 ? 'Previously helped you feel more settled' : null);
      return alt.copyWith(
        affinityScore: score > 0 ? score : null,
        personalizedReason: reason,
      );
    }).toList();

    // Sort alternatives by affinity score descending
    decoratedAlternatives.sort((a, b) {
      final scoreA = a.affinityScore ?? 0.0;
      final scoreB = b.affinityScore ?? 0.0;
      return scoreB.compareTo(scoreA);
    });

    // If an alternative has very strong positive affinity (> 0.45) while base is neutral/untested (<= 0.1),
    // promote that proven calming practice to primary
    if (decoratedAlternatives.isNotEmpty) {
      final bestAlt = decoratedAlternatives.first;
      final bestAltScore = bestAlt.affinityScore ?? 0.0;
      if (bestAltScore >= 0.45 && baseScore <= 0.1) {
        final remainingAlts = [
          currentPrimary,
          ...decoratedAlternatives.skip(1),
        ];
        return bestAlt.copyWith(alternativeSuggestions: remainingAlts);
      }
    }

    return currentPrimary.copyWith(
      alternativeSuggestions: decoratedAlternatives,
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

  static const _focusSuggestion = ActionSuggestion(
    actionType: ActionType.focus,
    title: 'Three Priorities & Focus',
    body:
        'Externalize mental clutter and gently focus on at most 3 micro-intentions.',
    route: AppRoutes.focus,
    durationMinutes: 5,
  );

  static const _compassionSuggestion = ActionSuggestion(
    actionType: ActionType.compassion,
    title: 'Self-Compassion Break',
    body:
        'Kind touch and gentle reassurance when being too critical of yourself.',
    route: AppRoutes.compassion,
    durationMinutes: 3,
  );

  static const _resetSuggestion = ActionSuggestion(
    actionType: ActionType.reset,
    title: 'One-Session Reset',
    body:
        'A self-contained 5-minute journey designed for acute relief in a single session.',
    route: AppRoutes.reset,
    durationMinutes: 5,
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
      personalizedReason: personalizedReason,
      affinityScore: affinityScore,
    );
  }
}
