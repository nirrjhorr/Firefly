---
title: 'Loneliness Comfort & "Guess vs. Reality" Experiment (FR-06 / RM-02)'
type: 'feature'
created: '2026-10-06'
status: 'done'
baseline_commit: 'ecf42da'
route: 'dispatch'
review_loop_iteration: 0
context:
  - _bmad-output/planning-artifacts/prd.md
  - _bmad-output/planning-artifacts/epics.md
  - _bmad-output/implementation-artifacts/epic-11-context.md
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Loneliness intensifies because the perceived psychological cost and awkwardness of reaching out feels disproportionately high relative to the expected warmth of the response (Masi et al. 2011; Kumar & Epley 2023). Users in deep isolation avoid reaching out due to cognitive distortions ("They're too busy", "It'll be awkward", "They won't care"), reinforcing a cycle of withdrawal.

**Approach:** Implement a trauma-informed, 100% offline **Loneliness Comfort & "Guess vs. Reality" Behavioral Experiment Engine** (`#111518` canvas with sage `#84B09A` / amber `#E5B870` accents).
1. **"Someone's Here" Comfort Canvas:**
   - Deep canvas (`#111518`) with soothing reassuring typography: *"You don't have to feel this alone."* and *"What you're feeling is real. Others have been here too."*
   - Gentle ambient visual indicator (slow, peaceful pulse without clinical pressure).
2. **Reaching-Out Prompts & Contact Management (FR-06):**
   - Populated dynamically from Safety Plan trusted contacts (Steps 3 & 4) plus custom loneliness contacts.
   - Pre-written, user-customizable message templates grounded in communication research:
     - *"Hey — I've been thinking of you. How are you doing?"*
     - *"Hi — just wanted to check in. Can we talk?"*
     - *"I'm having a hard time and thought of you. Would you be up for a call?"*
   - Offline system SMS intent dispatch (`sms:<phone>?body=<encoded_text>`) with zero external network or telemetry calls.
   - Contextual dismissible psychoeducation: *"Research shows people almost always appreciate being reached out to more than we expect — even when we worry it's awkward."* (Kumar & Epley 2023).
