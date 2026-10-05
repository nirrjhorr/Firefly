---
title: 'Extended Sensory Grounding Suite (FR-13)'
type: 'feature'
created: '2026-10-05'
status: 'done'
baseline_commit: 'ba752e1c54c4f9b95af194d9ae510abe7a9edae4'
route: 'dispatch'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Firefly currently only offers the standard 5-4-3-2-1 sensory exercise in its grounding mode. Users experiencing dissociation, sensory differences, physical injury, or situational constraints (e.g. inability to taste/smell or confined spaces) need varied, low-cognitive-load grounding modalities to anchor attention outside internal ruminative threat circuits.

**Approach:** Expand the sensory grounding engine to support 5 distinct evidence-based grounding modes (5-4-3-2-1, Texture Hunt, Sound Hunt, Colour Search, Feet on Floor Proprioceptive Grounding) using tactile prompt cards, smooth 300ms transitions, tactile haptic feedback, and post-session effectiveness tracking.

## Boundaries & Constraints

**Always:**
- Keep all interactive touch targets ≥ 56dp.
- Adhere strictly to WCAG AA contrast (≥ 4.5:1) on dark canvas (`#111518`).
- Maintain zero network calls (`FireflyHttpOverride` enforced).
- Support non-judgmental early exit ("That's enough for now") and stage skip without negative UI feedback.
- Prompt for post-session effectiveness rating via `EffectivenessFeedbackSheet` when ≥ 1 stage is completed, without storing any free-text notes.

**Never:**
- Never display countdown timers, failure alerts, or scoreboards in sensory exercises.
- Never force a user to complete all steps or penalize skipping senses.
- Never make outbound network requests or record private sensory notes to disk.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Select Grounding Mode | User chooses Texture Hunt | Controller initialises with 3 tactile texture stages (smooth, rough, fabric) | Fallback to 5-4-3-2-1 if unrecognized mode |
| Notice Step | User taps prompt card or "I noticed" | Haptic tick fires, counter increments, auto-advances when target reached | Ignore taps once target count reached |
| Skip Modality | User taps "Skip sense / step" | Advances to next stage cleanly without penalty or shame | If last stage, marks complete gently |
| Early Exit | User taps "That's enough for now" | Completes exercise, triggers effectiveness sheet if progress made, returns to Home | Pop safely or route to Home |
| Complete Sequence | All stages in mode checked off | 400ms tranquil sage glow, haptic double tick, opens effectiveness sheet | Clean disposal on exit |

</frozen-after-approval>

## Code Map

- `lib/features/breathing_grounding/domain/models/grounding_stage.dart` -- Define `GroundingMode` enum, stage definitions for Texture Hunt, Sound Hunt, Colour Search, and Feet on Floor.
- `lib/features/breathing_grounding/domain/models/grounding_session_state.dart` -- Extend state model with active `GroundingMode` and mode-specific total target count calculations.
- `lib/features/breathing_grounding/presentation/controllers/grounding_controller.dart` -- Support mode switching, auto-advancing, skipping, and haptic feedback.
- `lib/features/breathing_grounding/presentation/widgets/grounding_mode_selector.dart` -- Canonical low-stimulation modal or selector chips for switching grounding modes.
- `lib/features/breathing_grounding/presentation/widgets/grounding_prompt_card.dart` -- Render mode-specific prompt cards with ≥ 56dp targets and 300ms ease transitions.
- `lib/features/breathing_grounding/presentation/screens/breathing_grounding_screen.dart` -- Wire sensory grounding modes, query parameter routing (`?mode=textureHunt`), and post-session effectiveness dialog.
- `test/features/breathing_grounding/verify_sensory_grounding_standalone.dart` -- Unit and widget verification suite for all 5 modes.

## Tasks & Acceptance

**Execution:**
- [x] `lib/features/breathing_grounding/domain/models/grounding_stage.dart` -- Add `GroundingMode` enum and static stage lists for `textureHunt`, `soundHunt`, `colourSearch`, and `feetOnFloor`.
- [x] `lib/features/breathing_grounding/domain/models/grounding_session_state.dart` -- Add `mode` property to `GroundingSessionState` with mode-aware progress computations.
- [x] `lib/features/breathing_grounding/presentation/controllers/grounding_controller.dart` -- Add `setMode(GroundingMode mode)` and ensure clean reset and stage progression.
- [x] `lib/features/breathing_grounding/presentation/widgets/grounding_mode_selector.dart` -- Implement low-stimulation mode selector sheet/pills matching Design System tokens.
- [x] `lib/features/breathing_grounding/presentation/widgets/grounding_prompt_card.dart` -- Enhance prompt card with dynamic sensory icon styling, prompt cues, and skip button.
- [x] `lib/features/breathing_grounding/presentation/screens/breathing_grounding_screen.dart` -- Integrate mode switching, route argument support, and effectiveness feedback trigger.
- [x] `test/features/breathing_grounding/verify_sensory_grounding_standalone.dart` -- Create standalone verification test suite validating all 5 modes, progression, haptics, and zero network calls.

**Acceptance Criteria:**
- Given the Grounding mode in `BreathingGroundingScreen`, when switching between all 5 modes, then the active stage cards update with corresponding sensory prompts and target counts.
- Given any grounding stage, when tapping "I noticed" or checking off an item, then `HapticsPort` triggers a light impact and progress updates smoothly.
- Given any active stage, when tapping "Skip", then the session advances to the next stage without negative visual or auditory feedback.
- Given session completion, when the last item is confirmed, then a subtle sage glow animates, and `EffectivenessFeedbackSheet` is displayed.
- Given the verification test suite, all tests pass with zero regressions and zero network requests.

## Implementation Notes

- Implemented `GroundingMode` enum supporting 5 distinct modalities: 5-4-3-2-1, Texture Hunt, Sound Hunt, Colour Search, and Feet on Floor (proprioceptive grounding).
- Introduced `GroundingIcon` pure Dart value object to decouple the domain layer from `flutter/material.dart`, enabling clean headless CLI testing.
- Created `GroundingModeSelector` widget rendering low-stimulation pills with accessible ≥ 48dp targets and sage glow highlights.
- Connected mode switching to `BreathingGroundingScreen` and wired post-session effectiveness rating via `EffectivenessFeedbackSheet`.
- Authored and passed `verify_sensory_grounding_standalone.dart` testing all 5 modes, step transitions, and progress calculations.

## Spec Change Log

## Review Triage Log

## Design Notes

The 5 modes address distinct somatic and cognitive needs:
1. **5-4-3-2-1**: Comprehensive external sensory ladder for general overwhelm.
2. **Texture Hunt**: High-tactile focus for grounding when visual input is overwhelming or lights are dim.
3. **Sound Hunt**: Acoustic orienting for grounding when still or lying down.
4. **Colour Search**: Visual scanning to break mental freeze and engage exploratory ocular micro-movements.
5. **Feet on Floor**: Proprioceptive vestibular grounding for dissociation, panic, or vertigo sensations.
