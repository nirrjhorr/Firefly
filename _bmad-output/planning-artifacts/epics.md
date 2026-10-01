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
- **Epic 2: Stanley-Brown Safety Plan (Priority First)** (Sprint 2 - Completed)
- **Epic 3: Affect Check-In & Deterministic Recommendation Engine** (Sprint 2 - Completed)
- **Epic 4: Respiration & Grounding Engine** (Sprint 3 - Completed)
- **Epic 5: Tiny Steps Mode (Behavioral Activation)** (Sprint 3 - Completed)
- **Epic 6: Expressive Journaling & Unsent Letters** (Sprint 4 - Current Priority)

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

---

## Epic 4: Respiration & Grounding Engine

Implement the clinical-grade respiration and sensory grounding engine (FR-02), featuring evidence-backed cyclic sighing (4s inhale / 8s exhale), gapless offline soundscapes, synchronized haptic cues, high-performance `CustomPainter` bloom visualizer, 5-4-3-2-1 sensory grounding mode, and full-screen screen integration routed from the affect check-in.

### Story 4.1: Audio & Haptics Hardware Ports and Adapters

As a developer,
I want hardware abstraction ports and concrete adapters for audio playback and device haptics,
So that respiration audio and tactile feedback run deterministically offline and remain easily testable with mocks.

**Acceptance Criteria:**
- Given abstract interfaces `AudioPlayerPort` and `HapticsPort` in `core/contracts/`,
- When `JustAudioPlayerAdapter` is invoked,
- Then offline audio assets (`cyclic_sigh_ambience.mp3`, `gentle_rain.mp3`, `grounding_chime.mp3`) loop gaplessly with a 300ms volume fade-in/fade-out,
- And audio errors fail silently without interrupting ongoing respiration sessions;
- When `FlutterHapticsAdapter` is invoked,
- Then `phaseTransition(inhale)` emits a double light impact spaced 100ms apart,
- And `phaseTransition(exhale)` emits a single light impact,
- And `groundingConfirm()` emits a crisp selection click;
- And unit tests with mocks verify port behavior and error handling.

### Story 4.2: Respiration State Management & Cyclic Sighing Engine

As a user regulating acute distress,
I want a reactive breathing controller running a precise cyclic sighing cadence (4s inhale / 8s exhale),
So that my autonomic nervous system is guided toward parasympathetic calm without requiring active cognitive counting.

**Acceptance Criteria:**
- Given `BreathingSessionNotifier` extending Riverpod `AsyncNotifier` (or `StateNotifier`),
- When a cyclic sighing session starts,
- Then a periodic ticker (50ms) drives normalized `phaseProgress` (0.0 to 1.0) and updates phase (`inhale` 4000ms, `exhale` 8000ms),
- And each phase transition triggers corresponding haptic feedback via `HapticsPort`,
- And `ref.onDispose` cleanly stops the ticker, halts audio playback, and cancels ongoing haptics,
- And unit tests verify cadence timing, cycle count increments, and memory leak safety.

### Story 4.3: Cyclic Sigh Bloom Visualizer (CustomPainter)

As a user following a breathing session,
I want an organic, smoothly expanding bloom visualizer that guides my breath without visual noise or frame drops,
So that I can follow the pacing effortlessly with eyes open or in peripheral vision.

**Acceptance Criteria:**
- Given `CyclicSighBloomPainter` extending `CustomPainter`,
- When rendering during cyclic sighing,
- Then the bloom smoothly scales from 50dp radius at rest/exhale to 120dp at peak inhale,
- And 3 concentric glow rings render with decaying opacity,
- And the color smoothly transitions between calm sage (`#4A7862`) on inhale and dusk blue (`#3B5B6C`) on exhale,
- And `shouldRepaint` returns false when progress or phase has not changed,
- And when reduced motion is enabled, the animation collapses to a calm, static indicator.

### Story 4.4: 5-4-3-2-1 Sensory Grounding Mode

As an overwhelmed user experiencing sensory or cognitive overload,
I want a step-by-step 5-4-3-2-1 sensory grounding exercise,
So that I can anchor myself in my immediate physical reality through guided perceptual prompts.

