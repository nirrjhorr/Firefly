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
- **NFR-05: 6-Group Activity Architecture**: All 150+ activities must be mapped strictly into the 6 core engines (Movement & Somatic, Respiration, Grounding/Mindfulness, Cognitive Flow, Expression/Processing, Auditory/Social) to prevent UI bloat and ensure maintainability.

---

## Roadmap Structure

- **Epic 1: Core Scaffolding, Encrypted Storage & Design Foundations** (Sprint 1 - Completed)
- **Epic 2: Stanley-Brown Safety Plan (Priority First)** (Sprint 2 - Completed)
- **Epic 3: Affect Check-In & Deterministic Recommendation Engine** (Sprint 2 - Completed)
- **Epic 4: Respiration & Grounding Engine** (Sprint 3 - Completed)
- **Epic 5: Tiny Steps Mode (Behavioral Activation)** (Sprint 3 - Completed)
- **Epic 6: Expressive Journaling & Unsent Letters** (Sprint 4 - Completed)
- **Epic 7: Production Hardening, System Integration & Offline Model Packaging** (Sprint 5 - Completed)
- **Epic 8: Phase 1 Evidence-Supported Features** (Sprint 6 & 7 - Completed)
- **Epic 9: Phase 2 Exploratory Features** (Sprint 8 & 9 - Completed)
- **Epic 10: v2 Sprint 1 - Movement & Somatic Release** (Completed)
- **Epic 11: v2 Sprint 2 - Grounding, Sleep, Hope Box & Loneliness Suite** (Completed)
- **Epic 12: v2 Sprint 3 - Grounding, Mindfulness & Nature** (Completed)
- **Epic 13: v2 Sprint 4 - Cognitive Flow & Attention Switching** (Completed)
- **Epic 14: v2 Sprint 5 - Expression, Processing & Reframing** (Completed)
- **Epic 15: v2 Sprint 6 - Auditory, Restorative & Social Environments** (Completed)
- **Epic 16: Clinical Safety Guardrails & Production Verification** (v2 Sprint 7 - Active)
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

### Story 6.1: Application Layer AES GCM Double Encryption Crypto Erasure

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

### Story 6.2: Journal Drift Database DAO Repository TTL Engine

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

### Story 6.3: Offline Speech to Text Port Vosk Voice Adapter

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

### Story 6.4: Journal State Management Unsent Letters Controller

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

### Story 6.5: Journal Editor Screen Unsent Letters UI

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

---

## Epic 7: Production Hardening, System Integration & Offline Model Packaging

Harden the application into a verifiable, release-ready offline mental health companion. Provision real bundled assets (Vosk lightweight acoustic models, ambient audio soundscapes) directly in `assets/`, establish seamless end-to-end user navigation flows linking the Check-In recommendation engine with active interventions, strictly benchmark non-functional security constraints (zero-network enforcement, hardware key lifecycle, < 100ms panic button blanking), and implement end-to-end golden path verification.

### Story 7.1: Offline Audio Assets & Vosk Acoustic Model Bundling

As a user needing calming soundscapes and voice dictation without internet connectivity,
I want ambient audio and lightweight Vosk models packaged as bundled local assets in the build,
So that all grounding sounds and voice journaling work 100% offline out-of-the-box.

**Acceptance Criteria:**
- Given the Flutter app configuration and `pubspec.yaml`,
- When assets are declared and loaded at runtime,
- Then real offline audio loops (rain/stream/white-noise) are accessible in `assets/audio/` without external network dependencies,
- And a compressed Vosk model (e.g. `vosk-model-small-en-us`) is configured in `assets/models/` and loaded into the background isolate by `VoskVoiceAdapter`,
- And `HardwareAudioAdapter` verifies offline asset playback fallback without throws,
- And unit/integration tests verify that asset loading adheres to the `FireflyHttpOverride` zero-network policy.

### Story 7.2: End-to-End Home Navigation & State Integration Flows

As an emotionally overwhelmed user,
I want seamless navigation journeys from check-in results into matched interventions (Breathing, Grounding, Tiny Steps, Journal, Safety Plan),
So that I experience zero friction or broken links when following recommendations.

