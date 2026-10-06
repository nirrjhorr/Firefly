---
title: 'Story 15.2: Social Connection & Cooperative Activities (Epic 15 / FR-06 / RM-02)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: '9ba5b18'
route: 'dispatch'
review_loop_iteration: 0
context: ['_bmad-output/planning-artifacts/epics.md', 'research data/Activity_Architecture.md']
---

## Intent

**Problem:** Acute loneliness and social withdrawal create a painful paradox: individuals desperately need co-regulation and human warmth, yet social anxiety, fear of being a burden, and cognitive distortions ("They don't want to hear from me", "It will be awkward") inhibit reaching out. Demanding conversational interactions can also exhaust depleted nervous systems.

**Approach:** Implement a comprehensive Social Connection and Cooperative Activities suite within `LonelinessComfortScreen`:
1. **Cooperative Activities & Low-Pressure Rituals:** Introduce evidence-informed connection models from Activity Architecture Section 3.6:
   - **Parallel Quiet ("Sit with someone"):** Shared co-presence without conversation pressure or performance expectations.
   - **Appreciation Micro-Note:** Unsolicited tiny gratitude message explicitly removing reply pressure ("Thinking of you, no need to reply").
   - **Cooperative Low-Stakes Games:** Curated collaborative games (The Mind, Hanabi, Forbidden Island, shared jigsaws, collaborative word puzzles) that foster non-competitive teamwork.
   - **Low-Barrier Support:** Structured requests for simple co-presence during everyday tasks (making tea, doing one task).
2. **Pre-Written Social Invitations:** Calibrated SMS message templates for each cooperative activity that can be dispatched immediately to supportive contacts from `SafetyPlanContactsDao` or custom contacts.
3. **"Guess vs. Reality" Experiment Integration:** Fully integrated with the cognitive behavioral prediction experiment engine and SQLite persistence to dismantle negative social predictions through empirical tracking.
4. **Offline First & Privacy Safe:** 100% offline using native `url_launcher` SMS intents without analytics, external telemetry, or network exposure.

## Acceptance Criteria Verification

- [x] Domain model `CooperativeActivity` with curated low-pressure activity modes and suggested cooperative games.
- [x] Extended reach-out template catalogue covering parallel quiet, appreciation notes, cooperative gaming, and gentle support.
- [x] `CooperativeActivitiesSection` widget in `LonelinessComfortScreen` providing expandable detail cards and one-tap invite triggers.
- [x] Direct coupling between cooperative invites, contact selection, "Guess vs. Reality" prediction logging, and offline SMS intent launch.
- [x] Catalog alignment in `curated_activities.json` and `ActivitySeedingService`.
- [x] Standalone test runner (`test/features/loneliness_comfort/verify_cooperative_activities_standalone.dart`) passing with 100% assertions.

## Code Artifacts

- `lib/features/loneliness_comfort/domain/models/cooperative_activity.dart`
- `lib/features/loneliness_comfort/domain/models/loneliness_comfort_state.dart`
- `lib/features/loneliness_comfort/presentation/widgets/reach_out_message_dialog.dart`
- `lib/features/loneliness_comfort/presentation/widgets/cooperative_activities_section.dart`
- `lib/features/loneliness_comfort/presentation/screens/loneliness_comfort_screen.dart`
- `lib/features/activities/data/services/activity_seeding_service.dart`
- `test/features/loneliness_comfort/verify_cooperative_activities_standalone.dart`
