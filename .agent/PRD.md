# PRD.md
# Firefly — Product Requirements Document

**Version:** 1.0.0
**Date:** 2026-09-30
**Status:** Approved — Sprint 0 Baseline
**Owner:** Product & Engineering, Firefly
**Classification:** Internal Engineering Specification

---

## Table of Contents

1. [Executive Summary & Product Vision](#1-executive-summary--product-vision)
2. [Problem Statement & Behavioral Insights](#2-problem-statement--behavioral-insights)
3. [Core Guiding Principles](#3-core-guiding-principles)
4. [Functional Requirements Matrix](#4-functional-requirements-matrix)
5. [Non-Functional Requirements Matrix](#5-non-functional-requirements-matrix)
6. [Safety, Clinical & Ethical Guardrails](#6-safety-clinical--ethical-guardrails)
7. [Validation & Quality Framework](#7-validation--quality-framework)

---

## 1. Executive Summary & Product Vision

### 1.1 Product Definition

**Firefly** is a calm, 100% offline, privacy-critical mental wellbeing companion built with Flutter and Dart. It meets users in their hardest moments — late-night anxiety, flat and exhausted low moods, sensory overwhelm after a difficult day, or the particular ache of nighttime loneliness — and offers one small, evidence-informed step at a time.

Firefly is not a clinical tool. It does not diagnose. It does not replace therapy, medication, or professional care. It is a quiet, private companion that works on a user's device, without a network connection, without an account, and without ever sharing their data with anyone.

### 1.2 Positioning Statement

> *For people experiencing mild-to-moderate acute distress who want immediate, private support, Firefly is an offline wellbeing companion that delivers evidence-backed micro-interventions in under two minutes — unlike therapy apps, mood trackers, or crisis lines, which require connectivity, account creation, or significant cognitive investment.*

### 1.3 Product Philosophy

Firefly is built around three philosophical commitments:

**1. Serene by design.** Every interaction must reduce load, not add to it. The interface is low-stimulation, unhurried, and free of gamification pressure. The user is never punished for not showing up, and never rewarded with a token or badge when they do.

**2. Private by architecture.** User data never leaves the device. There is no server, no cloud database, no analytics SDK, and no network request. Privacy is not a feature to be toggled — it is the structural foundation.

**3. Evidence-grounded.** Every intervention in Firefly is supported by peer-reviewed research. Cyclic sighing is used because Balban et al. (2023) demonstrated it outperforms other breathwork and mindfulness for mood improvement. Behavioral activation is used because meta-analyses demonstrate effectiveness equivalent to full CBT. The Safety Plan follows the Stanley-Brown protocol validated in JAMA Psychiatry. Where evidence is preliminary, the app is conservative.

### 1.4 Scope Boundaries

| In Scope | Out of Scope |
|---|---|
| Mild-to-moderate stress, low mood, overwhelm, loneliness | Severe mental illness, psychosis, active suicidal crisis management |
| Evidence-backed micro-interventions (< 2 min) | Full therapeutic programs (8-week CBT, MBSR) |
| Stanley-Brown offline Safety Plan with crisis contacts | Real-time crisis intervention or professional counseling |
| Private, encrypted on-device data | Any cloud storage, user accounts, or remote sync |
| Complement to professional care | Replacement for professional care |
| Non-diagnostic self-reflection tools | Psychiatric diagnosis or clinical assessment |

### 1.5 Target Platform

Cross-platform mobile: **iOS (14.0+)** and **Android (API 24+)** as primary targets. Flutter codebase supports future extension to desktop (macOS, Windows, Linux) as secondary targets with minimal additional work.

---

## 2. Problem Statement & Behavioral Insights

### 2.1 The Acute Distress Problem

When a person is in acute emotional distress, their capacity for complex decision-making is significantly impaired. The prefrontal cortex — responsible for planning, reasoning, and self-regulation — is functionally subordinated to the stress response. The result is:

- **Executive dysfunction:** Inability to initiate multi-step tasks. A person who "knows" they should try breathing or journaling cannot start because starting feels too hard.
- **Sensory overwhelm:** Bright screens, notification sounds, and complex interfaces intensify distress.
- **Catastrophising cognition:** Problems feel permanent, pervasive, and personal.
- **Social avoidance:** Loneliness intensifies because the perceived cost of reaching out feels disproportionately high relative to the expected benefit.

Traditional mental health apps fail at this moment because they are designed for engaged, motivated users — not users in crisis. A 10-item questionnaire, a 30-day program, or a therapist-matching screen are all inaccessible when a person's cognitive bandwidth is close to zero.

### 2.2 Engagement Research: Why Current Apps Fail

**Baumel et al. (2019, JMIR 21(9):e14567)** analysed real-world traffic data from 59 popular unguided mental health apps:

- Median **15-day retention: 3.9%** (IQR 10.3%)
- Median **30-day retention: 3.3%** (IQR 6.2%)
- Standalone breathing-exercise apps: **0.0% median 30-day retention**
- Mindfulness/meditation apps: 4.7% at day 30
- Daily usage time for active users: 3.5–8.3 minutes (trackers, breathing) vs. 21.47 minutes (mindfulness)

**Implication for Firefly's design:** If the median user returns for fewer than 2 weeks and abandons entirely at 30 days, the app must deliver its full value in a single session. Firefly's architecture assumes **each visit may be the last** and designs accordingly. Every module is self-contained and completable in under 2 minutes.

The 0% retention for breathing apps specifically validates the decision to **embed breathing as a state-matched suggestion** (from the check-in) rather than a standalone feature. Users who open an app specifically to breathe are likely already resolved in their motivation. Users who arrive at a breathing exercise because the app routed them there based on their reported anxiety are far more likely to engage.

### 2.3 Why Streaks and Gamification Cause Harm

Research on gamification in mental health contexts consistently identifies a pattern of **guilt-induced abandonment**:

- Streak counters create a psychological contract. When the streak breaks — as it inevitably does for a user in distress, who is the most likely to need the app most on their worst days — the breach produces shame that compounds the original distress.
- Notification messages like "You've missed 3 days" or "Don't break your streak!" exploit loss aversion. For users with anxiety or depression, these notifications have been identified as active harm triggers.
- Achievement badges and completion animations (confetti, celebratory sounds) create a gamified relationship with recovery. Mental health recovery is non-linear; any UI that implies otherwise is clinically misleading.

**Firefly's response:** No streaks. No badges. No completion animations. The only progress metric is a gentle, private count: *"You showed up N times this week."* Positive framing, never comparative, never punitive.

### 2.4 The Case for Offline-First Architecture

**Connectivity and privacy create specific barriers for mental health tools:**

1. **Trust barrier:** Users experiencing shame, trauma, or stigmatised conditions are measurably less willing to log sensitive data if they believe it may be shared, sold, or subpoenaed. A 2019 study of mental health app privacy policies found that 79% of apps shared data with third parties, and 69% shared with commercial entities.

2. **Connectivity barrier:** Acute distress does not respect network availability. A person in a rural area, on a plane, or simply in a dead zone needs the app to work.

3. **Regulatory risk:** Mental health data is among the most sensitive categories under GDPR (Article 9 Special Category Data) and HIPAA. Offline-first architecture eliminates the largest class of compliance risk by ensuring no data leaves the device.

4. **Latency:** An offline app responds instantly. Network-dependent apps introduce latency at the exact moment a user needs immediacy.

---

## 3. Core Guiding Principles

These five principles are non-negotiable product heuristics. Every feature, copy decision, and interaction design must be validated against them.

---

### Principle 1: Value Under 2 Minutes

**Statement:** Every intervention must be completable and beneficial within 2 minutes of opening the app.

**Rationale:** Baumel et al. showed active session times of 3.5–8.3 minutes for the apps with the highest real-world engagement. The 0% retention rate for breathing apps suggests users who need a quick relief tool abandon apps that demand more. Firefly's interventions must work for a user who has low energy, low motivation, and limited cognitive capacity.

**Implementation constraints:**
- The check-in must be completable in < 30 seconds (5 taps maximum)
- The breathing engine delivers a measurable state shift within 1–2 cycles (2–4 minutes), with benefit perceptible even after 60 seconds
- Tiny-steps actions are explicitly filtered to ≤ 2 minutes duration
- Journaling is encouraged but never timed or required
- The Safety Plan is accessible in < 1 tap from any screen at any time

**Violation indicators:** Any screen that requires more than 5 interactions before the user receives value. Any intervention that cannot be partially completed and still provide benefit.

---

### Principle 2: One Step at a Time

**Statement:** Maximum one primary decision or action per screen. The user is never asked to choose between multiple interventions simultaneously.

**Rationale:** Executive dysfunction under distress means that a screen presenting multiple options is effectively presenting zero options. The paradox of choice compounds cognitive load. Firefly's check-in engine makes the routing decision on behalf of the user, presenting one recommended next step.

**Implementation constraints:**
- Every screen has exactly one primary CTA (56dp+ touch target, full-width where applicable)
- Secondary options (e.g., "Try something else") are visually subordinated and never equal in prominence to the primary
- The check-in result presents one `ActionSuggestion` — not a list of options
- Navigation from the recommendation is a single tap — no confirmation dialog required

**Violation indicators:** Any screen with two equally prominent CTAs. Any screen that requires the user to select from a list without a recommended default.

---

### Principle 3: Zero Guilt — No Streaks, No Shame

**Statement:** Progress is measured by presence, not performance. No streak counters, no missed-day notifications, no completion badges.

**Rationale:** Guilt is actively contraindicated for users with depression and anxiety. Streak mechanics create asymmetric psychological stakes: maintaining the streak feels obligatory, breaking it feels like failure. For users with low self-efficacy — a primary feature of depression — a broken streak is not a neutral event.

**Implementation constraints:**
- No `streak` field in any database table
- No push notification that references absence ("You haven't visited in X days")
- The Progress screen shows: sessions this week (positive count), most-used feature (curiosity framing), and one non-judgmental reflection ("You showed up 4 times this week")
- Completion of an exercise: subtle sage-green fade — no confetti, no sound effect, no animation lasting > 500ms
- Onboarding explicitly states: *"There's no streak here. Come when you need to. Leave when you're ready."*

**Violation indicators:** Any database field tracking consecutive days. Any UI element that visually degrades or resets based on absence.

---

### Principle 4: Warm, Non-Clinical Tone

**Statement:** All copy is written by a warm, quiet, non-judgmental friend — not a clinician, not a chatbot, and not a productivity coach.

**Rationale:** Clinical language ("depressive episode," "anxiety disorder," "maladaptive cognition") creates distance and pathologises the user's experience. Productivity language ("optimise your recovery," "build your resilience habit") is tone-deaf to the experience of distress. The correct register is warm, specific, and human.

**Copy standards:**
- **In:** "How are you right now?" **Out:** "Rate your current mood on a scale of 1–10"
- **In:** "One small thing" **Out:** "Complete your daily activation task"
- **In:** "Let's slow things down" **Out:** "Begin anxiety reduction protocol"
- **In:** "You showed up today" **Out:** "Streak maintained: 7 days"
- **In:** "Something to hold onto" **Out:** "Hope resource library"

All copy must pass a "would a caring friend say this at 2am?" test before inclusion.

**Violation indicators:** Any copy that uses diagnostic terminology without clinical context. Any copy that implies performance, achievement, or obligation.

---

### Principle 5: 100% Offline, Zero-Knowledge Privacy

**Statement:** Firefly never makes a network request. User data is encrypted on-device and never leaves the device except by explicit user-initiated encrypted export.

**Rationale:** Privacy is the foundational trust contract between Firefly and its users. Mental health data is among the most sensitive personal data categories. Users who cannot trust the privacy guarantee will not honestly log their worst moments. An app that receives honest data is clinically useful. An app that receives curated, shame-filtered data is not.

**Implementation constraints:**
- `HttpOverrides.global = FireflyHttpOverride()` installed before any other initialization — throws on any HTTP creation attempt
- Zero dependency on `http`, `dio`, Firebase, or any analytics SDK
- All local data encrypted with SQLCipher AES-256-CBC
- Encryption key stored in iOS Keychain / Android Keystore (hardware-backed TEE where available)
- `android:allowBackup="false"` in manifest
- `NSURLIsExcludedFromBackupKey = true` on database file
- User-initiated export is AES-256-GCM encrypted with Argon2id passphrase derivation
- App Store Privacy Label: all categories "Data Not Collected"

**Violation indicators:** Any outbound HTTP request in any circumstance. Any third-party SDK that requires network access. Any data persistence outside the encrypted local database.

---

## 4. Functional Requirements Matrix

> **Key:**
> - **ID**: Unique feature identifier
> - **Priority**: P0 = MVP (must ship), P1 = Fast Follow, P2 = Roadmap
> - **Evidence**: Peer-reviewed research justification

---

### FR-01: State-Matched Affect Check-In

**Priority:** P0 — Core MVP
**Feature Area:** Check-In
**Clinical Evidence:** Affect labeling (Lieberman et al.) reduces amygdala reactivity; mood monitoring identified as a moderating feature in Linardon et al. (176 RCTs, World Psychiatry)

#### User Story
*As a user arriving at the app in an unknown emotional state, I want to quickly describe how I feel using simple, non-clinical selectors, so that Firefly can route me to the one thing most likely to help right now without requiring me to know what I need.*

#### System Behavior

**1. Entry Point:**
- Check-in is the default home screen on first launch and the primary CTA if no check-in has been completed in the last 4 hours
- If a check-in was completed within the last 4 hours, home shows the last suggestion with a "Check in again" secondary option

**2. Check-In Flow (≤ 30 seconds, ≤ 5 taps):**

| Step | Component | Input Type | Output |
|---|---|---|---|
| 1 | Mood anchor | 5 moon-phase tiles: Heavy / Low / Here / Light / Open | `moodCategory` string |
| 2 | Energy level | Horizontal drag slider: Still → Moving | `energyLevel` integer 1–5 |
| 3 | Anxiety level | 5-dot visual selector (no numeric labels) | `anxietyLevel` integer 1–5 |
| 4 | Loneliness level | 5-dot visual selector | `lonelinessLevel` integer 1–5 |
| 5 | Submit | "I'm here" primary CTA (56dp sage button) | Routes to `ActionSuggestion` |

**3. Recommendation Engine (deterministic, < 1ms):**

| Priority | Condition | Suggested Action | Route |
|---|---|---|---|
| 1 | `anxietyLevel ≥ 4` | Cyclic sighing breathing | `/home/breathe` |
| 2 | `moodCategory == 'low' && energyLevel ≤ 2` | Tiny step (behavioral activation) | `/home/tiny-steps` |
| 3 | `lonelinessLevel ≥ 4` | Loneliness comfort | `/home/loneliness` |
| 4 | `moodCategory == 'overwhelmed'` | 5-4-3-2-1 grounding | `/home/breathe?mode=grounding` |
| 5 | `anxietyLevel ≥ 2 \|\| energyLevel ≤ 3` | Expressive journaling | `/home/journal/new` |
| 6 | Default (calm / positive) | Tiny step or Hope Box | `/home/tiny-steps` |

**4. Post-Check-In State:**
- `CheckInEntry` persisted to encrypted Drift database
- `ActionSuggestion` displayed on result card with title, body (1–2 sentences), estimated duration, and single navigation CTA
- "Try something else" secondary text link accesses a minimal 3-item alternatives list

#### Edge Cases

| Scenario | Behavior |
|---|---|
| User skips all selectors and taps submit | Engine defaults to mid-range values; routes to journaling |
| User completes check-in then immediately closes app | Entry saved; next launch shows last suggestion with time elapsed |
| User completes check-in at `anxietyLevel = 5` (maximum) | Routes to breathing AND surfaces the SOS overlay with increased opacity |
| Database write fails | Suggestion still shown from in-memory state; error logged silently; retry on next open |
| User changes system accessibility font to 200% | Mood tiles reflow to 2-column grid; energy slider labels remain visible |

#### Acceptance Criteria
- [ ] Check-in completable in < 30 seconds on a mid-range Android device
- [ ] All 6 routing conditions produce correct `ActionSuggestion` in unit tests (100% coverage)
- [ ] `CheckInEntry` persists correctly through app kill and restart
- [ ] Result card navigates to correct route for all 6 conditions
- [ ] At 200% system font scale: no overflow, no clipped text, all tap targets ≥ 56dp

---

### FR-02: Respiration & Grounding Engine

**Priority:** P0 — Core MVP
**Feature Area:** Breathing & Grounding
**Clinical Evidence:**
- Cyclic sighing: Balban et al. 2023 (Cell Reports Medicine, NCT05304000) — remote RCT, cyclic sighing produced greater positive affect improvement and respiratory rate reduction than box breathing, hyperventilation, and mindfulness over 1 month
- Paced breathing at ~6 breaths/min: maximises HRV, stimulates vagus nerve, shifts autonomic balance to parasympathetic
- 5-4-3-2-1 grounding: clinically used in CBT/DBT for anxious loop interruption; pilot study evidence for HRV improvement; lacks large-scale RCT evidence in isolation but strong clinical consensus

#### User Story
*As a user routed to breathing by the check-in (or navigating directly), I want a guided, visually calming respiration experience with haptic cues, so that my nervous system can regulate without requiring me to hold instructions in mind.*

#### System Behavior

**1. Cyclic Sighing (Default Mode):**

| Parameter | Value | Rationale |
|---|---|---|
| Inhale pattern | Double inhale (short + longer) | Maximises lung expansion, increases CO2 sensitivity |
| Inhale duration | 4,000ms total | Matches resonance frequency for majority of adults |
| Exhale pattern | Single prolonged exhale | Parasympathetic activation via prolonged exhalation |
| Exhale duration | 8,000ms | 2:1 exhale-to-inhale ratio for maximum vagal stimulation |
| Phase tick interval | 50ms (20fps state updates) | Sufficient for smooth bloom animation without CPU drain |
| Session recommendation | 5 minutes (approximately 25 cycles) | Balban protocol duration; displayed as suggestion, not enforced |

**2. Visual Bloom Animator (`CustomPainter`):**

| Property | Value |
|---|---|
| Canvas size | 280×280dp |
| Idle radius | 50dp |
| Inhale peak radius | 120dp |
| Glow rings | 3 concentric at 1.12×, 1.24×, 1.36× radius; opacity 12%, 8%, 4% |
| Inhale colour | Sage `#7DBA9B` |
| Exhale colour | Dusk blue `#5B8A99` |
| Colour transition | Continuous `ColorTween` across full cycle |
| Timing curve | `Curves.easeInOutSine` |
| Repaint condition | Only when `phaseProgress` or `phase` changes |

**3. Haptic Synchronisation:**

| Event | Haptic Pattern |
|---|---|
| Inhale phase start | Double light impact (100ms gap) |
| Exhale phase start | Single light impact |

**4. Audio:**
- Default: `gentle_rain.mp3` (bundled local asset, gapless loop)
- Options: `white_noise.mp3`, `silence` (no audio)
- User preference persisted to `AudioPreferences` table
- Fade in: 300ms volume ramp on session start
- Fade out: 300ms volume ramp on session end or navigation

**5. Phase Labels (centre of bloom):**
- Inhale: "Breathe in" (`displayMd` — Plus Jakarta Sans 28sp)
- Exhale: "Let go" (`displayMd`)

**6. 5-4-3-2-1 Grounding Mode:**
- Accessed via `?mode=grounding` route parameter or "Switch to grounding" link in breathing session
- Sequential prompt cards:
  - 5 things you can **see**
  - 4 things you can **touch**
  - 3 things you can **hear**
  - 2 things you can **smell**
  - 1 thing you can **taste**
- User taps to confirm each sense; selection click haptic on each
- No timer — user-paced
- Completion: gentle sage fade, no fanfare

**7. Resource Management (critical):**
- `BreathingSessionController` is `AsyncNotifier` with `ref.onDispose()` guaranteed teardown
- `ref.onDispose()` must: cancel `Timer`, call `audio.stop()`, call `haptics.cancel()`
- Audio failure (file missing, codec error) must NOT crash session — silent degradation with local log entry only
- Timer must NOT survive navigation — verified by Navigator pop observer test

#### Edge Cases

| Scenario | Behavior |
|---|---|
| User navigates away mid-session | `ref.onDispose` cancels timer, stops audio, cancels haptic — no orphaned resources |
| Audio file missing or corrupt | Session continues without audio; error state displayed as soft inline message only |
| Device haptics disabled (system setting) | `HapticFeedback` calls silently no-op; session unaffected |
| User enables Reduce Motion | `MotionTokens.resolve()` returns `Duration.zero`; bloom becomes static circle at inhale peak |
| Battery saver mode throttles timer | Phase durations extend; visual label updates compensate; session quality degrades gracefully |
| User completes 5 cycles (10 min) | No automatic end; a soft "Session summary" appears after every 5 cycles as a gentle pause prompt |

#### Acceptance Criteria
- [ ] Cyclic sighing session runs for 5+ minutes with no frame drops > 16ms on mid-range Android
- [ ] Audio loops gaplessly (no audible gap between loop iterations)
- [ ] Haptic fires within 1 frame of phase transition
- [ ] Navigating away mid-session: zero timer/audio leaks verified by profiler
- [ ] `shouldRepaint` returns `false` on timer ticks where `phaseProgress` delta < 0.001
- [ ] 5-4-3-2-1 flow completes all 5 steps and persists completion state
- [ ] Audio failure: session continues, error displayed, no crash

---

### FR-03: Tiny Steps Mode (Behavioral Activation)

**Priority:** P1 — Fast Follow (Tier 2)
**Feature Area:** Behavioral Activation
**Clinical Evidence:**
- Behavioral Activation (BA): meta-analysis of 28 studies (Psychol Med 2021;51(9):1491–1504) — BA vs. inactive controls: depression g=0.83, anxiety g=0.37
- BA equivalent to full CBT in face-to-face delivery (Ciharova et al. 2021, J Consult Clin Psychol)
- Unguided digital micro-dose versions are untested; conservative implementation required

#### User Story
*As a user with low energy and flat mood, I want a single, very small, doable action suggested to me, so that I can interrupt the inertia of depression without needing motivation I don't currently have.*

#### System Behavior

**1. Action Library:**
- 20+ curated micro-actions stored as Dart constants (not user-modifiable in v1.0)
- Each action: `title`, `body` (1 sentence), `durationMinutes` (≤ 2), `energyThreshold` (1–3 or 4–5), `affectCategory` array
- Categories: `physical` (drink water, stand up), `environmental` (open a window, turn on a light), `sensory` (touch something textured, listen to one song), `social` (send one message), `cognitive` (name three things around you)

**2. Selection Algorithm:**
- Filter by: `energyLevel` from check-in (low energy → `energyThreshold` 1–3 only)
- Filter by: `affectCategory` compatibility (low mood → physical + environmental priority)
- Present 3 suggestions in a vertical list; first is primary recommendation
- If check-in data not available: present 3 randomly selected low-energy actions

**3. Completion Flow:**
- User taps action → expanded card shows full instruction
- "Done — I tried it" primary CTA (56dp, sage)
- On completion: `HapticFeedback.mediumImpact()` × 2 (200ms gap) + 400ms sage green fade on card
- Completion saved to `UsageSummaries` table (feature key, timestamp) — no content saved
- "Not today" secondary text link: dismisses without penalty, no logging

**4. Copy Standards:**
- Actions framed as invitations, not commands: "Drink a glass of water" not "Hydrate yourself"
- No health claims: "A small move can help shift things" not "This will cure your depression"

#### Edge Cases

| Scenario | Behavior |
|---|---|
| All 3 suggestions dismissed | 3 new suggestions shown; after second full dismissal, journaling is offered instead |
| User completes action, re-opens app within 30 minutes | Prior completion shown; new suggestion offered after acknowledgement |
| Action library exhausted by filters | Fallback to any low-energy action regardless of category |

#### Acceptance Criteria
- [ ] All 3 presented actions match check-in energy level filter
- [ ] Completion registers in `UsageSummaries` without storing action content
- [ ] "Not today" dismissal produces no negative UI feedback
- [ ] Haptic fires on completion within 1 frame

---

### FR-04: Stanley-Brown Offline Safety Plan

**Priority:** P0 — Core MVP (ships before all other features — see ADR-007)
**Feature Area:** Safety
**Clinical Evidence:**
- Stanley et al. 2018 (JAMA Psychiatry 75(9):894–900): Safety Planning Intervention associated with 45% reduction in suicidal behavior (OR 0.56) vs. usual care; 2.06× more likely to attend follow-up outpatient care
- ED-SAFE 2 (JAMA Psychiatry 2023): stepped-wedge RCT; SPI associated with reduced suicide-related acute healthcare visits over 12 months
- Bush et al. 2017 (Psychiatric Services 68(4)): Virtual Hope Box improved coping self-efficacy in veterans with suicidal ideation; no significant reduction in ideation itself — positioned as coping complement, not treatment

#### User Story
*As a user who recognises warning signs of a crisis building, I want to immediately access my personalised safety plan from anywhere in the app, so that I can follow the steps I've prepared in advance without having to think clearly under pressure.*

#### System Behavior

**1. Access Architecture:**
- `SosOverlayButton` is a persistent floating widget rendered above the `NavigationShell` in `MainShellScaffold`
- Positioned: bottom-right, above bottom navigation bar
- Visual: 44×44dp shield icon at 25% opacity (intentionally unobtrusive — not a fear trigger)
- Touch target: 64×64dp (extended via invisible padding)
- Tap → `context.push(AppRoutes.safetyPlan)` → full-screen modal with 300ms fade transition
- One tap from any screen, any time, even during active breathing session

**2. Six-Step Stanley-Brown Template:**

| Step | ID | Content | Data Fields |
|---|---|---|---|
| 1 | Warning signs | Personal early warning signals | `SafetyPlanWarning` list (text, order) |
| 2 | Internal coping | Things I can do alone to distract/soothe | `SafetyPlanStep` (type: internal_coping) |
| 3 | Social distraction | People/places that take my mind off things | `SafetyPlanStep` (type: distraction_contact) |
| 4 | People to ask for help | Contacts I can reach out to | `SafetyPlanContact` (name, phone, relationship) |
| 5 | Professionals to contact | Therapist, GP, crisis line | `SafetyPlanContact` (isProfessional: true) |
| 6 | Environment safety | Ways to make my environment safer | `SafetyPlanStep` (type: environment_safety) |

**3. Contact Actions:**
- Each contact card: name, relationship label, phone number (if provided)
- "Call" button: `url_launcher` → `tel:<number>` intent — fully offline, no internet required
- "Text" button: `url_launcher` → `sms:<number>?body=<prewritten_message>` — pre-populated with soft reach-out text
- Pre-written text templates (user-editable): *"Hey — I'm having a rough time right now. Could we talk?"*

**4. Pre-Populated Crisis Lines:**
- Editable list pre-populated with local crisis numbers (determined by system locale at first launch)
- User can add, edit, and reorder all entries
- Displayed separately from personal contacts in a distinct "Emergency Lines" section
- These fire the same `tel:` intent as personal contacts

**5. Plan Editing:**
- Full-screen editor accessible from plan view via "Edit plan" secondary CTA
- All six steps editable as plain text fields
- Contacts: add / edit / delete / reorder (drag handle)
- "Last reviewed" timestamp displayed on plan view — gentle reminder to review periodically
- Plan saved on every keystroke (autosave — no explicit save button required)

**6. Panic Exit Sequence:**
- `PanicButton` (long-press ≥ 600ms on SOS overlay) → panic sequence
- Phase 1 (< 10ms): Navigate to `PanicBlankScreen` (pure `#000000`, no content)
- Phase 2 (< 50ms): `ref.invalidate()` all sensitive providers (journal display, check-in session, safety plan display, master key)
- Phase 3 (< 100ms): `biometricGuard.lockApp()` — drops database key reference
- Phase 4: Android: `moveTaskToBack(true)` — appears closed; iOS: navigate to neutral screen (panic exit to home screen not possible on iOS without jailbreak)
- Total time to blank screen: < 100ms

**7. Safety Plan Persistence:**
- All plan data stored in `SafetyPlans`, `SafetyPlanContacts`, `SafetyPlanWarnings`, `SafetyPlanSteps` tables
- Cascade delete: deleting a plan deletes all child records
- Plan survives app kill, device restart, and biometric re-lock
- Backup: included in user-initiated encrypted export

#### Edge Cases

| Scenario | Behavior |
|---|---|
| User opens Safety Plan for first time (empty) | Onboarding prompt: "Build your plan now — it works better when it's yours." Editor opens immediately |
| User taps SOS during breathing session | Full-screen Safety Plan overlaid above breathing screen; breathing session paused (audio faded out) |
| Panic button triggered accidentally | 600ms long-press threshold prevents accidental trigger; 200ms haptic pulse at 400ms warns user |
| Phone number field is empty | Call/Text buttons hidden — only contact name shown |
| Device is offline (always true) | All features fully functional — offline is the baseline, not an edge case |
| Crisis line locale detection fails | Default to international crisis lines (e.g., International Association for Suicide Prevention directory) |

#### Acceptance Criteria
- [ ] Safety Plan accessible in ≤ 1 tap from any screen including active breathing session
- [ ] All six Stanley-Brown steps editable and persistent
- [ ] `tel:` and `sms:` intents launch native dialer and SMS without network
- [ ] Panic button blanks screen in < 100ms (measured via frame timestamp)
- [ ] Cascade delete: deleting plan removes all child records
- [ ] Plan survives app kill and biometric re-lock cycle
- [ ] Safety Plan included in encrypted export

---

### FR-05: Expressive Journaling & Unsent Letters

**Priority:** P2 — Roadmap (Tier 3)
**Feature Area:** Journaling
**Clinical Evidence:**
- Frattaroli 2006 (Psychological Bulletin): meta-analysis of 146 disclosure studies — stronger effects with ≥ 3 sessions, sessions ≥ 15 min, writing at home/private space
- Newer meta-analysis (31 RCTs, N=4,012): small but significant effect on depression, anxiety, stress in healthy/subclinical samples
- Risk: Can exacerbate distress in acutely vulnerable populations (PTSD, severe distress) — guardrails required
- Pennebaker protocol: 15–20 min continuous writing, 3–4 consecutive days

#### User Story
*As a user who needs to process difficult thoughts and feelings privately, I want to write freely without fear that my words will be stored, shared, or judged, so that I can achieve the cognitive offloading that comes from externalising my internal experience.*

#### System Behavior

**1. Entry Creation:**
- New entry: large plain text field (minimum visible height 200dp), no formatting toolbar
- Optional header: "Unsent letter" mode toggle — changes header label to "This is for you. It won't be sent." and disables all export options for this entry
- Pennebaker mode toggle (opt-in): displays a gentle 15-minute ambient timer (visible but not alarming — no countdown sound)

**2. Voice-to-Text (Offline STT via Vosk):**
- Microphone button in text field toolbar
- Audio processed entirely on-device via Vosk acoustic model (bundled or first-launch download)
- Partial transcription streamed in real-time to text field
- User confirms final transcription before save
- Audio is never written to disk — only the transcription text is saved

**3. Privacy Architecture:**
- Content encrypted with application-layer AES-256-GCM **before** writing to Drift database (double encryption on top of SQLCipher)
- Encryption subkey derived via HKDF from Master Key with journal-specific context string
- Decryption: on-demand when entry is opened — decrypted text never stored in state beyond screen lifetime
- `ref.onDispose()` clears decrypted content from Riverpod state on navigation exit

**4. Auto-Delete TTL:**
- Per-entry toggle: "Auto-delete this entry"
- Duration picker: 3 days / 7 days / 30 days / Never
- TTL stored as `ttlDeleteAtUnix` Unix timestamp
- Wipe service runs on app launch (background) and after each session
- Wipe sequence: overwrite content with random data → delete row → `VACUUM`
- Cryptographic erasure available for "Wipe all journals": rotate journal HKDF subkey version → all prior ciphertext permanently unreadable

**5. Journal List View:**
- List shows: date created, word count (not content preview — privacy)
- Sorted newest first
- No search functionality (privacy — searching decrypted content requires holding it in memory)

**6. Safety Guardrail:**
- If a new journal entry is created immediately after the check-in's highest anxiety/distress rating: a single, dismissible soft prompt appears: *"Some people find writing intense feelings overwhelming. You can write as little or as much as feels right. The Safety Plan is always one tap away."*

#### Edge Cases

| Scenario | Behavior |
|---|---|
| User writes during acute distress (crisis keywords detected) | Crisis phrase detection routes to Safety Plan overlay (see §6.2); does not block or interrupt writing |
| Vosk model not yet downloaded | Voice button grayed out with tooltip: "Offline voice unavailable — tap to download (50MB)" |
| Entry marked Unsent Letter | Export and share options hidden on that entry's detail screen |
| TTL expires while app is closed | On next app launch, wipe service runs before any content is displayed |
| Journal HKDF key rotated (wipe all) | Existing encrypted blobs in DB become permanent noise; rows deleted; VACUUM run |

#### Acceptance Criteria
- [ ] Journal content encrypted before any DB write — verified by attempting to read raw DB with external tool
- [ ] Auto-delete TTL fires correctly when app opens after expiry
- [ ] Decrypted content cleared from state on screen exit (verified by profiler memory snapshot)
- [ ] "Unsent Letter" mode hides export options for that entry
- [ ] Cryptographic wipe: after key rotation, existing encrypted entries return decryption failure

---

### FR-06: Loneliness Comfort & Reaching Out

**Priority:** P1 — Fast Follow (Tier 2)
**Feature Area:** Loneliness
**Clinical Evidence:**
- Masi et al. 2011 (Pers Soc Psychol Rev 15(3)): meta-analysis of loneliness interventions — interventions targeting maladaptive social cognition most effective in randomised trials
- Kumar & Epley 2023 ("The Surprise of Reaching Out," J Pers Soc Psychol 124(4)): preregistered experiments showing robust underestimation of how much others appreciate being reached out to
- Kumar & Epley (Psychological Science — "Undervaluing Gratitude"): writers underestimated recipients' positive feelings, overestimated awkwardness

#### User Story
*As a user who feels lonely and isolated, I want to feel less alone in this moment and be gently encouraged toward the small act of reaching out, knowing I'm likely to underestimate how much the other person will appreciate hearing from me.*

#### System Behavior

**1. "Someone's Here" Screen:**
- Full-screen dark canvas, centre-anchored content
- Soft ambient sound playing (user's preferred soundscape)
- Slow, gentle breathing bloom animation (ambient mode — no phase labels, very slow 12s cycle)
- Large centre text (displayMd): *"You don't have to feel this alone."*
- Secondary body text: *"What you're feeling is real. Others have been here too."*
- Below fold: "Things that have helped before" expandable — user-maintained list of personal comfort items

**2. Reaching-Out Prompts:**
- Section: "People I could reach out to" — populated from Safety Plan contacts (Steps 3 & 4) plus user's own loneliness contact list
- Each contact card:
  - Name
  - "Send a message" button → SMS intent with pre-written body
  - User can edit the body before sending
- Pre-written messages (user-editable defaults):
  - *"Hey — I've been thinking of you. How are you doing?"*
  - *"Hi — just wanted to check in. Can we talk?"*
  - *"I'm having a hard time and thought of you. Would you be up for a call?"*
- Beneath contact list: contextual psychoeducation (dismissible): *"Research shows people almost always appreciate being reached out to more than we expect — even when we worry it's awkward."*

**3. Guess vs. Reality Flow (v1.0 MVP-lite version):**
- Before sending: "How do you think they'll respond?" — 3 options (Warmly / Neutral / Won't respond)
- After user returns: optional "What actually happened?" — same 3 options
- Responses stored anonymously in `AppConfiguration` as aggregate counts (not linked to contact identity)
- After 3+ pairs: gentle insight shown on Progress screen: *"Your predictions vs. what happened — most people are warmer than we expect."*

#### Edge Cases

| Scenario | Behavior |
|---|---|
| Contact list empty | Prompt: "Add someone to your reaching-out list" → opens contact addition flow |
| User starts Guess vs. Reality but never logs outcome | Outcome prompt surfaces gently on next app open (once only — not repeated) |
| User reaches out and reports negative outcome | No judgment; brief validation: *"That's hard. It doesn't mean reaching out was wrong — it just didn't land today."* |

#### Acceptance Criteria
- [ ] SMS intent launches with pre-written body editable by user before send
- [ ] Guess vs. Reality prediction and outcome both persist
- [ ] Aggregate insight shown correctly after 3+ pairs
- [ ] Audio plays and loops gaplessly on screen open
- [ ] Contact list pulls from Safety Plan contacts correctly

---

### FR-07: Hope Box

**Priority:** P0 — Core MVP
**Feature Area:** Coping Resources
**Clinical Evidence:**
- Bush et al. 2017 (Psychiatric Services 68(4):330–336): RCT, 118 veterans with suicidal ideation; Virtual Hope Box (VHB) users reported significantly greater coping self-efficacy at 3 weeks (b=2.41) and 12 weeks (b=2.99) vs. printed materials. No significant reduction in suicidal ideation itself. Most common uses: coping with distress, relaxation, distraction, inspiration.
- Position: coping aid, not treatment. Addresses coping self-efficacy, not ideation directly.

#### User Story
*As a user in a difficult moment, I want a private space to keep things that remind me why I'm here and what helps — photos, voice notes, songs, and written reasons — so that I can access them when I most need a reason to hold on.*

#### System Behavior

**1. Item Types:**

| Type | Storage | Input Method |
|---|---|---|
| Photo | App-private directory, AES-encrypted file reference in DB | Photo picker (from device gallery) |
| Voice note | App-private directory, AES-encrypted | On-device recording (30s max) |
| Text note | Encrypted `HopeBoxItem.content` field in DB | Plain text input |
| Reason to keep going | Encrypted `HopeBoxItem.content`, type: `reason` | Plain text, prompted: *"Something worth staying for:"* |
| Favourite song | Local file reference only (no streaming) | File picker |

**2. Display:**
- Masonry-style grid layout
- Items display: type icon + truncated label (not content — privacy on list view)
- Tap to open: full content view, full-screen if photo/voice
- "Add item" FAB (64dp, bottom-right, sage fill)

**3. Privacy:**
- All item file content stored in app-private directory (`getApplicationDocumentsDirectory()`)
- File paths encrypted in DB
- Files excluded from OS backup (`NSURLIsExcludedFromBackupKey = true`)
- No thumbnails generated in temp directories that could survive file deletion

**4. Deletion:**
- Per-item swipe-to-delete with confirmation
- Delete: removes DB record + deletes physical file + VACUUM

#### Edge Cases

| Scenario | Behavior |
|---|---|
| Hope Box empty on first open | Warm onboarding prompt: *"This space is just for you. Add something worth holding onto."* |
| Photo picker permission denied | Inline prompt explaining why permission needed; graceful degradation to text-only |
| Voice note recording interrupted (call) | Partial recording discarded; user returned to Hope Box |
| Storage nearly full | Warning before file-based add: "Your device has limited space." |

#### Acceptance Criteria
- [ ] All 5 item types creatable and displayable
- [ ] Files stored in app-private directory (not accessible via Files app)
- [ ] Deletion removes DB record AND physical file
- [ ] Hope Box content excluded from OS backup

---

### FR-08: Gentle Progress

**Priority:** P0 — Core MVP
**Feature Area:** Progress Reflection
**Clinical Evidence:** Baumel et al. engagement data; guilt mechanics research; self-efficacy theory (Bandura)

#### User Story
*As a user who has been using Firefly, I want to see a quiet, non-judgmental summary of how I've shown up for myself, without being confronted with missed days, streaks, or performance metrics.*

#### System Behavior

**1. Metrics Displayed:**

| Metric | Label | Display Format |
|---|---|---|
| Sessions this week | "You showed up" | Integer count + day dots (filled = session, empty = no session; dots have no shame state) |
| Most-used feature | "What's been helping" | Feature name + approximate usage count |
| Check-in mood distribution | "How you've been feeling" | Horizontal bar, 5 mood categories, past 7 days |
| Reaching-out predictions vs. outcomes | "People are warmer than we expect" | If ≥ 3 pairs, show aggregate comparison |

**2. What Is Explicitly Not Displayed:**
- Consecutive day streak
- "You missed X days"
- Comparison to previous weeks as a performance metric
- Any visual element that degrades or empties based on absence
- Leaderboard or community comparison

**3. Framing Copy:**
- Section header: *"How you've been showing up for yourself"*
- Empty state (no data yet): *"Your reflections will appear here. There's no pressure — come when you need to."*

#### Acceptance Criteria
- [ ] No streak field in database or UI
- [ ] Absence of sessions produces neutral empty dots, not red or grayed failure states
- [ ] Mood distribution calculated from local DB without network

---

### 4.1 Post-MVP Roadmap Matrix

| ID | Feature | Evidence Tier | Planned Phase |
|---|---|---|---|
| RM-01 | **One-Session Reset** (SSI module: name problem → one skill → one commitment) | Strong (Schleider et al. 2025: 83% of 24 systematic reviews positive; SMD −0.25) | v1.0 (MVP) |
| RM-02 | **Guess vs. Reality** (full belief-testing log with outcome tracking) | Strong (basic science: Kumar & Epley 2023) | v1.1 |
| RM-02b | **Thought Untangler (Self-Compassion)** (guided reflection to counteract shame/self-criticism) | Moderate (Neff's research; many RCTs, but few online trials) | v1.1 |
| RM-03 | **Wind-Down / Sleep** (gentle dCBT-I: sleep diary, consistent wake time, worry dump — no sleep restriction in v1.x) | Strong for digital dCBT-I (Lin et al. 2023, PeerJ: SMD −0.85 short-term insomnia) | v1.2 |
| RM-04 | **Movement Snacks** (2–10 min state-matched movement prompts) | Moderate-strong (Noetel et al. 2024, BMJ: g=−0.62 for walking) | v1.2 |
| RM-05 | **Awe Walk** (15-min guided outdoor prompt cards) | Preliminary (Sturm et al. 2020, Emotion: n=60, healthy older adults) | v1.3 |
| RM-06 | **Weekly Check-in Buddy** (user-initiated summary sharing with trusted contact) | Indirect (guidance raises completion ~12%) | v1.3 |
| RM-07 | **Music Room** (user-imported music; calm and gentle-lift playlists) | Mixed (Harney et al. 2022: d=−0.77 anxiety; high heterogeneity) | v1.3 |
| RM-08 | **On-Device Reflective LLM** (opt-in, journal prompts only, crisis-filtered) | Experimental — not evidence-validated | v2.0+ |

---

## 5. Non-Functional Requirements Matrix

### NFR-01: Security & Privacy

| Requirement | Specification | Verification |
|---|---|---|
| Network isolation | Zero outbound HTTP/HTTPS requests in any circumstance | Charles Proxy / mitmproxy intercept test; CI deny-list audit |
| Data encryption at rest | SQLCipher AES-256-CBC; HMAC-SHA512 page authentication | Attempt DB open with DB Browser for SQLite without key — must fail |
| Key storage | iOS Keychain (`kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`, `synchronizable: false`); Android Keystore (StrongBox if available, else TEE) | `flutter_secure_storage` options verified in code review |
| Biometric gate | DEK only retrievable after successful biometric/passcode authentication | `local_auth` integration test on device |
| OS backup exclusion | `android:allowBackup="false"` in manifest; `NSURLIsExcludedFromBackupKey = true` on DB file | `adb backup` returns empty; iCloud backup excludes app data |
| App switcher privacy | Android: `FLAG_SECURE` in `MainActivity`; iOS: blur overlay in `applicationWillResignActive` | Manual test: screenshot attempt returns black (Android); app switcher shows blur (iOS) |
| Exported backup encryption | AES-256-GCM; Argon2id key derivation (m=65536, t=3, p=2) | Attempt to open `.ffbk` file with hex editor — ciphertext only |
| Journal double encryption | Application-layer AES-256-GCM subkey via HKDF before DB write | Read DB row with DB Browser — content must be base64 ciphertext |
| Zero analytics | No Firebase, Sentry, Mixpanel, Amplitude, or any analytics SDK | MobSF binary analysis; CI package deny-list |
| Cryptographic journal erasure | HKDF subkey version rotation + VACUUM on "wipe all" | After rotation: attempt to decrypt prior entries — must fail |

### NFR-02: Performance

| Requirement | Target | Measurement |
|---|---|---|
| Cold start to first meaningful frame | < 1.5 seconds on mid-range Android (Snapdragon 665 class) | Flutter DevTools Timeline |
| Breathing bloom frame time | < 16ms (60fps guaranteed) | DevTools Performance overlay |
| Check-in screen response time | < 200ms from tap to recommendation display | Stopwatch trace in integration test |
| Database read (recent check-ins) | < 50ms | Drift query timer in dev mode |
| Audio session memory footprint | < 8 MB (active playback) | DevTools Memory tab |
| App resume after biometric | < 800ms to interactive state | Measured from `AppLifecycleState.resumed` |
| Panic blank screen latency | < 100ms from long-press complete to black screen | Frame timestamp measurement |
| ACID transaction safety | Zero data loss on immediate process kill during write | Monkey test: kill during write, verify DB integrity on next open |

### NFR-03: Accessibility

| Requirement | Standard | Verification |
|---|---|---|
| Text contrast — primary | ≥ 7:1 (WCAG 2.2 AAA) | Colour Contrast Analyser |
| Text contrast — secondary/body | ≥ 4.5:1 (WCAG 2.2 AA) | Colour Contrast Analyser |
| Interactive element contrast | ≥ 3:1 (WCAG 2.2 §1.4.11) | Colour Contrast Analyser |
| Touch target size | ≥ 56×56dp (all interactive elements) | Flutter Semantics inspector |
| Dynamic type | Full support to 200% system scale, no clipping or overflow | Physical device test at max accessibility font size |
| Screen reader support | All interactive elements have `semanticLabel`; bloom painter announces phase changes | VoiceOver (iOS) + TalkBack (Android) manual test |
| Reduced Motion | All animations collapse to static via `MotionTokens.resolve()` | Simulator accessibility setting test |
| Focus order | Logical reading order in all screens | Keyboard navigation test (external keyboard + accessibility) |
| Error communication | Never colour-only — icon + text always paired | Code review checklist |
| Colour blindness | All state differentiation uses shape/icon + colour, never colour alone | Sim Daltonism simulator test |

---

## 6. Safety, Clinical & Ethical Guardrails

### 6.1 Mandatory Onboarding Disclaimers

On first launch, before any feature is accessible, the user must acknowledge the following:

**Screen 1 — Scope Statement:**
> *"Firefly is a personal companion for difficult moments — stress, low mood, loneliness, overwhelm. It's designed to support you, not to diagnose or treat any condition.*
>
> *It works best for mild-to-moderate distress. For severe, ongoing, or urgent mental health concerns, please reach out to a professional."*

**Screen 2 — Safety Plan Prompt:**
> *"Before you start, let's set up your Safety Plan. This is a private guide you create for yourself — who to call, what helps, and what warning signs to watch for. It's always one tap away.*
>
> *You can skip this and return to it later, but we recommend building it now."*

**Persistent Disclaimer (all content screens):**
> Footer text (caption size, muted): *"Firefly supports — it doesn't replace professional care."*

### 6.2 Crisis Phrase Detection

**Scope:** Applied to journal entry text and (if implemented) any free-text input field.

**Architecture (deterministic — no LLM):**
- Local keyword blocklist compiled from clinical crisis literature
- Categories: explicit self-harm language, suicidal ideation phrases, hopelessness markers
- Pattern matching runs on every `onChanged` event with a 500ms debounce
- Detection does NOT block writing — it surfaces a non-intrusive overlay

**Detection Response:**
1. Soft overlay appears at top of journal screen (not blocking input):
   *"It sounds like things might be very hard right now. Your Safety Plan is here if you need it."*
2. Single CTA: "Open Safety Plan" → navigates to Safety Plan screen
3. Overlay dismissible by user tap — never forced
4. Detection event does NOT write any log entry (privacy invariant)

**False Positive Policy:**
- The keyword list is deliberately conservative to minimise false positives in expressive writing (e.g., "I want to die of embarrassment")
- Users who experience frequent false positives can disable detection in Settings
- Disabling is permitted: the Safety Plan is always accessible regardless

**What is NOT done:**
- No cloud analysis of text
- No external reporting
- No automatic emergency services contact
- No blocking of user action based on detected content

### 6.3 On-Device AI / LLM Constraints

The following constraints apply to any future implementation of an on-device LLM (v2.0+):

1. **Opt-in only:** User explicitly enables LLM features in Settings with clear disclosure of what the model does and doesn't do.
2. **Scope restriction:** LLM is permitted to generate reflective journaling prompts only. It must never respond to direct questions about treatment, diagnosis, medication, or crisis management.
3. **Crisis bypass:** Any input containing crisis-phrase matches routes to Safety Plan overlay; LLM response is suppressed.
4. **Clinician review:** All LLM response templates and prompt engineering must be reviewed and signed off by a licensed mental health clinician before any release to users.
5. **Hallucination guard:** LLM output is constrained to prompt questions only (e.g., "What does that feeling remind you of?") — never to factual statements about mental health.
6. **No cloud inference:** All inference on-device. No API calls to any external LLM service.

### 6.4 Content Review Requirements

Before any public release:
- All 20+ tiny-steps micro-actions reviewed by a licensed clinician for clinical appropriateness
- All Safety Plan templates reviewed against current Stanley-Brown protocol guidelines
- All crisis phrase detection keyword lists reviewed by a clinical psychologist
- All onboarding and disclaimer copy reviewed by a clinical psychologist and a legal counsel
- All journaling prompts reviewed for potential harm to vulnerable populations

### 6.5 Ethical Product Commitments

| Commitment | Implementation |
|---|---|
| No manipulation | No dark patterns, no artificially generated urgency, no emotional manipulation to increase engagement |
| No pathologising | No diagnostic language; no implication that the user has a disorder |
| No exploitation of vulnerability | No premium paywalls during active distress (e.g., "Unlock breathing exercises — subscribe now") |
| Transparent scope | Scope limitations stated clearly in onboarding and persistent disclaimer |
| User data ownership | User can export their data and delete all local data at any time |
| No discriminatory design | Mood selectors, copy, and visuals tested for cultural neutrality and accessibility |

### 6.6 Mitigation of Known Harms and Null Results

Based on research into digital mental health interventions, Firefly incorporates structural safeguards against known harms:
- **Mood Tracking and Rumination:** Constant mood logging can encourage circular thinking and hyper-monitoring. Firefly mitigates this by not pushing notifications for mood tracking and limiting the display of historical data to avoid triggering rumination.
- **Expressive Writing Risks:** While journaling is beneficial, it can exacerbate distress in vulnerable populations (e.g., severe PTSD) if it triggers reliving of trauma without resolution. Firefly includes a crisis phrase detection overlay that gently routes users to the Safety Plan if acute distress language is detected, and positions journaling as an optional, later-tier feature.
- **Unguided Mental Health App Shortfalls:** Many unguided apps suffer from a well-documented "efficacy gap," yielding negligible real-world results despite controlled trial success, often due to low motivation, manipulative gamification, or misleading advice. Firefly prioritizes user emotional safety over retention metrics, using utility over achievement (no streaks, no guilt) and ensuring robust crisis guardrails to avoid mishandling disclosures of self-harm.

---

## 7. Validation & Quality Framework

### 7.1 Zero-Telemetry Validation Constraints

Because Firefly transmits no data, standard product analytics (funnel analysis, A/B testing, retention metrics) are unavailable. Validation must rely entirely on consented external research protocols.

### 7.2 Usability Testing Protocol

**Phase:** Prior to and during Phase 7 (Accessibility & Release)
**Method:** Moderated think-aloud sessions, 8–12 participants
**Participant criteria:** Adults who self-report experiencing stress or low mood in the past 3 months; no current acute crisis; diverse in age (18–65), gender, and digital literacy

**Test scenarios:**
1. "You've had a difficult day. Open the app and do what feels right." (unguided)
2. "You're feeling lonely at 11pm. Use the app to do something about it." (scenario-guided)
3. "You want to write down what you're feeling but you want it to disappear in a week." (task-specific)
4. "Something doesn't feel right. Find your safety plan." (emergency access test)

**Metrics:**
- Time to first action (check-in → recommendation → intervention start)
- Task completion rate for Safety Plan access
- Qualitative: emotional tone of interaction ("Did it feel calm?", "Did anything feel pressuring?")
- Accessibility: all tasks attempted with VoiceOver/TalkBack enabled

### 7.3 Coping Self-Efficacy Pilot Protocol

**Aligned with Bush et al. 2017 methodology:**

**Instrument:** Coping Self-Efficacy Scale (CSE; Chesney et al. 2006) — 26-item validated measure
**Design:** Pre-post pilot, 4–8 weeks, consented participants (n ≥ 30)
**Primary outcome:** CSE score change from baseline to week 4 and week 8
**Secondary outcomes:** GAD-7 (anxiety), PHQ-2 (depression), app engagement (self-reported session frequency)
**Analysis:** Paired t-test pre/post; descriptive statistics on engagement; qualitative thematic analysis of exit interviews

**Ethical requirements:**
- IRB/Ethics board approval before any participant recruitment
- Informed consent including scope limitations
- Exclusion criteria: active suicidal ideation, current inpatient or intensive outpatient treatment, severe PTSD
- Safety monitoring plan: all participants given crisis resources at onboarding; study team available for referral

### 7.4 SAST & Security Verification Pipeline

**Pre-release mandatory gates:**

| Check | Tool | Pass Criteria |
|---|---|---|
| Network package audit | `scripts/security_gate.sh` grep against `pubspec.lock` | Zero forbidden packages present |
| Static analysis | `dart analyze --fatal-infos` | Zero warnings or errors |
| Security rules | Semgrep with `.semgrep/firefly_security.yaml` | Zero violations |
| Binary analysis | MobSF against release APK and IPA | Zero high or critical findings |
| Network interception | Charles Proxy / mitmproxy on emulator during full app session | Zero outbound requests of any kind |
| Screenshot prevention | Android emulator screenshot during active session | Returns pure black image |
| App switcher blur | iOS simulator backgrounding | App thumbnail shows blur overlay |
| Backup exclusion | `adb backup -apk app.firefly > backup.ab` | `backup.ab` contains no app data |
| DB encryption | DB Browser for SQLite on raw `.db` file | File unreadable without key |
| Privacy label accuracy | App Store Connect + Google Play Data Safety review | All categories: "Not Collected" |

### 7.5 Accessibility Audit

**Standard:** WCAG 2.2 Level AAA for text; Level AA for interactive elements
**Tools:** Flutter accessibility inspector, Colour Contrast Analyser, Sim Daltonism (colour blindness), VoiceOver (iOS), TalkBack (Android)

**Mandatory passing criteria before v1.0 release:**
- Zero WCAG AA failures on any screen
- All touch targets ≥ 56×56dp verified via Semantics debugger
- Full app navigable with VoiceOver/TalkBack enabled (no dead-end focus traps)
- All screens verified at 200% system font scale: no overflow, no truncation of primary content
- All animations verified to collapse at `disableAnimations: true`

---

## Appendix A: Feature Evidence Summary

| Feature | FR/RM ID | Evidence Level | Key Citation |
|---|---|---|---|
| Affect check-in / mood monitoring | FR-01 | Moderate | Linardon et al. (2024 meta-analysis of 176 RCTs) — mood monitoring as effective moderator |
| Cyclic sighing | FR-02 | Moderate | Balban et al. 2023 (Cell Reports Medicine) — produced greater improvements than mindfulness |
| 5-4-3-2-1 grounding | FR-02 | Weak (clinical consensus) | CBT/DBT clinical use; pilot HRV studies; no large-scale RCT |
| Behavioral activation | FR-03 | Moderate-strong | Psychol Med 2021;51(9) — g=0.83 vs. inactive controls |
| Stanley-Brown Safety Plan | FR-04 | Moderate | Stanley et al. 2018 (JAMA Psychiatry); ED-SAFE 2 (2023) |
| Expressive journaling | FR-05 | Weak-mixed | Frattaroli 2006; newer meta-analyses show small effects, risks for vulnerable |
| Loneliness / reaching out | FR-06 | Moderate (basic science) | Kumar & Epley 2023 (J Pers Soc Psychol); Masi et al. 2011 |
| Hope Box / virtual coping | FR-07 | Weak (single RCT) | Bush et al. 2017 (Psychiatric Services) — coping self-efficacy only |
| Gentle progress (no streaks) | FR-08 | Indirect | Baumel et al. 2019 (engagement data); literature on gamification harms |
| One-Session Reset | RM-01 | Strong | Schleider et al. 2025 (Annual Review) — 83% of 24 reviews positive (SMD -0.25) |
| Thought Untangler | RM-02b| Moderate | Neff's self-compassion research |

---

## Appendix B: Glossary

| Term | Definition |
|---|---|
| Affect labeling | The act of naming one's emotional state, shown to reduce amygdala reactivity |
| Behavioral activation (BA) | Evidence-based intervention scheduling pleasurable or valued activities to interrupt depression-inertia cycles |
| Cyclic sighing | Breathing technique: double inhale + prolonged exhale; demonstrated in Balban et al. 2023 to improve mood and reduce respiratory rate |
| DEK | Data Encryption Key — the AES-256 key used to encrypt the SQLite database |
| Drift | Type-safe SQLite ORM for Flutter with reactive stream queries |
| HKDF | HMAC-based Key Derivation Function — used to derive feature-specific subkeys from the Master Key |
| SQLCipher | Transparent AES-256-CBC encryption layer for SQLite database files |
| Stanley-Brown protocol | Evidence-based Safety Planning Intervention developed by Barbara Stanley and Gregory Brown; validated in JAMA Psychiatry |
| TEE | Trusted Execution Environment — hardware-isolated processor for cryptographic key operations |
| TTL | Time-To-Live — expiry timestamp after which a journal entry is automatically erased |
| Vosk | Open-source, fully offline speech recognition engine; processes audio locally with no cloud dependency |
| WCAG 2.2 AAA | Web Content Accessibility Guidelines 2.2, Level AAA — highest accessibility standard; requires ≥ 7:1 contrast for normal text |

---

*Document maintained by the Firefly Product Team. Any change to FR scope, NFR thresholds, or safety guardrails requires sign-off from both Product and a licensed clinical reviewer before implementation.*