**Acceptance Criteria:**
- Given `HomeScreen` and GoRouter route definitions,
- When a user selects a recommended action on `AffectResultCard`,
- Then navigation routes directly to the appropriate destination: `/breathing`, `/grounding`, `/tiny-steps`, `/journal`, or `/safety-plan`,
- And state from the check-in (affect score, energy level) smoothly initializes and contextualizes the destination screen,
- And completing or exiting an intervention returns cleanly to the Home shell with updated status or a calm resting state,
- And widget tests verify end-to-end route transitions and state synchronization across all modules.

### Story 7.3: NFR Security & Latency Benchmarks (Panic Button & Cryptographic Wipe)

As a privacy-dependent user facing acute distress or privacy intrusion,
I want the panic button to blank the screen and wipe decrypted state in under 100ms, with zero network leakage,
So that my mental health state and sensitive thoughts are instantly protected.

**Acceptance Criteria:**
- Given the active application running in any state (Check-in, Breathing, Journaling, Safety Plan),
- When the persistent SOS panic button or fast-exit trigger is tapped,
- Then screen blanking and navigation reset execute in < 100ms,
- And database encryption keys and decrypted journal plaintexts in memory are zero-overwritten (`_zeroMemory`),
- And automated benchmark tests confirm latency constraints (< 100ms for UI purge),
- And a security audit test verifies that `FireflyHttpOverride` catches and blocks any simulated socket or HTTP egress attempts.

### Story 7.4: Golden Path E2E Smoke & Accessibility Compliance Suite

As a user with sensory sensitivity or low energy,
I want an accessible interface that adheres strictly to WCAG AA contrast and touch target standards across the entire app lifecycle,
So that using Firefly never induces sensory overload or physical frustration.

**Acceptance Criteria:**
- Given the end-to-end application suite,
- When tested across the complete user golden path (Onboarding → Check-in → Intervention → Safety Plan),
- Then all interactive touch targets meet or exceed 56dp (72dp for Tiny Steps cards),
- And color contrast ratios across dark canvas (`#111518`), typography, and interactive controls pass WCAG AA (≥ 4.5:1 for normal text, ≥ 3.0:1 for large text),
- And an automated E2E integration test verifies the complete flow without crashes or memory leaks,
- And a full test run validates all suites pass with zero regressions.

---

## Epic 8: Phase 1 Evidence-Supported Features

Implement the immediate next priorities identified in the PRD, focusing on loneliness, sleep, and coping mechanisms. 

### Story 8.1: Hope Box & Guess vs. Reality Models (Sprint 6)

As a developer,
I want to define domain models and encrypted data access for the Hope Box and Social Experiment,
So that users can store media and log social predictions securely offline.

**Acceptance Criteria:**
- Given `HopeBoxItem` and `SocialExperiment` domain models,
- When data is stored,
- Then it is encrypted in the local SQLite database via Drift DAOs,
- And media (photos/audio) is stored securely on the device and purged if deleted.

### Story 8.2: Hope Box & Social Experiment Screens (Sprint 6)

As a user,
I want a private space for uplifting media and a way to test my social predictions,
So that I can combat loneliness and manage low mood.

**Acceptance Criteria:**
- Given the `HopeBoxScreen` and `SocialExperimentScreen`,
- When navigating to them,
- Then users can view/add media and log expected vs. actual outcomes of social interactions,
- And the UI adheres to the low-stimulation design system.

### Story 8.3: Wind-Down & One-Session Reset Models (Sprint 7)

As a developer,
I want to establish the data structures for Sleep Diaries and One-Session Resets,
So that users have structured, persistent records of their sleep and problem-solving commitments.

**Acceptance Criteria:**
- Given the `SleepDiary` and `OneSessionReset` models,
- When instances are created,
- Then they are properly saved in the encrypted store.

### Story 8.4: Wind-Down & One-Session Reset UIs (Sprint 7)

As a user struggling with sleep or acute overwhelm,
I want a gentle pre-bed worry dump and a 5-10 minute problem-solving module,
So that I can rest better or break out of a paralyzed state even if I don't use the app regularly.

**Acceptance Criteria:**
- Given the `WindDownScreen` and `OneSessionResetScreen`,
- When interacted with,
- Then the user is gently guided through CBT-I sleep components or a single-session problem/skill/commitment flow.

---

## Epic 9: Phase 2 Exploratory Features

Implement the later exploratory features that extend the app's physical and environmental interventions.

### Story 9.1: Movement Snacks & Awe Walk (Sprint 8)

As a low-energy or anxious user,
I want micro-movement options and guided 15-minute awe walks,
So that I can gently re-engage my body and shift my perspective.

