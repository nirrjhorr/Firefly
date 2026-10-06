---
title: 'Cognitive Grounding & Attention Switching Engine (FR-14)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: 'a027cb1'
route: 'dispatch'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Users caught in repetitive rumination, depressive brooding, or acute anxiety loops experience intrusive thoughts that physical or sensory grounding alone cannot always break. When working memory is captive to threat circuits, evidence-based cognitive interruption tasks (such as categories, backward counting, and word associations) can disrupt these loops by recruiting working memory bandwidth. However, mainstream apps gamify these with timers, buzzers, and failure states that trigger shame or cognitive exhaustion.

**Approach:** Build a dedicated, non-clinical Cognitive Grounding & Attention Switching Engine for Firefly. Provide 4 gentle, user-paced modalities (Alphabet Categories, Backward Counting, Word Association, Memory Sequence) designed strictly without scoring, time limits, or fail states. Each task offers gentle pacing, tactile haptic taps, effortless skips, and immediate "That's enough for now" exits linked to post-session effectiveness rating.

## Boundaries & Constraints

**Always:**
- Keep all interactive touch targets ≥ 56dp.
- Adhere strictly to WCAG AA contrast (≥ 4.5:1) on dark canvas (`#111518`).
- Maintain zero network calls (`FireflyHttpOverride` enforced).
- Support non-judgmental early exit ("That's enough for now") and stage skip without negative UI feedback.
- Prompt for post-session effectiveness rating via `EffectivenessFeedbackSheet` when ≥ 1 stage is completed, without storing any free-text notes.
- Pacing must be entirely self-directed; no countdown timers or buzzers.

**Never:**
- Never display countdown timers, failure alerts, or scoreboards.
- Never record or transmit user answers, freeform inputs, or text responses to disk or network.
- Never judge progress or force a user to finish all letters or steps.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Select Exercise Mode | User selects "Alphabet Categories" | Controller initialises with category prompt (e.g. "Animals" or "Countries") and letter 'A' | Fallback to Alphabet Categories if unknown mode |
| Confirm Word / Step | User taps "I found one" or enters step | Haptic tick fires, advances to next letter/step with smooth 300ms transition | Ignore double-taps during 300ms transition |
| Skip Letter / Step | User taps "Skip letter" | Advances to next letter/step cleanly without penalty or shame | If end reached, offers completion gently |
| Switch Category | User taps "New category" | Randomly picks next category from offline curated list | Seamless state refresh |
| Backward Counting | User selects "Counting" with step size 7 | Steps down from 100 (100 -> 93 -> 86...), shows current prompt, user taps when calculated | Option to switch step size (3s or 7s) |
| Early Exit | User taps "That's enough for now" | Completes exercise, triggers effectiveness sheet if progress made, returns to previous route | Pop safely or route to Home |

</frozen-after-approval>

## Code Map

- `lib/features/cognitive_grounding/domain/models/cognitive_exercise.dart` -- Domain models for exercise modes, category libraries, and stage states.
- `lib/features/cognitive_grounding/domain/models/cognitive_session_state.dart` -- Immutable session state model tracking active exercise, step, and progress.
- `lib/features/cognitive_grounding/presentation/controllers/cognitive_grounding_controller.dart` -- Riverpod controller managing user-paced transitions, haptics, and category rotations.
- `lib/features/cognitive_grounding/presentation/widgets/cognitive_mode_selector.dart` -- Low-stimulation selector cards for the 4 cognitive modalities.
- `lib/features/cognitive_grounding/presentation/widgets/cognitive_exercise_card.dart` -- Tactile prompt card with large touch targets, skip buttons, and peaceful styling.
- `lib/features/cognitive_grounding/presentation/screens/cognitive_grounding_screen.dart` -- Main screen with mode switching, persistent SOS shield compatibility, and effectiveness sheet.
- `lib/core/routing/app_routes.dart` & `lib/core/routing/app_router.dart` -- Register `/home/cognitive-grounding` route.
- `test/features/cognitive_grounding/verify_cognitive_grounding_standalone.dart` -- Verification suite for all 4 cognitive exercise types.

## Tasks & Acceptance

**Execution:**
- [x] `lib/features/cognitive_grounding/domain/models/cognitive_exercise.dart` -- Create exercise types, offline curated lists (animals, foods, cities, calming objects), and stage definitions.
- [x] `lib/features/cognitive_grounding/domain/models/cognitive_session_state.dart` -- Create immutable state model.
- [x] `lib/features/cognitive_grounding/presentation/controllers/cognitive_grounding_controller.dart` -- Implement controller with mode selection, advance, skip, and reset.
- [x] `lib/features/cognitive_grounding/presentation/widgets/cognitive_mode_selector.dart` -- Build accessible mode selector pills/cards.
- [x] `lib/features/cognitive_grounding/presentation/widgets/cognitive_exercise_card.dart` -- Build non-gamified prompt card.
- [x] `lib/features/cognitive_grounding/presentation/screens/cognitive_grounding_screen.dart` -- Assemble screen with SOS shield and effectiveness tracking.
- [x] `lib/core/routing/app_routes.dart` & `lib/core/routing/app_router.dart` -- Wire route and connect acute distress anchor in `RightNowModal`.
- [x] `test/features/cognitive_grounding/verify_cognitive_grounding_standalone.dart` -- Create and run standalone verification suite.

**Acceptance Criteria:**
- Given `CognitiveGroundingScreen`, when switching between Alphabet Categories, Counting, Word Association, and Memory Sequence, the screen renders appropriate calming prompts.
- Given any prompt, when tapping "I have one" or advancing, a gentle haptic tick occurs and the next prompt appears without delays or stutter.
- Given any active exercise, when tapping "Skip", the exercise proceeds without error sounds, penalty counters, or visual red cues.
- Given "That's enough for now", the exercise gracefully exits and opens `EffectivenessFeedbackSheet` if ≥ 1 item was completed.
- All standalone verification tests pass with zero network calls and strict null safety.

## Implementation Notes

- Implemented 4 non-gamified working memory interruption exercises: Alphabet Categories, Backward Counting, Word Associations, and Calm Sequence.
- Connected acute distress fast-path in `RightNowModal` ('I cannot stop thinking' -> `AppRoutes.cognitiveGrounding`).
- Created accessible `CognitiveModeSelector` and `CognitiveExerciseCard` with ≥ 56dp primary touch targets, Atkinson typography, and calm sage accents.
- Verified all domain logic and state transitions with `test/features/cognitive_grounding/verify_cognitive_grounding_standalone.dart`.