**Acceptance Criteria:**
- Given `GroundingController` and `GroundingPromptCard`,
- When grounding mode is activated,
- Then sequential prompt cards guide the user through 5 things to see, 4 to touch, 3 to hear, 2 to smell, and 1 to taste,
- And each card tap advances to the next step accompanied by a haptic confirmation click,
- And the user can gracefully finish early or repeat any step,
- And unit tests verify complete progression through all 5 sensory stages.

### Story 4.5: Breathing & Grounding Screen Integration

As a user routed from the affect check-in or home navigation,
I want a complete, low-stimulation respiration screen with soundscape controls and emergency safety access,
So that I can complete a calming session in comfort and exit whenever I need to.

**Acceptance Criteria:**
- Given `BreathingGroundingScreen` connected to GoRouter (`/home/breathe`),
- When opened with optional query parameter `?mode=grounding`,
- Then the appropriate mode (Cyclic Sighing vs 5-4-3-2-1 Grounding) is displayed,
- And a full-screen canvas in `#111518` displays the centered bloom or grounding card with phase typography and cycle count,
- And the user can choose ambient soundscapes (cyclic sigh ambience, gentle rain, grounding chime, or mute) with preferences saved,
- And an accessible secondary exit button allows closing the session cleanly at any time,
- And the persistent SOS overlay button remains accessible for immediate safety.

---

## Epic 5: Tiny Steps Mode (Behavioral Activation)

Implement the behavioral activation micro-action system (FR-03) designed to interrupt depression-inertia and anxiety paralysis through 2-minute actionable steps matched to the user's current energy and affect state, with calm tactile feedback and zero gamification.

### Story 5.1: Curated Behavioral Micro-Action Library & Domain Models

As a developer,
I want domain models and an offline library of 20+ evidence-based micro-actions,
So that low-energy users receive immediate, practical behavioral activation tasks without requiring network access.

**Acceptance Criteria:**
- Given `TinyStep` domain model (id, title, description, category, energyLevel 1-5, durationMinutes ≤ 2),
- When loaded,
- Then at least 20 curated micro-actions exist categorized across sensory, physical, environmental, and nourishment categories,
- And all actions are achievable within 2 minutes with zero barrier to entry,
- And unit tests verify library validation and non-empty categorization.

### Story 5.2: Tiny Steps State Controller & Recommendation Matching

As a user feeling paralyzed or lacking momentum,
I want a state controller that matches 3 relevant tiny steps to my latest check-in state,
So that I am offered manageable options tailored to my current energy without feeling overwhelmed.

**Acceptance Criteria:**
- Given `TinyStepsController` extending Riverpod `AsyncNotifier` (or `StateNotifier`),
- When initialized,
- Then it evaluates the active `AffectState` and filters 3 tailored micro-actions matching the user's energy level,
- And users can request an alternative set of 3 steps ("Show different options") without guilt or penalty,
- And unit tests verify state filtering, fallback for uninitialized affect state, and shuffle behavior.

### Story 5.3: Tiny Steps Screen & Micro-Action Interaction UI

As a user trying to take a small positive action,
I want an accessible, low-pressure screen displaying 3 actionable cards with tactile completion feedback,
So that completing a small step feels grounding and supportive rather than competitive.

**Acceptance Criteria:**
- Given `TinyStepsScreen` connected to GoRouter (`/home/tiny-steps`),
- When displayed,
- Then 3 full-width action cards render with touch targets ≥ 72dp and clear typography,
- And tapping "Done" triggers a warm double-tap haptic and gentle sage highlight without gamified streaks, badges, or confetti,
- And an "I'll do this later" option allows closing the screen without judgment,
- And returning to Home updates the active card to reflect completed action or offers a gentle rest prompt.

---

## Epic 6: Expressive Journaling & Unsent Letters

Implement the confidential expressive journaling and unsent letters system (FR-05), featuring application-layer AES-256-GCM double encryption on top of SQLCipher, cryptographic erasure and TTL auto-delete engine, offline speech-to-text (Vosk) on a background isolate, and a distraction-free writing UI designed to reduce cognitive load and prevent rumination traps.

### Story 6.1: Application-Layer AES-256-GCM Double Encryption & Cryptographic Erasure

As a privacy-conscious user recording deep emotional distress or unsent letters,
I want my journal entries protected by a second layer of AES-256-GCM encryption with cryptographic erasure,
So that even in forensic NAND extraction or database key compromise, my raw thoughts remain permanently unreadable.

