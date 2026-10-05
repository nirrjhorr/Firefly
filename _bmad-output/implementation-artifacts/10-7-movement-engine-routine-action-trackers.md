---
title: 'Story 10.7: Movement Engine & Routine Action Trackers'
type: 'feature'
created: '2026-10-06'
status: 'done'
route: 'dispatch'
review_loop_iteration: 0
context: ['_bmad-output/planning-artifacts/prd.md', 'research data/Activity_Architecture.md', '_bmad-output/planning-artifacts/epics.md']
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Users carrying somatic restlessness, low energy, or psychomotor agitation lacked a dedicated active movement and somatic regulation interface to guide physical discharge (shakeout, wall pushups, stroll) and low-barrier routine actions with pacing cadence and post-activity feedback.

**Approach:** Implement `MovementEngineScreen` at `/home/move`, supported by a clean Riverpod session controller, an organic low-stimulation visual pulse ring (`MovementPulseRing`) synchronized to activity cadence (BPM), a 10-activity evidence-based movement catalog, and post-session settlement feedback logging to Drift DB.

## Boundaries & Constraints

**Always:**
- 100% offline, zero network requests, complying with `FireflyHttpOverride`.
- Low-stimulation palette (`#111518` background, `#4A7862` sage action tokens, high contrast WCAG AA).
- Minimum touch targets ≥ 56dp for all interactive buttons.
- Synchronized tactile haptics on start, half-way interval, and completion.
- Emergency SOS overlay button persisted with < 100ms panic blanking.

**Never:**
- No gamification, streaks, countdown buzzers, or failure messages.
- No mandatory completion — users can pause, reset, or tap "That's enough for now" at any time.

## Code Map

- `lib/features/movement/domain/models/movement_activity.dart` -- Core domain entity and `MovementType` enum.
- `lib/features/movement/domain/models/movement_session_state.dart` -- Immutable session state with progress and timing calculations.
- `lib/features/movement/domain/data/movement_catalog.dart` -- Curated library of 10 evidence-based movement and routine action activities.
- `lib/features/movement/presentation/controllers/movement_session_controller.dart` -- Riverpod `StateNotifier` managing timer ticks, cadence, and haptic feedback.
- `lib/features/movement/presentation/widgets/movement_pulse_ring.dart` -- Low-stimulation circular progress ring with rhythmic pulsing.
- `lib/features/movement/presentation/screens/movement_engine_screen.dart` -- Complete movement screen with category switching, step guidance, sensory anchor callouts, and SOS shield.
- `lib/core/routing/app_routes.dart` -- Added `AppRoutes.move = '/home/move'`.
- `lib/core/routing/app_router.dart` -- Registered `/move` root modal route and `/home/move` shell route, supporting `?mode=` query parameters.
- `test/features/movement/verify_movement_standalone.dart` -- Automated standalone verification suite for all models, catalogs, and state transitions.

## Tasks & Acceptance

**Execution:**
- [x] Create `MovementActivity` domain model and `MovementType` enum (`activePhysical`, `somaticRelease`, `routineAction`, `tactileFocus`).
- [x] Create `MovementSessionState` and `MovementSessionStatus`.
- [x] Create `MovementCatalog` with 10 evidence-based activities (shakeout, wall pushups, stroll, shoulder rolls, marching, progressive stretch, jaw release, drink water, open curtains, cool splash).
- [x] Create `MovementSessionController` with periodic timer, pause/resume, step switching, and milestone haptics.
- [x] Create `MovementPulseRing` with BPM-synchronized gentle breathing pulse and progress display.
- [x] Create `MovementEngineScreen` with tabbed category filtering, step-by-step guidance cards, and sensory anchors.
- [x] Wire post-session feedback dialog (`EffectivenessFeedbackSheet.show`) to log outcomes to encrypted SQLite.
- [x] Register routes in `app_routes.dart` and `app_router.dart`.
- [x] Update `RightNowModal` to link `restless` anchor to `/home/move?mode=shakeout`.
- [x] Author and run `test/features/movement/verify_movement_standalone.dart` (100% passing).

</frozen-after-approval>
