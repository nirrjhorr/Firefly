---
title: 'Story 13.2: Flow & Spatial Puzzles Integration (FR-15 / Epic 13)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: '32b4e40'
route: 'dispatch'
review_loop_iteration: 0
context: ['_bmad-output/planning-artifacts/epics.md', 'research data/Activity_Architecture.md']
---

## Intent

**Problem:** Users experiencing racing thoughts, rumination loops, or acute restless energy need low-pressure activities that engage working memory and spatial cognition to interrupt invasive thought patterns. Mainstream mobile puzzle games are laden with countdown clocks, move penalties, high-contrast ad flashing, and score gamification that induce cognitive anxiety or defeat states.

**Approach:** Implement a dedicated Flow & Spatial Puzzles suite designed specifically around non-clinical self-regulation principles. Provide two gentle modalities:
1. **Constellation Star Flow:** Interactive celestial connect-the-dots canvas with 6 curated patterns (Cassiopeia, Corona Borealis, Cygnus Swan, Pleiades, Lotus Blossom, River Pebble), luminous glowing paths, and subtle starfield ambiance.
2. **Harmony Sliding Tiles:** A soothing 3x3 tactile sliding tile grid with guaranteed solvable configurations (`shuffleSolvable`), clean stone card aesthetics, and zero move limits or failure alerts.

Both modalities feature touch targets ≥ 56dp, high-contrast low-stimulation color palettes, soft tactile haptics, non-judgmental early exit ("That's enough for now"), and post-session effectiveness tracking via `EffectivenessFeedbackSheet`.

## Acceptance Criteria Verification

- [x] Canvas-based puzzle UI for Constellation Flow and tactile 3x3 Harmony Tiles.
- [x] Accessible touch targets (≥ 56dp per tile/node) and WCAG AA contrast against `#111518`.
- [x] Zero countdown timers, move limits, error buzzers, or score tracking.
- [x] Solvable sliding tile generator without permutation parity traps.
- [x] 6 curated peaceful celestial and organic constellation patterns.
- [x] Full integration into `AppRoutes`, `AppRouter` (shell and modal routes with persistent SOS overlay protection), `curated_activities.json`, and `ActivitySeedingService`.
- [x] Standalone verification suite in `test/features/flow_puzzle/verify_flow_puzzle_standalone.dart` passing 100%.

## Code Map

- `lib/features/flow_puzzle/domain/models/flow_puzzle_type.dart`
- `lib/features/flow_puzzle/domain/models/constellation_pattern.dart`
- `lib/features/flow_puzzle/domain/models/sliding_grid_state.dart`
- `lib/features/flow_puzzle/domain/models/flow_puzzle_session_state.dart`
- `lib/features/flow_puzzle/presentation/controllers/flow_puzzle_controller.dart`
- `lib/features/flow_puzzle/presentation/widgets/constellation_canvas_widget.dart`
- `lib/features/flow_puzzle/presentation/widgets/sliding_tile_grid_widget.dart`
- `lib/features/flow_puzzle/presentation/widgets/flow_puzzle_mode_sheet.dart`
- `lib/features/flow_puzzle/presentation/screens/flow_puzzle_screen.dart`
- `lib/core/routing/app_routes.dart`
- `lib/core/routing/app_router.dart`
- `assets/data/curated_activities.json`
- `lib/features/activities/data/services/activity_seeding_service.dart`
- `test/features/flow_puzzle/verify_flow_puzzle_standalone.dart`
