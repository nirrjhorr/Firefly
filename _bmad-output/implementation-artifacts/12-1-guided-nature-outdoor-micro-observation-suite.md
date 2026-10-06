---
title: 'Guided Nature & Outdoor Micro-Observation Suite (Story 12.1)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: '2343f45'
route: 'dispatch'
review_loop_iteration: 0
context:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/epics.md
  - research data/Activity_Architecture.md
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** When a user is in acute distress, emotional overwhelm, or rumination, internal sensory attention can feed threat spirals. Shifting attention outward to natural and environmental phenomena (sky gazing, tree canopies, shifting light and shadows, ambient weather) activates the parasympathetic nervous system and broadens visual attention (open monitoring) without requiring complex cognitive performance. Mainstream apps often bury nature grounding behind high-bandwidth video downloads or multi-step questionnaires.

**Approach:** Build a dedicated, lightweight, 100% offline Nature & Outdoor Micro-Observation Suite for Firefly:
1. Provide 5 distinct evidence-based observation modes:
   - **Sky & Cloud Gazing** (`skyGazing`): Broadening visual field and noticing sky gradient and cloud flow.
   - **Tree Canopy & Leaves** (`treeCanopy`): Observing branch fractal patterns, leaf motion, and organic green hues.
   - **Light & Shadow Play** (`lightAndShadow`): Attending to high/low contrast edges, sunbeam angles, and ambient illumination.
   - **Outdoor Sensory Grounding** (`outdoorGrounding`): Tactile contact with earth, ambient breeze, temperature on skin.
   - **Weather & Atmosphere** (`weatherNotice`): Attending to rain sound/rhythm, wind velocity, humidity, or atmospheric settling.
2. Structured observational prompt cards with ≥ 56dp interactive touch targets, soft haptic feedback, and smooth 300ms transitions.
3. Completely self-paced with optional tranquil soft timer; zero scoring, zero count-down pressure, and zero failure states.
4. Non-judgmental early exit ("That's enough for now") triggering post-session effectiveness rating via `EffectivenessFeedbackSheet`.
5. Seamless shell and root modal routing via `AppRoutes.nature` (`/home/nature?mode=...`) with persistent SOS overlay protection.

## Boundaries & Constraints

**Always:**
- Keep all interactive touch targets ≥ 56dp.
- Adhere strictly to WCAG AA contrast (≥ 4.5:1) on dark canvas (`#111518`).
- Maintain zero network calls (`FireflyHttpOverride` strictly enforced).
- Support non-judgmental early exit ("That's enough for now") and stage skip without negative UI feedback.
- Prompt for post-session effectiveness rating via `EffectivenessFeedbackSheet` when ≥ 1 observation prompt is completed.
- Ensure the SOS panic button is visible exactly once on any given screen (never duplicated, never obscured).

**Never:**
- Never display countdown timers, buzzers, streaks, or performance scores.
- Never force outdoor presence; every prompt must provide an indoor window / ceiling / potted plant alternative.
- Never require camera, GPS location, or internet access to observe nature.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Select Nature Mode | User selects "Sky & Cloud Gazing" | Controller loads 4 sky observation prompts with broad horizon focus | Fallback to Sky Gazing if unrecognized mode |
| Advance Observation | User taps "I noticed" / "Next step" | Haptic tick fires, advances to next prompt card with 300ms ease transition | Ignores rapid taps during transition |
| Indoor Fallback | User is indoors unable to step out | Each prompt explicitly guides looking through a window, at a houseplant, or noticing daylight on a wall | Zero friction or guilt |
| Skip Prompt | User taps "Skip step" | Moves to next observation prompt without penalty | Gracefully reaches completion if last prompt |
| Optional Soft Timer | User toggles soft timer | Displays unobtrusive elapsed seconds counter without ticking sound or countdown stress | Can be paused or hidden anytime |
| Early Exit | User taps "That's enough for now" | Completes exercise, triggers effectiveness rating if progress made, returns to previous route | Gracefully pops or routes to `/home/check-in` |

</frozen-after-approval>

## Code Map

- `lib/features/nature/domain/models/nature_observation_mode.dart` -- Mode enum (5 modes) and metadata.
- `lib/features/nature/domain/models/nature_prompt.dart` -- Prompt entity and curated offline prompt catalog.
- `lib/features/nature/domain/models/nature_session_state.dart` -- Immutable state tracking mode, step, elapsed timer, and completion.
- `lib/features/nature/presentation/controllers/nature_controller.dart` -- Riverpod controller managing observation flow and timer.
- `lib/features/nature/presentation/widgets/nature_mode_selector_sheet.dart` -- Low-stimulation bottom sheet to switch observation modes.
- `lib/features/nature/presentation/widgets/nature_prompt_card.dart` -- Tactile prompt card with ≥ 56dp touch targets.
- `lib/features/nature/presentation/screens/nature_observation_screen.dart` -- Main screen with shell/modal support, SOS overlay, and feedback sheet.
- `lib/core/routing/app_routes.dart` & `lib/core/routing/app_router.dart` -- Register `AppRoutes.nature` (`/home/nature`).
- `test/features/nature/verify_nature_observation_standalone.dart` -- Comprehensive standalone verification test suite.

## Tasks & Acceptance

**Execution:**
- [x] Author `NatureObservationMode`, `NaturePrompt`, and offline prompt library in `lib/features/nature/domain/models/`.
- [x] Author `NatureSessionState` immutable state class with progress calculations.
- [x] Author `NatureController` Riverpod state notifier in `lib/features/nature/presentation/controllers/`.
- [x] Author `NaturePromptCard` and `NatureModeSelector` widgets with accessible touch targets.
- [x] Author `NatureObservationScreen` with mode initialization, timer toggle, SOS shield, and feedback dialog.
- [x] Register `AppRoutes.nature` constant in `app_routes.dart` and wire route in `app_router.dart`.
- [x] Add nature activities to `curated_activities.json` and `ActivitySeedingService`.
- [x] Author and run standalone verification test suite `test/features/nature/verify_nature_observation_standalone.dart` (100% pass).
- [x] Run full regression suite across all features.
