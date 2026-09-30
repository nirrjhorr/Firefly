# Firefly - Architectural Roadmap Breakdown

## Overview

This document provides the complete epic and user story breakdown for Firefly, decomposing the product requirements from the PRD, UX Design tokens, and Architecture specifications into implementable, independently verifiable stories.

## Requirements Inventory

### Functional Requirements

- **FR-01: State-Matched Affect Check-In** (P0): Mood anchor (5 moon-phase tiles), energy slider ("Still → Moving"), 5-dot anxiety and loneliness selectors, deterministic routing engine (< 1ms), result card with action suggestion, home screen integration.
- **FR-02: Respiration & Grounding Engine** (P0): Cyclic sighing (4s inhale / 8s exhale), visual bloom custom painter, haptic sync, offline soundscapes, 5-4-3-2-1 grounding mode.
- **FR-03: Tiny Steps Mode (Behavioral Activation)** (P1): Curated 20+ micro-action library filtered by energy and affect, completion haptic feedback, 2-minute limit.
- **FR-04: Stanley-Brown Offline Safety Plan** (P0 - Priority First): 6-step Stanley-Brown crisis plan, contact call/sms intents with pre-written templates, crisis lines, persistent 1-tap SOS overlay, and panic fast exit (< 100ms screen blanking and provider reset).
- **FR-05: Expressive Journaling & Unsent Letters** (P2): Plain-text private journaling, offline STT (Vosk), application-layer AES-GCM double encryption, auto-delete TTL.

### Non-Functional Requirements & Architectural Constraints

- **NFR-01: Zero Network Policy**: `FireflyHttpOverride` installed as first line in `main()`, zero networking packages, complete offline operation.
- **NFR-02: Cryptographic Security**: SQLCipher AES-256-CBC, hardware-backed key derivation (`KeyManager`), HKDF subkey derivation.
- **NFR-03: Layered Clean Architecture**: Presentation (Riverpod `AsyncNotifier`) → Domain (Repository interfaces, sealed `Result<T, E>`) ← Data (Drift DAOs + SQLCipher).
- **NFR-04: Low-Stimulation Design System**: Atkinson Hyperlegible, Plus Jakarta Sans, JetBrains Mono, dark canvas `#111518`, sage `#4A7862`, crisis coral `#B05454`, touch targets ≥ 56dp, no streaks or gamification.

---

## Roadmap Structure

- **Epic 1: Core Scaffolding, Encrypted Storage & Design Foundations** (Sprint 1 - Completed)
- **Epic 2: Stanley-Brown Safety Plan (Priority First)** (Sprint 2 - Current Priority)
- **Epic 3: Affect Check-In & Deterministic Recommendation Engine** (Sprint 2 - Core Engine)

---

## Epic 1: Core Scaffolding, Encrypted Storage & Design Foundations

Establish the clean workspace, strict linter configuration, zero-network enforcement, hardware key derivation, SQLCipher encrypted Drift database tables, and the low-stimulation design system tokens with basic router shell.

### Story 1.1: Project Scaffolding, Security Baseline & Error Handling

As a developer,
I want a clean, linted Flutter workspace configured with strict analysis rules, sealed Result types, and zero network overrides,
So that no unauthorized network traffic is ever possible and errors are handled safely.

**Acceptance Criteria:**
- Given the Flutter project root,
- When `analysis_options.yaml` is applied with strict type checks and lints,
- Then `FireflyHttpOverride` blocks all outbound HTTP connections,
- And sealed `Result<T, E>` is available in `core/errors/result.dart`.

### Story 1.2: Hardware Key Derivation & Security Engine

As a privacy-focused user,
I want my encryption keys to be hardware-backed and guarded by device biometrics or passcode,
So that my mental health data remains inaccessible to anyone else on the device.

**Acceptance Criteria:**
- Given the `KeyManager` and `BiometricGuard`,
- When the app is launched,
- Then the database encryption key is securely generated or retrieved from secure storage,
- And the key is dropped from memory on `lockApp()`.

### Story 1.3: Encrypted Database Engine (Drift + SQLCipher)

As a developer,
I want all application data tables defined in Drift and encrypted with SQLCipher PRAGMAs,
So that all user entries are protected with AES-256 encryption at rest.

