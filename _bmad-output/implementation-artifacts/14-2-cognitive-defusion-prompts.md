---
title: 'Story 14.2: Cognitive Defusion Prompts & Thought Distance Suite (FR-15 / Epic 14)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: '585c873'
route: 'dispatch'
review_loop_iteration: 0
context: ['_bmad-output/planning-artifacts/epics.md', 'research data/Activity_Architecture.md']
---

## Intent

**Problem:** Users experiencing acute anxiety, catastrophic rumination, or depressive loops frequently experience cognitive fusion — identifying completely with transient intrusive thoughts ("I am broken", "I am failing", "I cannot cope"). Mainstream apps either attempt to aggressively challenge thoughts with clinical cognitive distortion logs (triggering shame and fatigue) or gamify distraction with timers. Acceptance and Commitment Therapy (ACT) provides empirical evidence that creating mindful psychological distance (defusion) diminishes autonomic reactivity without arguing with the thought.

**Approach:** Implement a dedicated, non-clinical Cognitive Defusion Suite (`CognitiveDefusionScreen`) delivering 3 evidence-supported defusion modalities:
1. **Leaves on a Stream (`leavesOnStream`):** An interactive dark water canvas where thoughts are placed onto autumn leaves drifting downstream on gentle river currents, drifting smoothly off-screen without struggle.
2. **Thought Cloud Dissolve (`thoughtClouds`):** A serene twilight sky canvas where thoughts appear inside drifting clouds and dissolve peacefully into mist upon tap or breath release.
3. **Thought Labelling & Distance (`thoughtLabeling`):** A structured 3-tier linguistic defusion step progression that systematically separates identity from thoughts:
   - Level 1: "I am failing."
   - Level 2: "I notice I am having the thought that I am failing."
   - Level 3: "I notice that my mind is giving me a story that I am failing, and I am here observing it."

All modalities include ≥ 56dp accessible touch targets, curated starter thoughts for cognitive fatigue relief, "That's enough for now" exit tied to `EffectivenessFeedbackSheet`, persistent SOS overlay protection, and full routing integration.

## Acceptance Criteria Verification

- [x] `CognitiveDefusionScreen` rendering interactive dark canvas (`#111518`), smooth 60fps drift progression, and low-stimulation palette.
- [x] 3 distinct evidence-based defusion modes (Leaves on a Stream, Thought Cloud Dissolve, Thought Labelling).
- [x] Interactive prompts guiding users to label thoughts or visualize them drifting away.
- [x] Zero gamification, timers, or error states.
- [x] Full integration into `AppRoutes.defusion`, `app_router.dart` (modal `/defusion` and shell `/home/defusion`).
- [x] Seeded into `assets/data/curated_activities.json` and `ActivitySeedingService` under `ActivityCategory.cognitiveDefusion`.
- [x] Verified via `test/features/cognitive_defusion/verify_cognitive_defusion_standalone.dart` with 100% assertions passing.

## Code Artifacts

- `lib/features/cognitive_defusion/domain/models/defusion_mode.dart`
- `lib/features/cognitive_defusion/domain/models/defusion_thought.dart`
- `lib/features/cognitive_defusion/domain/models/defusion_session_state.dart`
- `lib/features/cognitive_defusion/presentation/controllers/cognitive_defusion_controller.dart`
- `lib/features/cognitive_defusion/presentation/widgets/leaves_stream_canvas.dart`
- `lib/features/cognitive_defusion/presentation/widgets/thought_clouds_canvas.dart`
- `lib/features/cognitive_defusion/presentation/widgets/thought_labeling_card.dart`
- `lib/features/cognitive_defusion/presentation/widgets/defusion_mode_selector.dart`
- `lib/features/cognitive_defusion/presentation/screens/cognitive_defusion_screen.dart`
- `lib/core/routing/app_routes.dart`
- `lib/core/routing/app_router.dart`
- `assets/data/curated_activities.json`
- `lib/features/activities/data/services/activity_seeding_service.dart`
- `test/features/cognitive_defusion/verify_cognitive_defusion_standalone.dart`