**Acceptance Criteria:**
- Given the offline libraries for Movement Snacks and Awe Walk prompts,
- When the user selects these modes,
- Then they are presented with gentle, state-matched options that encourage small physical steps or outdoor perspective shifts.

### Story 9.2: Music Room & Weekly Check-in Buddy (Sprint 9)

As a user needing comfort and connection,
I want to play local calming music and easily share a weekly summary with a trusted person,
So that I feel supported without compromising my offline privacy.

**Acceptance Criteria:**
- Given the `MusicRoomController` and `WeeklyCheckInController`,
- When used,
- Then local audio can be played for comfort,
- And a textual summary can be generated and passed to the system share sheet or SMS intent without Firefly needing network permissions.

---

## Epic 10: v2 Sprint 1 - Movement & Somatic Release

Implement the foundational physical regulation activities designed to discharge nervous system energy and activate positive behavioral momentum.

### Story 10.1: Movement Engine & Routine Action Trackers
As a user feeling restless or lethargic, I want simple physical and routine actions guided by a clean UI, so that I can shift my state through movement without needing high cognitive energy.
**Acceptance Criteria:**
- Create `MovementEngineScreen` supporting Active Physical (Walking, Stretching, Yoga) and Behavioral (Make bed, Drink water) tasks.
- Include a 2-minute timer for short activities, and open-ended trackers for others.
- Log effectiveness to Drift DB after completion.

### Story 10.2: Progressive Muscle Relaxation (PMR) Interactive Body Map
As a user carrying physical tension, I want a body map that guides me through tensing and releasing muscles from head to toe, so that I can physically release stored somatic tension.
**Acceptance Criteria:**
- `PmrScreen` with an interactive anatomical vector silhouette.
- 10 active body regions highlighted during Tense/Hold/Release phases.
- Synchronized haptic cues for phase transitions.

---

## Epic 11: v2 Sprint 2 - Respiration & Autonomic Regulation

Implement the core breathing engine with adaptive visualizers to directly manipulate heart rate and physiological arousal.

### Story 11.1: Multi-Technique Respiration Engine & Adaptive Bloom Painter
As a user experiencing physical anxiety or racing thoughts, I want to select from validated breathing techniques (Cyclic Sighing, Box, Resonance) with an organic bloom visualizer, so that my autonomic nervous system can down-regulate.
**Acceptance Criteria:**
- `BreathingSessionController` computes phase transitions accurately (inhale, hold, exhale).
- `BloomCustomPainter` renders 60fps smooth expansion in sage and contraction in dusk blue.
- Haptic pulses fire precisely on phase boundaries.

---

## Epic 12: v2 Sprint 3 - Grounding, Mindfulness & Nature

Implement environmental observation, somatic grounding visualizations, and meditative labyrinth tracing to shift attention away from internal rumination without cognitive load.

### Story 12.1: Guided Nature & Outdoor Micro-Observation Suite
As a user feeling overwhelmed, restless, or mentally exhausted, I want guided nature observation and environmental grounding prompts (Sky gazing, Tree canopy, Light & shadow, Outdoor grounding, Weather noticing), so that I can anchor my attention to the natural world without cognitive pressure.
**Acceptance Criteria:**
- `NatureObservationScreen` with tactile observation prompt cards (≥ 56dp touch targets).
- 5 evidence-based nature observation modes with smooth 300ms transitions and optional serene timer.
- Clean offline support, gentle haptic acknowledgments, and graceful "That's enough for now" exit with effectiveness rating.

### Story 12.2: Somatic Visualizations & Body Centering
As a user seeking deep physical calm or autonomic down-regulation, I want guided somatic visualization exercises (Heavy body gravity settling, Warm hands peripheral dilation, Mountain posture stability, Mindful pause), so that I can release physical vigilance.
**Acceptance Criteria:**
- `SomaticCenteringScreen` with paced physiological settling stages and gentle pulse animations.
- Offline audio guidance/soundscape integration and haptic transition cues.
- Full accessibility compliance, no forced completion or countdown pressure.

### Story 12.3: Meditative Labyrinth Tracing & Canvas Drawing
As a user seeking quiet, focused distraction and rhythmic soothing, I want an interactive digital finger labyrinth and continuous meditative tracing canvas, so that repetitive motor-tactile flow can settle my nervous system.
**Acceptance Criteria:**
- `LabyrinthScreen` with interactive `CustomPainter` rendering smooth geometric classical labyrinth and spiral paths.
- Real-time touch tracking with gentle glowing trail and haptic pulses on turn points.
- Zero timers, scores, or fail states; non-judgmental pause or exit anytime.