3. **"Guess vs. Reality" Behavioral Experiment Flow (FR-06 / RM-02):**
   - Stage 1 (Prediction before sending): *"How do you think they'll respond?"* (Warmly / Neutral / Won't respond).
   - Stage 2 (Outcome logging upon return): *"What actually happened?"* (Warmly / Neutral / Won't respond).
   - Stage 3 (Non-judgmental validation):
     - Distant outcome: *"That's hard. It doesn't mean reaching out was wrong — it just didn't land today."*
     - Warm outcome: *"Notice how much warmer it was than the awkwardness you feared."*
   - Stage 4 (Aggregate Insights): After 3+ completed pairs, displays aggregate insight on prediction vs reality to dismantle social avoidance distortions.
4. **Distress Fast-Path & Safety Controls:**
   - Accessible via `/home/loneliness` with persistent SOS panic button overlay (`<100ms` blanking).
   - Non-judgmental early exit ("That's enough for now") prompting post-session effectiveness rating via `EffectivenessFeedbackSheet` (`act_loneliness_comfort`).
   - Quick comfort anchors to Gentle Breathing (`/home/breathe`), Unsent Letters (`/home/journal`), and Hope Box (`/home/hope-box`).

## Boundaries & Constraints

**Always:**
- Keep all interactive touch targets ≥ 56dp.
- Adhere strictly to WCAG AA contrast (≥ 4.5:1) against `#111518` dark canvas.
- Maintain zero network calls (`FireflyHttpOverride` strictly enforced; SMS dispatched via local OS `sms:` URI intent only).
- Keep prediction data strictly confidential, local, and anonymous (not linked to contact identity in aggregate summaries).
- If reaching out outcome is negative, provide gentle, non-judgmental validation.
- Support non-judgmental early exit and persistent SOS shield overlay.

**Never:**
- Never guilt, shame, or pressure the user into reaching out.
- Never impose streaks, badges, gamification, or failure states if user decides not to message.
- Never upload or sync reach-out contacts, prediction logs, or messages to external servers.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Open Loneliness Screen | User navigates to `/home/loneliness` | Renders comforting canvas, contacts, quick comforts, and insight card (if ≥ 3 pairs) | Graceful empty list handling |
| Empty Contacts | Safety plan and custom contacts empty | Shows gentle prompt: *"Add someone you could message when things feel heavy"* with Add Contact button | Fallback to quick self-soothing tools |
| Select Template & Message | User selects contact and taps "Send a message" | Opens template picker dialog with 3 editable messages | Validates message non-empty |
| Start Prediction | User proceeds with message | Bottom sheet prompts: *"How do you think they'll respond?"* (Warmly / Neutral / Won't respond) | Allows skipping prediction |
| Launch SMS Intent | User confirms prediction | Encodes URI `sms:<phone>?body=<encoded>`, launches OS SMS app, sets pending outcome banner | Safe error alert if URL launcher fails |
| Log Outcome | User returns to app and selects outcome | Records actual outcome, displays gentle non-judgmental feedback, updates aggregate stats | Safe persistence |
| 3+ Completed Pairs | Total completed experiments reaches 3 | Displays cognitive reframing insight card: *"Your predictions vs. what happened — most people are warmer than we expect."* | Recomputes stats dynamically |
| Early Exit | User taps "That's enough for now" | Closes screen, prompts `EffectivenessFeedbackSheet` | Clean disposal |

</frozen-after-approval>

## Code Map

- `lib/features/loneliness_comfort/domain/models/reach_out_contact.dart` -- Domain model for reach-out contacts (Safety Plan integration and custom).
- `lib/features/loneliness_comfort/domain/models/social_prediction_experiment.dart` -- Models for `SocialOutcome`, `SocialPredictionExperiment`, and `SocialExperimentSummary`.
- `lib/features/loneliness_comfort/domain/models/loneliness_comfort_state.dart` -- Immutable state model for Loneliness Comfort screen and experiment lifecycle.
- `lib/features/loneliness_comfort/domain/repositories/loneliness_comfort_repository.dart` -- Repository interface for custom contacts, experiment logs, aggregate insights, and settings.
- `lib/features/loneliness_comfort/data/repositories/loneliness_comfort_repository_impl.dart` -- Concrete repository with persistent storage, statistics calculation, and memory-safe cleanup.
- `lib/features/loneliness_comfort/presentation/controllers/loneliness_comfort_controller.dart` -- Riverpod controller managing contacts, template selection, prediction lifecycle, SMS intent dispatch, and outcome logging.
- `lib/features/loneliness_comfort/presentation/widgets/reach_out_contact_card.dart` -- Contact card with relationship tag, ≥ 56dp touch targets, and message action button.
- `lib/features/loneliness_comfort/presentation/widgets/reach_out_message_dialog.dart` -- Dialog for selecting and customizing Kumar & Epley 2023 message templates.
- `lib/features/loneliness_comfort/presentation/widgets/guess_vs_reality_sheet.dart` -- Two-stage modal sheet for prediction logging and outcome reporting.
- `lib/features/loneliness_comfort/presentation/widgets/social_insight_card.dart` -- Cognitive reframing card displaying predictions vs reality after ≥ 3 experiments.
- `lib/features/loneliness_comfort/presentation/screens/loneliness_comfort_screen.dart` -- Full "Someone's Here" experience with comforting header, contacts, quick comforts, SOS overlay, and post-session rating.
- `test/features/loneliness_comfort/verify_loneliness_comfort_standalone.dart` -- Standalone verification test suite covering models, repository calculations, SMS intent encoding, state transitions, and edge cases.

## Tasks & Acceptance

**Execution:**
- [x] Domain models: `reach_out_contact.dart`, `social_prediction_experiment.dart`, `loneliness_comfort_state.dart`
- [x] Repository: `loneliness_comfort_repository.dart` & `loneliness_comfort_repository_impl.dart`
- [x] Controller: `loneliness_comfort_controller.dart` with Safety Plan integration and SMS intent generator
- [x] UI Widgets: `reach_out_contact_card.dart`, `reach_out_message_dialog.dart`, `guess_vs_reality_sheet.dart`, `social_insight_card.dart`
- [x] UI Screen: `loneliness_comfort_screen.dart` with `#111518` canvas, header, SOS panic overlay, and post-session rating
- [x] Standalone test verification: `verify_loneliness_comfort_standalone.dart`
- [x] Sprint status update & review

**Acceptance Criteria:**
- Given `LonelinessComfortScreen`, users are greeted with low-stimulation, non-judgmental comfort copy and ambient breathing pulse.
- Contacts dynamically pull from Safety Plan (Steps 3 & 4) and support custom additions.
- 3 validated pre-written message templates (Kumar & Epley 2023) can be selected, edited, and launched via native offline `sms:` intent with zero network calls.
- "Guess vs. Reality" experiment records pre-send prediction and post-send outcome.
- Negative/distant outcomes yield trauma-informed validation without shame.
- Reaching ≥ 3 completed experiments unlocks the cognitive reframing insight card.
- Early exit triggers optional `EffectivenessFeedbackSheet` rating (`act_loneliness_comfort`).
- 100% of standalone assertions pass.

## Implementation Notes

- Implemented 100% offline, privacy-sealed Loneliness Comfort & "Guess vs. Reality" Experiment (FR-06 / RM-02):
  - **"Someone's Here" Canvas:** Peaceful `#111518` theme, slow breathing visual pulse, and trauma-informed validation text.
  - **Reaching-Out Integration:** Seamless contact bridging from Safety Plan and custom additions; 56dp touch targets with calling and messaging CTAs.
  - **Evidence-Based Templates:** Kumar & Epley 2023 pre-written messages with editing modal and compliant offline URI generator (`sms:<phone>?body=<encoded>`).
  - **Guess vs. Reality Experiment Loop:** Two-stage bottom sheet tracking predicted warmth before send and actual warmth after send; non-judgmental validation for distant replies.
  - **Empirical Reframing Card:** Unlocks at ≥ 3 completed experiments to demonstrate that real responses are statistically warmer than anxious predictions.
  - **Safety & Flow:** Persistent SOS panic button support, fast anchors to Gentle Breathing, Hope Box, and Unsent Letters, with `EffectivenessFeedbackSheet` rating integration.
  - **Verification:** Comprehensive standalone test suite in `test/features/loneliness_comfort/verify_loneliness_comfort_standalone.dart` passes 100% of assertions.

