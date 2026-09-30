# Story 3.1: Pure Deterministic Recommendation Engine

Status: done

## Story Description
As a developer,
I want a pure, deterministic recommendation engine function with 100% unit test coverage,
So that user states are consistently and safely routed to the correct intervention without cloud dependencies or unpredictable LLM hallucinations.

## Acceptance Criteria
1. `AffectState` model defined with `moodCategory`, `energyLevel` (1-5), `anxietyLevel` (1-5), and `lonelinessLevel` (1-5).
2. `ActionSuggestion` model defined with `actionType`, `title`, `body`, `route`, and `durationMinutes`.
3. `RecommendationEngine.evaluate(AffectState)` implemented as a pure function:
   - Rule 1: `anxietyLevel >= 4` -> Cyclic sighing breathing (`/home/breathe`)
   - Rule 2: `moodCategory == 'low' && energyLevel <= 2` -> Tiny step behavioral activation (`/home/tiny-steps`)
   - Rule 3: `lonelinessLevel >= 4` -> Loneliness comfort (`/home/loneliness`)
   - Rule 4: `moodCategory == 'overwhelmed'` -> 5-4-3-2-1 grounding (`/home/breathe?mode=grounding`)
   - Rule 5: `anxietyLevel >= 2 || energyLevel <= 3` -> Expressive journaling (`/home/journal`)
   - Rule 6: Default fallback -> Tiny step (`/home/tiny-steps`)
4. 100% unit test coverage in `test/core/recommendation_engine/recommendation_engine_test.dart`.
