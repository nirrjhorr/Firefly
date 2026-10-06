---
title: 'Story 14.1: Encrypted Worry Dump & Unsent Letters Integration (FR-15 / Epic 14)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: '585c873'
route: 'dispatch'
review_loop_iteration: 0
context: ['_bmad-output/planning-artifacts/epics.md', 'research data/Activity_Architecture.md']
---

## Intent

**Problem:** While basic encrypted journaling was established in Epic 6, it remained isolated from the v2 Unified Activity Architecture and lacked direct modal routing for emergency emotional unburdening. Users in moments of acute overwhelm or pre-bed anxiety need immediate one-tap access to cathartic writing tools ("Unsent Letters" for difficult unsent words and "Worry Dump" for nighttime rumination) with persistent SOS overlay protection and post-session effectiveness tracking.

**Approach:** Complete Story 14.1 by integrating the Encrypted Worry Dump and Unsent Letters suite into the v2 architecture:
1. Dedicated route constants (`AppRoutes.unsentLetter` and `AppRoutes.worryDump`).
2. Root modal routes (`/unsent-letter` and `/worry-dump`) with `SosOverlayButton` support and shell routes (`/home/unsent-letter` and `/home/worry-dump`).
3. Enhanced `JournalEntryScreen` with mode-sensitive header prompts, tactile "That's enough" exit, and post-burn `EffectivenessFeedbackSheet` invocation.
4. Extracted `JournalTtlOption` into a clean domain model (`lib/features/journaling/domain/models/journal_ttl_option.dart`).
5. Seeded fallback catalog in `ActivitySeedingService` with `act_unsent_letter` and `act_worry_dump` under `ActivityCategory.emotionalExpression`.
6. Verified with standalone test suite in `test/features/journaling/verify_worry_unsent_standalone.dart`.

## Acceptance Criteria Verification

- [x] Dedicated modal routes `/unsent-letter` and `/worry-dump` registered in `app_router.dart` with `parentNavigatorKey: _rootNavigatorKey` and SOS floating overlay.
- [x] Shell navigation routes `/home/unsent-letter` and `/home/worry-dump` wired cleanly in `MainShellScaffold`.
- [x] Mode-specific banners and prompt guidance rendered without cognitive friction.
- [x] Immediate cryptographic zeroing ("Burn Now") triggers post-burn `EffectivenessFeedbackSheet` for personal regulation tracking.
- [x] Decoupled `JournalTtlOption` enum into pure domain models.
- [x] Validated via `test/features/journaling/verify_worry_unsent_standalone.dart` with 100% assertions passing.

## Code Artifacts

- `lib/core/routing/app_routes.dart`
- `lib/core/routing/app_router.dart`
- `lib/features/journaling/domain/models/journal_ttl_option.dart`
- `lib/features/journaling/presentation/controllers/journal_editor_controller.dart`
- `lib/features/journaling/presentation/screens/journal_entry_screen.dart`
- `lib/features/activities/data/services/activity_seeding_service.dart`
- `test/core/routing/verify_routing_standalone.dart`
- `test/features/journaling/verify_worry_unsent_standalone.dart`
