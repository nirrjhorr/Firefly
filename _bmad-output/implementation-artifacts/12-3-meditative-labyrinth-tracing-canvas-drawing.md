---
title: 'Meditative Labyrinth Tracing & Canvas Drawing (Story 12.3)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: '229ee70'
route: 'dispatch'
review_loop_iteration: 0
context:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/epics.md
  - research data/Activity_Architecture.md
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** During moments of mental racing, emotional turbulence, or restless somatic energy, cognitive grounding tasks (e.g. arithmetic or verbal lists) can feel too demanding, while passive breathing exercises can feel claustrophobic or frustrating. Traditional finger labyrinths have been used for centuries as kinesthetic, contemplative meditation tools: the slow, continuous, non-competitive motor tracking of a geometric path engages visuomotor focus, discharges motor agitation, and induces rhythmic bilateral parasympathetic settling. Mainstream apps typically lack physical motor tracing or turn them into scored, fast-paced puzzle games with failure states.

**Approach:** Build a dedicated, 100% offline Meditative Labyrinth Tracing & Drawing Suite for Firefly:
1. Provide 4 geometric contemplative tracing patterns:
   - **Classical Cretan Labyrinth** (`classical`): Unicursal, single non-branching path winding inward to a calm center.
   - **Concentric Archimedean Spiral** (`spiral`): Continuous inward spiral drawing attention toward center stillness.
   - **Infinity Loop** (`infinity`): Smooth, flowing figure-8 rhythmic bilateral motor regulation.
   - **Meander Pathway** (`meander`): Rhythmic geometric waves providing steady, metered tactile rhythm.
2. Interactive `CustomPainter` with smooth touch tracking:
   - Real-time touch location rendering with soft luminous aura and trailing wake.
   - Zero wall collision punishments, zero wrong turns, zero timers, zero scoreboards.
   - Subtle tactile haptic tick as the user traverses turns and approaches the center.
3. Option to toggle "Clear Canvas" to trace again, or switch patterns effortlessly.
4. Non-judgmental early exit ("That's enough for now") triggering post-session effectiveness rating via `EffectivenessFeedbackSheet`.
5. Seamless shell and root modal routing via `AppRoutes.labyrinth` (`/home/labyrinth?pattern=...` and `/labyrinth`) with persistent SOS overlay protection.

## Boundaries & Constraints

**Always:**
- Keep all interactive touch targets ≥ 56dp.
- Adhere strictly to WCAG AA contrast (≥ 4.5:1) on dark canvas (`#111518`).
- Maintain zero network calls (`FireflyHttpOverride` strictly enforced).
- Support non-judgmental early exit ("That's enough for now") and stage skip without negative UI feedback.
- Prompt for post-session effectiveness rating via `EffectivenessFeedbackSheet` when tracing is completed.
- Ensure the SOS panic button is visible exactly once on any given screen (never duplicated, never obscured).
- Support reduced-motion preferences gracefully (static trail without motion distortion).

**Never:**
- Never display countdown timers, game overs, buzzers, scores, or time pressure.
- Never penalize off-path straying; gently encourage unhurried movement.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Select Pattern | User selects "Infinity Loop" | Controller loads mathematical curve points for Infinity loop | Fallback to Classical if unknown pattern |
| Pan on Canvas | User drags finger along path | Trail draws smoothly with glowing head, fires subtle haptic pulses on turn nodes | Ignores multi-touch jitter |
| Reach Center | User reaches labyrinth center | Soft glowing bloom pulse at center, quiet completion acknowledgment | Can reverse or retrace immediately |
| Clear Canvas | User taps "Retrace" | Resets current trail while preserving selected pattern | Clean redraw without flash |
| Early Exit | User taps "That's enough for now" | Completes exercise, triggers effectiveness rating if progress made, returns to previous route | Gracefully pops or routes to `/home/check-in` |

</frozen-after-approval>

## Code Map

- `lib/features/labyrinth/domain/models/labyrinth_pattern_type.dart` -- Pattern enum (4 types) and mathematical curve generators.
- `lib/features/labyrinth/domain/models/labyrinth_session_state.dart` -- Immutable state tracking pattern, progress, trail points, and completion.
- `lib/features/labyrinth/presentation/controllers/labyrinth_controller.dart` -- Riverpod controller managing touch tracing, path calculation, and haptics.
- `lib/features/labyrinth/presentation/widgets/labyrinth_canvas_widget.dart` -- Interactive CustomPainter rendering path and luminous touch trail.
- `lib/features/labyrinth/presentation/widgets/labyrinth_pattern_selector_sheet.dart` -- Modal sheet to switch patterns.
- `lib/features/labyrinth/presentation/screens/labyrinth_screen.dart` -- Main screen with shell/modal support, SOS overlay, and feedback sheet.
- `lib/core/routing/app_routes.dart` & `lib/core/routing/app_router.dart` -- Register `AppRoutes.labyrinth` (`/home/labyrinth`).
- `test/features/labyrinth/verify_labyrinth_standalone.dart` -- Standalone verification test suite.

## Tasks & Acceptance

**Execution:**
- [x] Author `LabyrinthPatternType` and parametric curve generators in `lib/features/labyrinth/domain/models/`.
- [x] Author `LabyrinthSessionState` immutable state class with progress calculations.
- [x] Author `LabyrinthController` Riverpod state notifier in `lib/features/labyrinth/presentation/controllers/`.
- [x] Author `LabyrinthCanvasWidget` interactive canvas with smooth touch tracking and luminous trail painter.
- [x] Author `LabyrinthPatternSelectorSheet` widget with accessible touch targets.
- [x] Author `LabyrinthScreen` with pattern initialization, clear canvas action, SOS shield, and feedback dialog.
- [x] Register `AppRoutes.labyrinth` constant in `app_routes.dart` and wire routes in `app_router.dart`.
- [x] Add labyrinth activities to `curated_activities.json` and `ActivitySeedingService`.
- [x] Author and run standalone verification test suite `test/features/labyrinth/verify_labyrinth_standalone.dart` (100% pass).
- [x] Run full regression suite across all features.
