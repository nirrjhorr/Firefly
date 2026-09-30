# Story 2.6: SOS Floating Overlay & Fast Panic Exit Mechanism

Status: done

## Story Description
As a user needing immediate safety or immediate privacy,
I want 1-tap SOS access from any screen and a rapid panic exit sequence (< 100ms) on long-press,
So that I can get help instantly or blank the app and lock my data if someone approaches.

## Acceptance Criteria
1. Persistent `SosOverlayButton` is accessible from all primary views.
2. Single-tap routes instantly to `AppRoutes.safetyPlan`.
3. Long-press (≥ 600ms) triggers Panic Sequence:
   - Navigates immediately to `PanicBlankScreen` (`#000000` pitch black).
   - Drops encryption key reference via `BiometricGuard.lockApp()`.
   - Clears memory state.
   - Triggers `SystemNavigator.pop()` or backgrounding.