---

## Epic 13: v2 Sprint 4 - Cognitive Flow & Attention Switching

Implement puzzles and mental load tasks that consume working memory to interrupt intrusive thoughts.

### Story 13.1: Cognitive Grounding Engine
As a user experiencing racing thoughts, I want low-pressure structured working memory exercises (Categories, Backward Counting, Alphabet Association), so that my mind can break repetitive thought cycles.
**Acceptance Criteria:**
- `CognitiveGroundingScreen` with text-based cognitive prompts.
- Zero scoring, timers, or error buzzers.
- 50+ offline soothing category prompts.

### Story 13.2: Flow & Spatial Puzzles Integration
As a user seeking distraction, I want simple spatial and path-based puzzles (Sliding, Mazes, Labyrinths), to consume my working memory.
**Acceptance Criteria:**
- Simple Canvas-based puzzle UI (Labyrinth tracing, Connect the dots).
- Accessible touch targets and high-contrast, low-stimulation colors.

---

## Epic 14: v2 Sprint 5 - Expression, Processing & Reframing

Implement tools for externalizing emotions, organizing thoughts, and practicing self-compassion.

### Story 14.1: Encrypted Worry Dump & Unsent Letters
As a user needing emotional catharsis, I want a distraction-free writing canvas with instant "burn" capabilities, so that I can safely release heavy feelings.
**Acceptance Criteria:**
- `JournalEditorScreen` with offline voice dictation (Vosk).
- TTL selector badge for auto-delete horizons.
- AES-256-GCM double encryption for all entries stored in Drift.
- "Burn Now" button for immediate cryptographic zeroing.

### Story 14.2: Cognitive Defusion Prompts
As a user stuck in a thought spiral, I want guided cognitive defusion prompts (Leaves on a stream, Thought labelling), to reframe my worries.
**Acceptance Criteria:**
- Interactive prompts guiding users to label thoughts or visualize them drifting away.

---

## Epic 15: v2 Sprint 6 - Auditory, Restorative & Social Environments

Implement passive sensory regulation, sleep preparation, and co-regulation tools.

### Story 15.1: Ambient Audio Mixer & Sleep Wind-Down
As a user struggling with insomnia, I want an audio mixer with a fading sleep timer, so that I can rest better.
**Acceptance Criteria:**
- `SleepWindDownScreen` with ultra-dark `#0A0D0F` canvas.
- Audio mixer combining 2-3 offline tracks (Rain, Piano, White Noise).
- Logarithmic volume attenuation over the final 5 minutes of a 15-60 min timer.

### Story 15.2: Social Connection & Cooperative Activities
As a user experiencing isolation, I want pre-written reach-out texts and cooperative game suggestions, so that I can connect with others without the barrier of expecting awkwardness.
**Acceptance Criteria:**
- Display supportive contacts from `SafetyPlanContactsDao`.
- Offline SMS dialer integration via `url_launcher`.
- "Guess vs. Reality" tracker logging predictions and outcomes.

---




## Epic 16: Clinical Safety Guardrails & Production Verification (v2 Sprint 7)

Implement clinical safety interceptors, zero-telemetry keyword detection, full screen inventory specification, and the pre-release zero-network gate pipeline.

### Story 16.1: Deterministic Crisis Phrase Detection & Local Safety Interceptor
As a user in acute emotional distress writing in the journal or worry dump,
I want non-intrusive, zero-telemetry local detection of crisis language that surfaces my Stanley-Brown Safety Plan,
So that I receive immediate, private access to crisis resources without being monitored, shamed, or blocked from writing.

**Acceptance Criteria:**
- CrisisPhraseDetector service in lib/core/safety/ with offline, clinical keyword blocklist covering self-harm, suicidal ideation, and acute hopelessness phrases.
- Debounced (500ms) non-blocking execution on journal/worry-dump text changes.
- Soft LocalSafetyBanner overlay offering a direct 1-tap route to /safety-plan with non-judgmental wording and dismiss capability.
- Zero network, zero external logging, and zero persistent storage of detection events.
- 100% verified via standalone tests.

