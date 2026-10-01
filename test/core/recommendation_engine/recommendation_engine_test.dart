import 'package:flutter_test/flutter_test.dart';
import 'package:firefly/core/recommendation_engine/models/action_suggestion.dart';
import 'package:firefly/core/recommendation_engine/models/affect_state.dart';
import 'package:firefly/core/recommendation_engine/recommendation_engine.dart';
import 'package:firefly/core/routing/app_routes.dart';

void main() {
  group('RecommendationEngine (100% Branch Coverage)', () {
    test('Priority 1: High anxiety (>= 4) routes to breathing', () {
      const state = AffectState(
        moodCategory: 'here',
        energyLevel: 3,
        anxietyLevel: 4,
        lonelinessLevel: 1,
      );

      final result = RecommendationEngine.evaluate(state);

      expect(result.actionType, equals(ActionType.breathing));
      expect(result.route, equals(AppRoutes.breathe));
      expect(result.durationMinutes, equals(2));
      expect(result.alternativeSuggestions.length, equals(3));
    });

    test('Priority 2: Low mood with low energy (<= 2) routes to tiny steps', () {
      const state = AffectState(
        moodCategory: 'low',
        energyLevel: 1,
        anxietyLevel: 2,
        lonelinessLevel: 2,
      );

      final result = RecommendationEngine.evaluate(state);

      expect(result.actionType, equals(ActionType.tinySteps));
      expect(result.route, equals(AppRoutes.tinySteps));
      expect(result.durationMinutes, equals(2));
    });

    test('Priority 2: Heavy mood with low energy (<= 2) routes to tiny steps', () {
      const state = AffectState(
        moodCategory: 'heavy',
        energyLevel: 2,
        anxietyLevel: 1,
        lonelinessLevel: 1,
      );

      final result = RecommendationEngine.evaluate(state);

      expect(result.actionType, equals(ActionType.tinySteps));
      expect(result.route, equals(AppRoutes.tinySteps));
    });

    test('Priority 3: High loneliness (>= 4) routes to loneliness comfort', () {
      const state = AffectState(
        moodCategory: 'here',
        energyLevel: 3,
        anxietyLevel: 2,
        lonelinessLevel: 5,
      );

      final result = RecommendationEngine.evaluate(state);

      expect(result.actionType, equals(ActionType.lonelinessComfort));
      expect(result.route, equals('/home/loneliness'));
      expect(result.durationMinutes, equals(3));
    });

    test('Priority 4: Overwhelmed mood routes to 5-4-3-2-1 grounding', () {
      const state = AffectState(
        moodCategory: 'overwhelmed',
        energyLevel: 3,
        anxietyLevel: 2,
        lonelinessLevel: 1,
      );

      final result = RecommendationEngine.evaluate(state);

      expect(result.actionType, equals(ActionType.grounding));
      expect(result.route, contains('mode=grounding'));
    });

    test('Priority 5: Moderate anxiety (>= 2) routes to journaling', () {
      const state = AffectState(
        moodCategory: 'here',
        energyLevel: 4,
        anxietyLevel: 3,
        lonelinessLevel: 1,
      );

      final result = RecommendationEngine.evaluate(state);

      expect(result.actionType, equals(ActionType.journaling));
      expect(result.route, equals(AppRoutes.journal));
      expect(result.durationMinutes, equals(3));
    });

    test('Priority 5: Low energy (<= 3) with calm mood routes to journaling', () {
      const state = AffectState(
        moodCategory: 'calm',
        energyLevel: 3,
        anxietyLevel: 1,
        lonelinessLevel: 1,
      );

      final result = RecommendationEngine.evaluate(state);

      expect(result.actionType, equals(ActionType.journaling));
      expect(result.route, equals(AppRoutes.journal));
    });

    test('Priority 6: Default balanced state routes to tiny steps', () {
      const state = AffectState(
        moodCategory: 'open',
        energyLevel: 4,
        anxietyLevel: 1,
        lonelinessLevel: 1,
      );

      final result = RecommendationEngine.evaluate(state);

      expect(result.actionType, equals(ActionType.tinySteps));
      expect(result.route, equals(AppRoutes.tinySteps));
      expect(result.durationMinutes, equals(2));
    });

    test('ActionSuggestion JSON serialization roundtrip', () {
      const original = ActionSuggestion(
        actionType: ActionType.breathing,
        title: 'Slowing down with breath',
        body: 'Calming cyclic sighing breath',
        route: '/home/breathe',
        durationMinutes: 2,
      );

      final json = original.toJson();
      final reconstructed = ActionSuggestion.fromJson(json);

      expect(reconstructed.actionType, equals(original.actionType));
      expect(reconstructed.title, equals(original.title));
      expect(reconstructed.body, equals(original.body));
      expect(reconstructed.route, equals(original.route));
      expect(reconstructed.durationMinutes, equals(original.durationMinutes));
    });
  });
}
