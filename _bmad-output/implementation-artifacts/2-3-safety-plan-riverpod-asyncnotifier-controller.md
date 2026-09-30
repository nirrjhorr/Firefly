# Story 2.3: Safety Plan Riverpod AsyncNotifier Controller

Status: done

## Story Description
As a user,
I want reactive state management that automatically loads and autosaves my safety plan,
So that changes I make under distress are never lost.

## Acceptance Criteria
1. `SafetyPlanController` implemented in `lib/features/safety_plan/presentation/controllers/safety_plan_controller.dart`.
2. Extends `AsyncNotifier<SafetyPlan?>` (or `StateNotifier`).
3. Supports CRUD methods: `updateStepText(int stepNumber, String text)`, `addCustomContact(...)`, `removeContact(String id)`, `addWarningSign(String warning)`, `removeWarningSign(String id)`, `recordReview()`.
4. Handles optimistic updates or seamless async state updates without flashing loaders or jarring jumps.