### Story 16.2: Screen Inventory & Feature Mapping Documentation Alignment
As a developer and designer,
I want a comprehensive canonical source-of-truth document specifying all 12 modules, routes, CTAs, and the 6-layer overlay architecture,
So that future enhancements and design audits remain 100% consistent with Firefly design tokens.

**Acceptance Criteria:**
- docs/SCREEN_INVENTORY_AND_FEATURE_MAPPING.md documenting all 12 functional modules, routes, primary CTAs, touch targets, and low-stimulation palette tokens.
- Complete documentation of the 6-Layer Z-Index & Overlay Architecture.

### Story 16.3: Pre-Release Security & Zero-Network Verification Pipeline
As a security auditor and release engineer,
I want an automated pre-release verification script checking dependencies, network kill switches, and cryptographic integrity,
So that no unauthorized networking package or telemetry can ever enter the release build.

**Acceptance Criteria:**
- scripts/security_gate.py scanning pubspec.lock and lib/ for forbidden networking packages and socket invocations.
- Verification passes with 0 violations.

---

## Epic 17: Multi-Tab Activity Architecture & Design System Harmonization (v2 Sprint 8)

Unify the 70 evidence-based practices into the canonical 6-group regulation architecture, implement the Apple-inspired Activities library screen, synchronize Serene Sanctuary design tokens, and lock the v2.2.0 production release.

### Story 17.1: Multi-Tab 6-Group Activity Catalog & Search Interface
As a user seeking to discover self-regulation practices without cognitive overwhelm,
I want a unified, tactile activity catalog categorized by the 6 core somatic groups with real-time search and energy filtering,
So that I can easily find practices matched to my current state.

**Acceptance Criteria:**
- RegulationGroup domain enum covering all 6 groups (Movement, Respiration, Grounding, Flow, Expression, Rest & Social) + All.
- ActivitiesScreen (/home/activities) with tactile horizontal pill tabs, real-time count badges, energy filter sheet, and instant search.
- Dual-tab RightNowModal with Acute Anchors (12 fast paths) and Regulation Groups (6 one-tap deep links).
- Home check-in hub integration linking to the full library.

### Story 17.2: Stitch Serene Sanctuary Design Tokens & WCAG AAA Verification
As a user with sensory sensitivities,
I want a unified, soothing visual design system adhering to Stitch Serene Sanctuary guidelines with verified contrast,
So that every screen feels cohesive, unhurried, and accessible.

