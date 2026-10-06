---
title: 'Story 13.1: Cognitive Grounding Engine (FR-14 / Epic 13)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: '32b4e40'
route: 'dispatch'
review_loop_iteration: 0
context: ['_bmad-output/implementation-artifacts/11-2-cognitive-grounding-attention-switching-engine.md']
---

## Intent

**Problem:** Users caught in repetitive rumination, depressive brooding, or acute anxiety loops experience intrusive thoughts that physical or sensory grounding alone cannot always break. Evidence-based cognitive interruption tasks (such as categories, backward counting, and word associations) disrupt these loops by recruiting working memory bandwidth. However, mainstream apps gamify these with timers, buzzers, and failure states that trigger shame or cognitive exhaustion.

**Approach:** Complete Story 13.1 by deploying Firefly's non-clinical Cognitive Grounding Engine featuring 52 offline curated soothing categories (surpassing the ≥50 criteria), backward counting (from 100 by 7s, 50 by 3s, 30 by 2s), calming word associations, and tranquil sequence holding. Designed strictly without scoring, countdowns, or fail states, offering gentle pacing, tactile haptic feedback, effortless letter/step skips, and immediate "That's enough for now" exits linked to post-session effectiveness feedback.

## Acceptance Criteria Verification

- [x] `CognitiveGroundingScreen` with text-based cognitive prompts and gentle 300ms transitions.
- [x] Zero scoring, timers, or error buzzers (purely user-directed pacing).
- [x] 52 offline soothing category prompts (exceeding ≥50 requirement) across nature, comforts, animals, textures, and serene memories.
- [x] Verified via `test/features/cognitive_grounding/verify_cognitive_grounding_standalone.dart` with 100% assertions passing.

## Code Artifacts

- `lib/features/cognitive_grounding/domain/models/cognitive_exercise.dart` (52 offline category prompts, counting configurations, word chains)
- `lib/features/cognitive_grounding/domain/models/cognitive_session_state.dart`
- `lib/features/cognitive_grounding/presentation/controllers/cognitive_grounding_controller.dart`
- `lib/features/cognitive_grounding/presentation/screens/cognitive_grounding_screen.dart`
- `lib/features/cognitive_grounding/presentation/widgets/cognitive_mode_selector.dart`
- `lib/features/cognitive_grounding/presentation/widgets/cognitive_exercise_card.dart`
- `test/features/cognitive_grounding/verify_cognitive_grounding_standalone.dart`
