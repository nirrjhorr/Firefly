---
title: "Story 10.2: 'Right Now' Immediate Distress Fast-Path Modal & Routing"
type: 'feature'
created: '2026-10-05'
status: 'done'
route: 'dispatch'
review_loop_iteration: 0
context: ['_bmad-output/planning-artifacts/prd.md', 'research data/Activity_Architecture.md']
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** When a user is in acute emotional distress (e.g. sudden panic, paralyzing overwhelm, or intense racing thoughts), executive dysfunction makes completing a 5-step affect check-in frustrating and cognitively overwhelming.

**Approach:** Implement a 1-tap prominent distress button on the Home screen that opens a low-stimulation modal (`#111518`) with 12 plain-language need anchors, dispatching immediately (< 5ms) to the matched regulation exercise.

## Boundaries & Constraints

**Always:**
- 100% offline, zero network requests, zero analytics or tracking.
- Touch targets on all anchor cards must meet or exceed 56dp.
- Modal opens in < 50ms and dispatches immediately without blocking UI thread.
- Full compatibility with the persistent SOS shield overlay.

**Never:**
- No clinical or diagnostic language.
- No mandatory fields, score counters, or guilt feedback when dismissing.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| User taps "Need something right now?" | Tap button on CheckInScreen | Opens `RightNowModal` with 12 anchors in < 50ms | N/A |
| User taps "I need to calm down" | Tap anchor 1 | Closes modal and navigates to `/home/breathe` | N/A |
| User taps "I want to connect" | Tap anchor 11 | Closes modal and navigates to `/home/loneliness` | N/A |
| User closes modal | Tap close or drag handle | Closes modal smoothly, returns to CheckInScreen | N/A |

</frozen-after-approval>

## Code Map

- `lib/features/activities/presentation/widgets/right_now_modal.dart` -- `RightNowModal` widget and 12 `RightNowAnchor` definitions
- `lib/features/check_in/presentation/screens/check_in_screen.dart` -- Fast-path trigger banner on Home screen
- `lib/core/routing/app_routes.dart` -- Route constants

## Tasks & Acceptance

**Execution:**
- [x] `lib/features/activities/presentation/widgets/right_now_modal.dart` -- Create `RightNowModal` and `kRightNowAnchors` with 12 plain-language anchors.
- [x] `lib/features/check_in/presentation/screens/check_in_screen.dart` -- Add prominent *"Need something right now?"* button before mood anchor.
- [x] `test/features/activities/right_now_modal_test.dart` -- Unit tests validating all 12 anchors and routing mappings.

**Acceptance Criteria:**
- Given the CheckInScreen, when viewing the top area, a prominent "Need something right now?" card is visible.
- Given the RightNowModal, when opened, exactly 12 discrete distress anchors are displayed with icons and descriptions.
- Given any anchor card, when tapped, haptic feedback triggers and the app navigates immediately to the matched route.

## Implementation Notes

- Designed `RightNowModal` as an Apple-inspired bottom sheet with dark canvas (`#111518`), smooth drag handle, and clear touch affordances.
- Implemented `kRightNowAnchors` containing the 12 canonical anchors specified in FR-10.
- Integrated the entry banner into `CheckInScreen` with subtle sage accent border and icon indicator.
- Unit tests verify all 12 anchors have valid titles, non-empty routes starting with `/`, and accurate feature destinations.
