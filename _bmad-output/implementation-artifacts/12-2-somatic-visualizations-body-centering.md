---
title: 'Somatic Visualizations & Body Centering (Story 12.2)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: 'b4dcc0a'
route: 'dispatch'
review_loop_iteration: 0
context:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/epics.md
  - research data/Activity_Architecture.md
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** When a user is caught in autonomic hyper-arousal, somatic hyper-vigilance, or restless tension, cognitive instructions ("stop worrying") fail because the sympathetic nervous system is locked into a vigilance state. Guided somatic visualizations directly address physiological feedback loops by utilizing autogenic thermal cues (peripheral vasodilation), gravitational settling (skeletal and postural unwinding), grounded posture anchoring (vestibular and proprioceptive stabilization), and brief mindful pause resets. Existing commercial apps typically gate these techniques behind subscription paywalls or complex multi-minute guided audio sessions that feel too demanding during distress.

**Approach:** Build a dedicated, 100% offline Somatic Visualizations & Body Centering Suite for Firefly:
1. Provide 4 evidence-based somatic centering modes:
   - **Heavy Body Gravity Settling** (`heavyBody`): Guided awareness of downward gravitational pull, releasing held tension in jaw, shoulders, pelvis, and limbs into the support underneath.
   - **Warm Hands Peripheral Dilation** (`warmHands`): Autogenic visualization of blood flow and soothing warmth radiating into palms and fingertips, triggering peripheral vasodilation and down-regulating autonomic arousal.
   - **Mountain Posture Stability** (`mountainPosture`): Somatosensory posture alignment visualizing rooted immobility, grounded base, and enduring emotional weather with unwavering stability.
   - **Mindful Pause & Body Anchor** (`mindfulPause`): A rapid 3-step physical anchor routine (Stop, Drop attention into physical contact point, Breathe & soften posture).
2. Paced physiological settling stages with gentle, organic pulse aura visualizer (`SomaticVisualizerWidget` / `PulseAuraCustomPainter`) pulsing at a resting parasympathetic rhythm (~0.1 Hz) without abrupt shifts.
3. Offline ambient soundscape integration with optional toggle (using `cyclic_sigh_ambience.mp3` or `grounding_chime.mp3`), respecting user preference and failing safely offline.
4. Structured stage prompt cards with ≥ 56dp touch targets, soft haptic feedback, and smooth 300ms transitions.
5. Completely self-paced with optional unobtrusive soft elapsed timer; zero countdowns, zero scoring, and zero failure states.
6. Non-judgmental early exit ("That's enough for now") triggering post-session effectiveness rating via `EffectivenessFeedbackSheet`.
7. Seamless shell and root modal routing via `AppRoutes.somatic` (`/home/somatic?mode=...` and `/somatic`) with persistent SOS overlay protection.

## Boundaries & Constraints

**Always:**
- Keep all interactive touch targets ≥ 56dp.
- Adhere strictly to WCAG AA contrast (≥ 4.5:1) on dark canvas (`#111518`).
- Maintain zero network calls (`FireflyHttpOverride` strictly enforced).
- Support non-judgmental early exit ("That's enough for now") and stage skip without negative UI feedback.
- Prompt for post-session effectiveness rating via `EffectivenessFeedbackSheet` when ≥ 1 stage is completed.
- Ensure the SOS panic button is visible exactly once on any given screen (never duplicated, never obscured).
- Support reduced-motion preferences gracefully (static tranquil aura when reduced-motion is requested).

**Never:**
- Never display countdown timers, buzzers, streaks, or performance scores.
- Never force physical positions; provide adaptable cues for sitting, lying down, or standing.
- Never require cloud audio streams or external assets.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Select Somatic Mode | User selects "Heavy Body Gravity" | Controller loads 4 progressive gravity settling stages | Fallback to Heavy Body if unrecognized mode |
| Advance Stage | User taps "Step completed" | Haptic pulse fires, advances to next somatic stage with 300ms ease transition | Ignores rapid taps during transition |
| Skip Stage | User taps "Skip step" | Moves to next prompt without negative feedback or penalty | Gracefully reaches completion if last stage |
| Soundscape Toggle | User toggles ambient audio | Plays/pauses offline ambient soundscape via AudioPlayerPort | Silent graceful fallback if audio fails |
| Optional Soft Timer | User toggles soft timer | Displays elapsed minutes/seconds without countdown stress | Can be toggled on/off anytime |
| Early Exit | User taps "That's enough for now" | Completes exercise, triggers effectiveness rating if progress made, returns to previous route | Gracefully pops or routes to `/home/check-in` |

</frozen-after-approval>

## Code Map

- `lib/features/somatic/domain/models/somatic_exercise_mode.dart` -- Mode enum (4 modes) and metadata.
- `lib/features/somatic/domain/models/somatic_prompt.dart` -- Stage entity and curated offline prompt catalog.
- `lib/features/somatic/domain/models/somatic_session_state.dart` -- Immutable state tracking mode, stage index, audio state, elapsed timer, and completion.
- `lib/features/somatic/presentation/controllers/somatic_controller.dart` -- Riverpod controller managing somatic flow, audio, and timer.
- `lib/features/somatic/presentation/widgets/somatic_visualizer_widget.dart` -- Organic pulse aura custom painter visualizer.
- `lib/features/somatic/presentation/widgets/somatic_prompt_card.dart` -- Tactile prompt card with ≥ 56dp touch targets.
- `lib/features/somatic/presentation/widgets/somatic_mode_selector_sheet.dart` -- Low-stimulation bottom sheet to switch somatic modes.
- `lib/features/somatic/presentation/screens/somatic_centering_screen.dart` -- Main screen with shell/modal support, SOS overlay, and feedback sheet.
- `lib/core/routing/app_routes.dart` & `lib/core/routing/app_router.dart` -- Register `AppRoutes.somatic` (`/home/somatic`).
- `test/features/somatic/verify_somatic_centering_standalone.dart` -- Comprehensive standalone verification test suite.

## Tasks & Acceptance

**Execution:**
- [x] Author `SomaticExerciseMode`, `SomaticPrompt`, and offline prompt library in `lib/features/somatic/domain/models/`.
- [x] Author `SomaticSessionState` immutable state class with progress calculations.
- [x] Author `SomaticController` Riverpod state notifier in `lib/features/somatic/presentation/controllers/`.
- [x] Author `SomaticVisualizerWidget`, `SomaticPromptCard`, and `SomaticModeSelectorSheet` widgets.
- [x] Author `SomaticCenteringScreen` with mode initialization, audio toggle, timer toggle, SOS shield, and feedback dialog.
- [x] Register `AppRoutes.somatic` constant in `app_routes.dart` and wire routes in `app_router.dart`.
- [x] Add somatic centering activities to `curated_activities.json` and `ActivitySeedingService`.
- [x] Author and run standalone verification test suite `test/features/somatic/verify_somatic_centering_standalone.dart` (100% pass).
- [x] Run full regression suite across all features.
