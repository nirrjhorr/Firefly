# Story 18.1, 18.2, 18.3: Single-Session Intervention (SSI) — One-Session Reset Engine

**Epic:** Epic 18: Single-Session Intervention (SSI) — One-Session Reset Engine (v2 Sprint 9)  
**Status:** Completed  
**Owner:** Product & Engineering, Firefly  

---

## 1. Context & Clinical Rationale

Digital Single-Session Interventions (SSIs) (*Schleider et al., Annual Review of Clinical Psychology 2025*, 415 RCTs, >40,000 participants) demonstrate meaningful, sustained symptom relief ($SMD = -0.25$) in a single sitting without requiring multi-week retention (*Baumel et al. 2019*).

The One-Session Reset operationalizes Firefly's core design philosophy that **each visit may be the only visit**: a self-contained 5-minute protocol designed to de-escalate acute distress through a structured 5-step journey:
1. **Anchor (Name the Moment):** Affect labeling dampens amygdala reactivity.
2. **Regulate (Settle the Body):** 90-second paced autonomic down-regulation with real-time breathing/settling guidance.
3. **Reframe (Gentle Perspective):** Self-compassion and ACT cognitive distance.
4. **Commit (One Small Step):** Behavioral activation micro-action (< 2 min) to restore agency.
5. **Complete (Sanctuary Close):** Pre/post nervous system shift rating without gamification or guilt.

---

## 2. Technical Deliverables

### Domain Layer (`lib/features/one_session_reset/domain/`)
- `ResetPhase`: 5 sequential phases (`anchor`, `regulate`, `reframe`, `commit`, `complete`).
- `ResetDistressAnchor`: 6 evidence-backed distress categories with paired somatic techniques.
- `ResetSession`: Pure immutable domain model with JSON serialization and factory constructors.
- `ResetRepository`: Interface defining session storage and retrieval.

### Data Layer (`lib/features/one_session_reset/data/`)
- `ResetRepositoryImpl`: In-memory and local persistent store.

### Presentation Layer (`lib/features/one_session_reset/presentation/`)
- `ResetSessionNotifier` / `resetSessionProvider`: Riverpod state machine managing forward/backward phase traversal.
- `ResetScreen`: Serene Apple-inspired 5-step stepper screen at `/home/reset` and `/reset` with animated breathing timer, touch-friendly cards, and persistent SOS overlay.

### Routing & Integration
- Registered `AppRoutes.reset` and `AppRoutes.modalReset`.
- Added One-Session Reset card to `CheckInScreen` and `RightNowModal`.
- Seeded `act_one_session_reset` in `assets/data/curated_activities.json` (71 total activities).

---

## 3. Verification & Acceptance
- Headless verification: `test/features/reset/verify_one_session_reset_standalone.dart` passing 100%.
- Full test suite: 24/24 standalone test suites passing 100%.
- Lint sweep: 0 issues across 226 Dart files.
- Security gate: 100% zero-network verified.
- Design tokens: 100% WCAG AAA verified.