**Acceptance Criteria:**
- Standardized SpacingTokens, RadiusTokens, AppTypography, and AppIcons aliases across all feature modules.
- Illuminated sage (#7DBA9B) elevated to 8.19:1 contrast against #111518 (WCAG 2.2 AAA verified).
- Canonical reusable components FireflyNavHeader and FireflyEmptyState.
- scripts/verify_design_system_and_tokens.py verifying contrast and token integrity.

### Story 17.3: Production Release v2.2.0 Verification & Distribution Lock
As a release engineer,
I want automated release verification, lint sweeping, and signed distribution packages,
So that release v2.2.0 is locked with cryptographic checksums and verified offline assets.

**Acceptance Criteria:**
- Version bumped to 2.2.0+14 in pubspec.yaml.
- Automated release build script generating dist/firefly-v2.2.0-release.apk with verified checksums.
- CHANGELOG.md and dist/RELEASE_NOTES.md fully documented and finalized.

---

## Epic 18: Single-Session Intervention (SSI) — One-Session Reset Engine (v2 Sprint 9)

Implement the evidence-backed Single-Session Intervention (SSI) One-Session Reset protocol (Schleider et al. 2025, Baumel et al. 2019) providing a self-contained 5-minute guided journey (Anchor → Regulate → Reframe → Commit → Complete) designed for acute relief in a single session.

### Story 18.1: One-Session Reset Domain Model, State Machine & Repository
As a user in distress needing immediate structured guidance,
I want a clear 5-phase state machine managing the progression from distress anchoring to somatic regulation, cognitive reframing, and micro-commitment,
So that I can move through regulation step-by-step without cognitive overload.

**Acceptance Criteria:**
- ResetPhase enum: anchor, regulate, reframe, commit, complete.
- DistressAnchor enum with non-judgmental descriptions and target somatic techniques.
- ResetSession immutable domain model with pre/post shift rating and zero cloud leakage.
- ResetRepository interface and state management controller with step navigation.

### Story 18.2: Interactive 5-Step One-Session Reset UI (ResetScreen)
As a user with depleted executive function,
I want a serene, distraction-free 5-step guided interface with large touch targets and real-time guidance,
So that I can complete a full regulation sequence in under 5 minutes without friction.

**Acceptance Criteria:**
- ResetScreen mounted at /home/reset and /reset.
- Apple-inspired calm 5-dot step indicator with unhurried transitions.
- Interactive Step 1 (Anchor selector), Step 2 (Paced autonomic regulator with live timer), Step 3 (Compassionate reframe input), Step 4 (Micro-commitment selector), Step 5 (Effectiveness rating & peaceful closing).
- Persistent SOS overlay protection on all steps.

### Story 18.3: Universal Routing, Home/Modal Integration & Standalone Verification
As a user navigating Firefly,
I want seamless access to the One-Session Reset from the home check-in hub, acute distress modal, and activity library,
So that I can launch the reset whenever acute distress overwhelms me.

**Acceptance Criteria:**
- AppRoutes and AppRouter registration (/home/reset and /reset).
- Entry cards integrated into CheckInScreen and RightNowModal.
- Activity seeded in curated_activities.json.
- test/features/reset/verify_one_session_reset_standalone.dart passing 100% in pure Dart.
- 100% compliance with security gate, lint sweep, and design tokens.

---

## Epic 19: Self-Compassion & Thought Untangler Module (v2 Sprint 10)

Implement Kristin Neff's evidence-based self-compassion framework (Neff 2003, 2023) and cognitive untangling tools providing structured relief from harsh self-criticism, shame, and emotional fusion through the 3-step Self-Compassion Break and Interactive Thought Untangler.

### Story 19.1: Self-Compassion Domain Models, State Machine & Repository
As a user experiencing harsh self-criticism or shame,
I want structured domain models and a state machine guiding me through the 3 components of self-compassion (Mindfulness, Common Humanity, Self-Kindness) and thought untangling,
So that I can relate to my difficulties with warmth rather than isolation and self-blame.

**Acceptance Criteria:**
- `SelfCompassionComponent` enum (mindfulness, commonHumanity, selfKindness).
- `CompassionExerciseType` enum (selfCompassionBreak, thoughtUntangler, lovingKindnessAffirmation).
- `UntangledThought` immutable domain model with original thought, common humanity anchor, and kind reframe.
- `CompassionSession` immutable model with pre/post distress rating, timestamp, and zero-knowledge encrypted persistence.
- `CompassionRepository` interface and in-memory/encrypted SQLite DAO implementation.

### Story 19.2: Interactive Self-Compassion Break & Thought Untangler UI (`CompassionScreen`)
As a user under emotional distress from self-judgment,
I want a serene, low-stimulation interface offering the 3-step Self-Compassion Break and Thought Untangler with soothing physical touch prompts (hand on heart) and gentle reassurance chips,
So that I can soften self-criticism in under 4 minutes without cognitive strain.

**Acceptance Criteria:**
- `CompassionScreen` mounted at `/home/compassion` and `/compassion`.
- Stitch Serene Sanctuary dark canvas `#111518`, illuminated sage `#7DBA9B`, warm amber `#D99B65`.
- 3-step Neff Self-Compassion Break with soothing rhythmic breath/touch pulse visualizer and unhurried progression.
- Interactive Thought Untangler with step-by-step externalization:
  1. What is the harsh thought?
  2. Common humanity: Millions of humans feel this exact way.
  3. What would you say to a friend you deeply love?
- Persistent SOS overlay on all steps; touch targets ≥ 56dp.

### Story 19.3: Universal Routing, Catalog Seeding & Standalone Verification
As a user exploring Firefly,
I want direct access to Self-Compassion practices from the Activity Catalog, Right Now modal, and Home Hub,
So that I can access compassionate relief whenever shame or self-criticism strikes.

**Acceptance Criteria:**
- AppRoutes (`/home/compassion`, `/compassion`) and AppRouter registration.
- Activity catalog seeding in `curated_activities.json` (`act_self_compassion_break`, `act_thought_untangler`).
- Integration cards in `RightNowModal` and `ActivitiesScreen` under Regulation Group 5 (Expression, Processing & Reframing).
- Standalone test `test/features/compassion/verify_self_compassion_standalone.dart` passing 100% in pure Dart.
- Zero network calls, 100% design system token compliance, clean lint sweep.