**Acceptance Criteria:**
- Given the Drift database schemas for CheckIns, Journal, SafetyPlan, and Preferences,
- When the database is opened with the key from KeyManager,
- Then SQLCipher PRAGMAs (`cipher_page_size = 4096`, `cipher_hmac_algorithm = HMAC_SHA512`, `secure_delete = ON`) are applied,
- And all tables are generated and queryable.

### Story 1.4: Design System Tokens & Base Navigation

As a user under emotional distress,
I want a serene, low-stimulation visual interface with accessible typography and shell navigation,
So that using the app reduces cognitive overload rather than compounding it.

**Acceptance Criteria:**
- Given the design system specifications,
- When the theme is applied,
- Then low-stimulation color palettes, fluid typography tokens, and spacing tokens are active,
- And `go_router` shell navigation renders with the persistent SOS button accessible.

---

## Epic 2: Stanley-Brown Safety Plan (Priority First)

Implement the full Stanley-Brown Safety Planning Intervention (SPI) across 6 evidence-based steps, local encrypted storage, full CRUD operations via Riverpod AsyncNotifier, contact actions with offline `tel:` and `sms:` intents, pre-written reach-out templates, crisis hotline emergency lines, and a high-speed panic button (< 100ms) with screen blanking and state purging.

### Story 2.1: Safety Plan Domain Models & Repository Interface

As a developer,
I want clear domain models and an abstract repository interface for the Stanley-Brown Safety Plan,
So that the safety architecture adheres strictly to clean architectural boundaries.

**Acceptance Criteria:**
- Given the Stanley-Brown 6-step clinical protocol,
- When the domain entities are defined,
- Then models exist for `SafetyPlan`, `SafetyPlanWarning`, `SafetyPlanStep` (internal coping, distraction places, environment safety), `SafetyPlanContact` (with professional flag and relationship), and crisis lines,
- And `SafetyPlanRepository` defines abstract CRUD methods returning `Result<T, Exception>`.

### Story 2.2: Safety Plan Drift Database Implementation & DAOs

As a developer,
I want Drift DAOs and repository implementations for persisting safety plans, warnings, steps, and contacts,
So that all safety plan data is reliably stored in the local encrypted SQLCipher database with cascade deletion.

**Acceptance Criteria:**
- Given `SafetyPlanRepositoryImpl` and Drift tables,
- When a user saves or updates steps, contacts, or warning signs,
- Then data is persisted to SQLite with foreign keys and cascade delete,
- And repository methods return `Ok` on success or `Err` with failure diagnostics.

### Story 2.3: Safety Plan Riverpod AsyncNotifier Controller

As a user,
I want reactive state management that automatically loads and autosaves my safety plan,
So that changes I make under distress are never lost.

**Acceptance Criteria:**
- Given `SafetyPlanController` extending Riverpod `AsyncNotifier`,
- When steps, contacts, or warnings are modified,
- Then changes are automatically committed to the repository,
- And loading and error states are safely handled without disrupting the user.

### Story 2.4: Stanley-Brown Safety Plan Screen & Interactive Accordions

As a user in distress,
I want to view my personalised safety plan in 6 clean accordion cards with one-tap calling and texting,
So that I can follow my coping steps and reach my trusted contacts immediately without cognitive strain.

**Acceptance Criteria:**
- Given the `SafetyPlanScreen`,
- When displayed to the user,
- Then the 6 Stanley-Brown steps are rendered as accessible accordion cards with clear typography,
- And each contact provides one-tap `tel:` call and `sms:` text actions with pre-written compassionate templates,
- And dedicated emergency crisis lines are clearly accessible.

### Story 2.5: Safety Plan Editor Screen & Contact Management

As a user preparing for future difficult moments,
I want a full-screen editor where I can add, modify, and reorder my warning signs, coping strategies, and contacts,
So that my safety plan accurately reflects what truly helps me.

**Acceptance Criteria:**
- Given `SafetyPlanEditorScreen`,
- When editing any of the 6 steps or emergency contacts,
- Then inputs have touch targets ≥ 56dp and autofocus handling,
- And contacts can be added, updated, or deleted with relationship tags and professional indicators,
- And edits autosave reliably to the local store.

### Story 2.6: SOS Floating Overlay & Fast Panic Exit Mechanism

As a user needing immediate safety or immediate privacy,
I want 1-tap SOS access from any screen and a rapid panic exit sequence (< 100ms) on long-press,
So that I can get help instantly or blank the app and lock my data if someone approaches.

