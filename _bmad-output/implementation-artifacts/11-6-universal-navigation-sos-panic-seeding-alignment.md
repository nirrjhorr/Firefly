---
title: 'Universal Navigation, SOS Panic & Seeding Alignment (Story 11.6)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: '21b5216'
route: 'dispatch'
review_loop_iteration: 0
context:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/epics.md
  - _bmad-output/implementation-artifacts/epic-11-context.md
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Across Epic 10 and Epic 11, multiple self-regulation engines and sanctuaries were authored (PMR body map, Movement engine, Cognitive grounding, Sleep suite, Hope box vault, Loneliness comfort). However, navigation routes, SOS overlay encapsulation, Home screen quick-access cards, and the 13 acute distress anchors in `RightNowModal` were not fully consolidated, posing risks of route fragmentation, duplicate floating SOS panic buttons within bottom navigation shells, and disjointed offline activity seeding.

**Approach:** Execute comprehensive system-wide universal navigation, distress routing, and offline seeding alignment:
1. **RightNowModal Distress Fast-Path Alignment:**
   - Expanded `kRightNowAnchors` to 13 acute distress anchors, adding the canonical Hope Box distress entry (`losing_hope`: *"I need a reminder to hold on"* -> `/home/hope-box`).
   - Wired `overwhelmed` anchor to `/home/breathe?mode=grounding` to immediately activate 5-4-3-2-1 sensory grounding.
   - Added `'heart'` / `'favorite'` icon resolution in `_AnchorCard`.
2. **RecommendationEngine Deterministic Alignment:**
   - Defined `_hopeBoxSuggestion` and added it as an evidence-based alternative in loneliness and depressive affect states.
   - Consolidated `AppRoutes.loneliness` constant usage throughout recommendation logic.
3. **AppRouter SOS Panic & Shell Encapsulation:**
   - Ensured shell routes (`AppRoutes.hopeBox`, `AppRoutes.sleep`, `AppRoutes.loneliness`, `AppRoutes.pmr`, `AppRoutes.move`, `AppRoutes.cognitiveGrounding`) explicitly pass `showSosOverlay: false` to prevent duplicate panic buttons on top of `MainShellScaffold`'s persistent SOS button.
   - Preserved `showSosOverlay: true` for root modal routes (`/hope-box`, `/sleep`, `/loneliness`, `/pmr`, `/move`, `/cognitive-grounding`) with `_rootNavigatorKey`.
   - Added graceful redirect for `/home/ground` to `${AppRoutes.breathe}?mode=$mode`.
4. **Home (Check-In) Screen Quick Access:**
   - Added a serene, low-cognitive-load quick-access row on `CheckInScreen` below the Sound Sanctuary card, directly linking into the **Hope Box** (`AppRoutes.hopeBox`) and **Sleep Suite** (`AppRoutes.sleep`).
5. **Activity Seeding & Catalog Harmonization:**
   - Aligned `curated_activities.json` routes for sensory grounding (`/home/breathe?mode=...`) and cognitive grounding (`/home/cognitive-grounding?mode=...`).
   - Expanded `ActivitySeedingService` hardcoded fallback catalog to include all core v2 engines (Hope Box, Sleep, Cognitive Grounding, Somatic Shakeout, and Social Reach-Out).
6. **Comprehensive Standalone Verification:**
   - Built and passed `test/core/routing/verify_universal_navigation_standalone.dart` asserting 100% route validity, zero network compliance, and modal/shell alignment.

## Boundaries & Constraints

**Always:**
- Keep all interactive touch targets ≥ 56dp.
- Adhere strictly to WCAG AA contrast (≥ 4.5:1) against `#111518` dark canvas.
- Maintain zero network calls (`FireflyHttpOverride` strictly enforced).
- Ensure the SOS panic button is visible exactly once on any given screen (never duplicated, never obscured).
- Support instant `< 100ms` emergency panic blanking and cryptographic key wipe.

**Never:**
- Never duplicate floating buttons or create layout collisions.
- Never hardcode raw string routes where `AppRoutes` constants exist.
- Never make activity access contingent on completing questionnaires or multi-step surveys.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Acute distress anchor tap | User selects "I need a reminder to hold on" in RightNowModal | Dismisses modal, routes to `/home/hope-box` | Direct push without network dependency |
| Overwhelm distress tap | User selects "I feel overwhelmed" | Dismisses modal, opens Breathing/Grounding screen with 5-4-3-2-1 mode active | Seamless parameter passing |
| Home Screen Quick Access | User taps Hope Box or Sleep Suite card on CheckIn screen | Navigates to corresponding feature with bottom nav intact | Zero layout disruption |
| Shell Navigation | User browses activities within shell | Single SOS button at bottom-right of shell; screen-internal SOS buttons disabled | `showSosOverlay: false` enforced |
| Full Modal Navigation | User navigates via root modal path | Modal displays internal SOS button | `showSosOverlay: true` on root navigator |
| Offline Asset Failure | Asset reading fails on first launch | `ActivitySeedingService` seeds complete 9-item fallback catalog covering all engines | Safe fallback with zero app crash |

</frozen-after-approval>

## Code Map

- `lib/core/routing/app_routes.dart` -- 20 canonical route constants.
- `lib/core/routing/app_router.dart` -- GoRouter configuration with root modals, shell routes, and SOS overlay safety flags.
- `lib/features/activities/presentation/widgets/right_now_modal.dart` -- 13 canonical distress anchors with Hope Box and grounding routing.
- `lib/core/recommendation_engine/recommendation_engine.dart` -- Pure deterministic recommendation engine with Hope Box alternative.
- `lib/features/check_in/presentation/screens/check_in_screen.dart` -- Home view with quick-access cards for Hope Box and Sleep Suite.
- `lib/features/activities/data/services/activity_seeding_service.dart` -- Offline seeding service with 9-item multi-engine fallback catalog.
- `assets/data/curated_activities.json` -- 54-item curated activity catalog with aligned routes across all 16 categories.
- `test/core/routing/verify_universal_navigation_standalone.dart` -- Comprehensive standalone verification suite.

## Tasks & Acceptance

**Execution:**
- [x] Align `kRightNowAnchors` and icon mappings in `right_now_modal.dart` (including Hope Box `losing_hope` anchor).
- [x] Align `RecommendationEngine` routes and add `_hopeBoxSuggestion` to alternatives.
- [x] Configure `app_router.dart` to prevent duplicate SOS overlays in shell routes and add `/home/ground` legacy redirect.
- [x] Integrate Hope Box and Sleep Suite quick-access cards into `CheckInScreen`.
- [x] Expand `ActivitySeedingService` fallback catalog to cover all v2 activity engines.
- [x] Align routes in `curated_activities.json`.
- [x] Author and run `test/core/routing/verify_universal_navigation_standalone.dart` (100% pass).
- [x] Run full standalone test suite across all features with zero regressions.
- [x] Update documentation and sprint artifacts.
