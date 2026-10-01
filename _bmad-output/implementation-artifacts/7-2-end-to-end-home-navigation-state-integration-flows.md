---
title: 'Story 7.2: End-to-End Home Navigation & State Integration Flows'
type: 'feature'
created: '2026-10-01'
status: 'done'
route: 'oneshot'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** The recommendation engine routes affect check-in states to distinct intervention screens (`/home/breathe`, `/home/tiny-steps`, `/home/journal`, `/home/loneliness`, `/safety-plan`). However, `/home/loneliness` was unmapped in the route tree, `/home` lacked a redirect fallback to `/home/check-in`, and state preservation across deep links and configuration changes was not configured.

**Approach:**
1. Create `LonelinessComfortScreen` in `lib/features/loneliness_comfort/presentation/screens/loneliness_comfort_screen.dart` with low-stimulation cards for audio soundscapes, safety plan contacts with reach-out templates, and unsent letters.
2. Wire `AppRoutes.loneliness` into `app_router.dart` inside the `MainShellScaffold` route tree.
3. Add `/home` fallback redirect to `AppRoutes.checkIn` in `app_router.dart`.
4. Add `restorationScopeId: 'firefly_router'` to GoRouter for proper process death and configuration change state restoration.
5. Create comprehensive integration tests in `test/features/navigation/e2e_navigation_integration_test.dart`.

</frozen-after-approval>

## Implementation Notes

- **Loneliness Comfort Module**:
  - Implemented `lib/features/loneliness_comfort/presentation/screens/loneliness_comfort_screen.dart` featuring calm trauma-informed UI (`#111518`), leading back button, and quick-action cards pushing to Breathing, Safety Plan, and Unsent Letters.
  - Linked to GoRouter under `AppRoutes.loneliness`.

- **Router Enhancements & State Restoration**:
  - Configured `restorationScopeId: 'firefly_router'` on `appRouterProvider` in `lib/core/routing/app_router.dart`.
  - Added redirect from `AppRoutes.home` (`/home`) to `AppRoutes.checkIn` (`/home/check-in`) to guarantee reliable back navigation and deep-linking resilience.

- **Verification & Test Coverage**:
  - Created `test/features/navigation/e2e_navigation_integration_test.dart` verifying:
    - Pure deterministic recommendation engine evaluation for all 5 affect priority bands.
    - `AffectResultCard` navigation push dispatching.
    - `LonelinessComfortScreen` rendering, options, and safe return transitions.

## Review Triage Log
- None. All acceptance criteria satisfied and verified.