**Acceptance Criteria:**
- Given `JournalCryptoService` using `package:cryptography`,
- When encrypting plaintext,
- Then an HKDF subkey is derived from the Master Key using context `firefly-journal-content-v1`,
- And encryption uses AES-256-GCM with a 12-byte secure random nonce and 16-byte authentication tag,
- And plaintext bytes in memory are securely overwritten (`_zeroMemory`) immediately after encryption/decryption,
- And decryption verifies the authentication tag, rejecting tampered ciphertext,
- And a cryptographic erasure mechanism enables immediate subkey version rotation and ciphertext zero-overwriting.

### Story 6.2: Journal Drift Database DAO, Repository & TTL Expiry Engine

As a developer,
I want an encrypted Drift DAO and repository supporting CRUD operations and automated TTL deletion,
So that expired entries and auto-delete unsent letters are automatically purged without manual intervention.

**Acceptance Criteria:**
- Given `JournalDao` attached to `JournalEntries` table,
- When entries are saved,
- Then encrypted ciphertext, contentType (`text` or `voice`), `ttlDeleteAtUnix`, `isAutoDeleteEnabled`, and `wordCount` are stored,
- And `JournalRepository` interface and implementation provide reactive streams (`watchEntries()`) and `getEntryById()`,
- And automated cleanup query (`purgeExpiredEntries()`) runs on launch and entry write to remove all entries where `ttlDeleteAtUnix <= currentTime`,
- And unit tests verify persistent storage, TTL purge logic, and repository stream updates.

### Story 6.3: Offline Speech-to-Text Port & Vosk Voice Recognition Adapter

As a user feeling too exhausted, numb, or overwhelmed to type,
I want an offline voice-to-text input option powered by Vosk,
So that I can articulate my feelings verbally with 100% on-device privacy and zero audio data sent to any network.

**Acceptance Criteria:**
- Given abstract `VoiceRecognitionPort` in `lib/core/contracts/`,
- When listening is triggered,
- Then speech recognition operates on a dedicated background isolate keeping UI thread RAM overhead < 50MB,
- And partial speech transcriptions stream reactively to the caller via `transcribePartial()`,
- And `transcribeFinal()` returns the committed transcript upon silence or stop,
- And disposing or stopping the adapter cleanly releases audio resources and isolates without memory leaks.

### Story 6.4: Journal State Management & Unsent Letters Controller

As a user composing an expressive journal or unsent letter,
I want a responsive state controller managing draft persistence, auto-delete intervals, and instant "burn" capabilities,
So that I can safely release heavy feelings with full control over their lifecycle.

**Acceptance Criteria:**
- Given `JournalEditorController` and `JournalListController` using Riverpod,
- When composing,
- Then word count is reactively calculated and drafts are securely cached in state,
- And users can configure TTL options: None (keep indefinitely), 1 hour, 24 hours, or 7 days,
- And an unsent letter "burn / instant wipe" action completely purges the entry and its ciphertext with haptic feedback,
- And unit tests verify controller state transitions, TTL calculation, draft saving, and purge events.

### Story 6.5: Distraction-Free Journal Editor Screen & Unsent Letters UI

As a user seeking emotional catharsis without distraction,
I want a serene, distraction-free writing canvas with offline voice dictation and clear privacy controls,
So that I can write freely without judgment, pressure, or cognitive overwhelm.

**Acceptance Criteria:**
- Given `JournalEditorScreen` and `JournalListScreen` connected to GoRouter (`/home/journal`),
- When the editor opens,
- Then a clean, dark `#111518` canvas renders with fluid Atkinson Hyperlegible typography and touch targets ≥ 56dp,
- And an offline microphone button toggles Vosk voice dictation with a calming pulse indicator and partial transcript insertion,
- And a TTL selector badge clearly displays the auto-delete horizon (e.g. "Auto-deletes in 24h" or "Unsent Letter"),
- And an "Unsent Letter: Burn Now" button allows immediate destruction with a calm confirmation and tactile fade,
- And the journal list displays cards with creation date, word count, TTL countdown chips, and quick delete,
- And widget tests verify screen rendering, voice toggle interaction, TTL selection, and burn/delete behavior.
