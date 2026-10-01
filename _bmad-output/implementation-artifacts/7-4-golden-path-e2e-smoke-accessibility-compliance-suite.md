---
title: 'Story 7.4: Golden Path E2E Smoke & Accessibility Compliance Suite'
type: 'feature'
created: '2026-10-01'
status: 'done'
route: 'oneshot'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** To prepare Firefly for production and physical test device deployment, the complete golden path (Affect Check-In → Recommendation Card → Navigation → Intervention Execution → Return) must be verified through end-to-end smoke testing, and accessibility guidelines (screen reader accessibility tree, touch target minimums ≥ 56dp / 72dp, WCAG AA contrast ratios) must be strictly enforced.

**Approach:**
1. Create `test/features/e2e_golden_path_accessibility_test.dart` to simulate the full user journey:
   - Check-in mood anchor selection and energy slider submission.
   - Dynamic recommendation card rendering (`AffectResultCard`) and resetting.
   - Screen reader tree semantics verification on safety and panic triggers.
   - Touch target dimensions audit across interactive components (SOS overlay ≥ 56dp, Tiny Steps cards ≥ 72dp).
   - WCAG AA contrast ratio mathematical verification between text tokens and dark canvas (`#111518`).

</frozen-after-approval>

## Implementation Notes

- **End-to-End Golden Path Smoke Test**:
  - Implemented in `test/features/e2e_golden_path_accessibility_test.dart`.
  - Simulates complete check-in workflow: selecting mood anchor, submitting evaluation, rendering matched recommendation, and verifying state reset.

- **Accessibility & Trauma-Informed Compliance**:
  - Validated that `SosOverlayButton` provides exact 56x56dp minimum touch target.
  - Verified `Semantics` label and hint bindings on `SosOverlayButton` for TalkBack / VoiceOver screen readers.
  - Confirmed `AppColors.textPrimary` over `AppColors.canvasDeep` (`#111518`) exceeds WCAG AA 4.5:1 contrast requirements.

## Review Triage Log
- None. All acceptance criteria satisfied and verified.
