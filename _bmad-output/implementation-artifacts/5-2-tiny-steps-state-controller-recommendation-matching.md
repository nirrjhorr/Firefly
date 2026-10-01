# Story 5.2: Tiny Steps State Controller & Recommendation Matching

Status: done

## Story Description
As a user feeling paralyzed or lacking momentum,
I want a state controller that matches 3 relevant tiny steps to my latest check-in state,
So that I am offered manageable options tailored to my current energy without feeling overwhelmed.

## Acceptance Criteria
1. `TinyStepsState` model:
   - Contains list of 3 selected `TinyStep` candidates, `completedStepId` (optional), and current energy filter.
2. `TinyStepsController` (`AsyncNotifier` or `StateNotifier`):
   - Reads user's current energy from latest `CheckInEntry` / `AffectState` if available, or defaults to low energy (2).
   - Randomly selects 3 distinct matching micro-actions from the catalog without repeats in the current set.
   - `shuffle()` method to load 3 alternative options on demand.
   - `completeStep(String stepId)` to mark an action as completed and update local state.
3. Unit tests verifying state initialization, state-matched filtering, shuffling logic, and completion events.
