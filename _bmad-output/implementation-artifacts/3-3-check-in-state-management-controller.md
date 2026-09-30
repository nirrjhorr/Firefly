# Story 3.3: Check-In State Management Controller

Status: done

## Story Description
As a user,
I want a responsive check-in controller that manages my selections and provides the resulting suggestion,
So that submitting my check-in transitions seamlessly into the recommended care action.

## Acceptance Criteria
1. `CheckInController` created in `lib/features/check_in/presentation/controllers/check_in_controller.dart`.
2. State holds active selection (`moodCategory`, `energyLevel`, `anxietyLevel`, `lonelinessLevel`), submitting state, and completed `ActionSuggestion?`.
3. Submitting triggers:
   - Evaluation with `RecommendationEngine`.
   - Persistence to `CheckInRepository`.
   - Updates state with the resulting `ActionSuggestion`.
4. Resets state cleanly when starting a new check-in.