**Acceptance Criteria:**
- Given `SosOverlayButton` in `MainShellScaffold`,
- When tapped,
- Then the app navigates immediately to `AppRoutes.safetyPlan` via a smooth fade transition;
- When long-pressed (≥ 600ms),
- Then the panic sequence navigates to `PanicBlankScreen` (< 10ms), purges in-memory Riverpod providers (< 50ms), and drops the database encryption key via `BiometricGuard.lockApp()` (< 100ms).

---

## Epic 3: Affect Check-In & Deterministic Recommendation Engine

Implement the state-matched affect check-in flow with 5 moon-phase mood tiles, "Still → Moving" energy slider, anxiety and loneliness selectors, a pure deterministic recommendation engine routing users to evidence-based interventions in < 1ms, encrypted persistence of check-ins, and the post-check-in recommendation result card.

### Story 3.1: Pure Deterministic Recommendation Engine

As a developer,
I want a pure, deterministic recommendation engine function with 100% unit test coverage,
So that user states are consistently and safely routed to the correct intervention without cloud dependencies or unpredictable LLM hallucinations.

**Acceptance Criteria:**
- Given `AffectState` (moodCategory, energyLevel 1–5, anxietyLevel 1–5, lonelinessLevel 1–5),
- When `RecommendationEngine.evaluate(AffectState)` is invoked,
- Then anxiety ≥ 4 routes to breathing (`/home/breathe`),
- And low mood with energy ≤ 2 routes to tiny steps (`/home/tiny-steps`),
- And loneliness ≥ 4 routes to loneliness comfort (`/home/loneliness`),
- And overwhelmed mood routes to 5-4-3-2-1 grounding (`/home/breathe?mode=grounding`),
- And moderate anxiety or low energy routes to expressive journaling (`/home/journal/new`),
- And calm/positive states route to tiny steps or hope box,
- And 100% of branches are covered by automated unit tests.

### Story 3.2: Check-In Domain Models & Drift Database Implementation

As a developer,
I want domain models and a Drift DAO repository for mood check-in entries,
So that check-in history is safely stored and aggregated in the encrypted database.

**Acceptance Criteria:**
- Given `CheckInEntry` domain entity and `CheckInRepository` interface,
- When `CheckInRepositoryImpl` records a check-in,
- Then mood category, energy, anxiety, loneliness, and suggested action are written to SQLCipher via Drift,
- And repository methods return `Result<T, Exception>`.

### Story 3.3: Check-In State Management Controller

As a user,
I want a responsive check-in controller that manages my selections and provides the resulting suggestion,
So that submitting my check-in transitions seamlessly into the recommended care action.

**Acceptance Criteria:**
- Given `CheckInController` extending Riverpod `AsyncNotifier`,
- When the user selects mood, energy, anxiety, and loneliness and taps submit,
- Then the state is persisted to the database and evaluated by the recommendation engine,
- And the state updates with the resulting `ActionSuggestion`.

### Story 3.4: Affect Check-In Screen UI

As a user experiencing acute emotions,
I want an intuitive, low-friction check-in screen with moon-phase tiles and peaceful sliders completable in < 30 seconds (≤ 5 taps),
So that I can register how I feel without feeling evaluated or overwhelmed.

**Acceptance Criteria:**
- Given `CheckInScreen`,
- When presented to the user,
- Then 5 `MoodTile` selectors (Heavy, Low, Here, Light, Open) are displayed,
- And an `EnergySlider` provides "Still → Moving" input with accessible touch targets,
- And 5-dot selectors capture anxiety and loneliness levels without intimidating clinical numeric labels,
- And a 56dp "I'm here" sage button triggers submission.

### Story 3.5: Affect Result Card & Home Screen Integration

As a user who just completed a check-in,
I want a clear, calm recommendation result card with an immediate single-tap CTA and an alternative options drawer,
So that I am guided directly to the right relief without decision paralysis.

**Acceptance Criteria:**
- Given `AffectResultCard`,
- When displayed after a check-in,
- Then the suggested intervention title, 1–2 sentence compassionate explanation, and estimated duration (≤ 2 min) are shown,
- And tapping the primary CTA navigates directly to the suggested route,
- And "Try something else" presents 3 subtle alternatives,
- And returning to Home shows the active suggestion or a prompt to check in.
