# Epic 11 Context: v2 Grounding, Sleep, Hope Box & Loneliness Suite (v2 Sprint 2)

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Deliver the critical next tier of evidence-based self-regulation and coping resources for Firefly v2. This epic expands the core sensory grounding system beyond 5-4-3-2-1 into tactile grounding, introduces non-clinical cognitive working memory interruption tasks to break depressive/anxious rumination, establishes a dark bedtime transition sanctuary with a pre-bed worry dump and fading sleep timer, provides an app-private encrypted multi-media Hope Box, and upgrades loneliness comfort with structured reaching-out prompts and behavioral expectation tracking.

## Stories

- Story 11.1: Extended Sensory Grounding Suite (FR-13)
- Story 11.2: Cognitive Grounding & Attention Switching Engine (FR-14)
- Story 11.3: Pre-Bed Sleep & Wind-Down Suite (FR-15 / RM-03)
- Story 11.4: Hope Box Offline Multi-Media Coping Vault (FR-07)
- Story 11.5: Loneliness Comfort & "Guess vs. Reality" Experiment (FR-06 / RM-02)
- Story 11.6: Universal Navigation, SOS Panic & Seeding Alignment

## Requirements & Constraints

- **Offline-First Zero Network Policy**: All features, media assets, prompt lists, categories, and models must operate with zero network connection. Any socket or HTTP call must trigger an immediate assertion error caught by `FireflyHttpOverride`.
- **Low-Stimulation Design System**: All screens use dark background tokens (`#111518`, with `#0A0D0F` for Sleep Suite), calm typography tokens, touch targets ≥ 56dp, and WCAG AA contrast (≥ 4.5:1).
- **Anti-Gamification & Anti-Guilt**: No scores, no countdown timers, no failure states, no streaks, no buzzers. Every exercise is user-paced with an easy, non-judgmental exit button ("That's enough for now" / "Not today").
- **Privacy & Encryption at Rest**: All persistent structured data stored in Drift encrypted with SQLCipher AES-256. Media files in Hope Box must reside exclusively in app-private storage (`getApplicationDocumentsDirectory()`) and be excluded from OS backups. Deleting items must execute file deletion, DB deletion, and `VACUUM`.
- **Emergency Panic Button Protection**: The persistent SOS shield must remain visible and accessible on all screens, executing a `< 100ms` screen blanking and memory key wipe upon long press (≥ 600ms).

## Technical Decisions

- **State Management**: Riverpod 2.x `AsyncNotifier` and `StateNotifier` controllers managing immutable state models with clean lifecycle disposal on screen exit (`ref.onDispose`).
- **Activity Framework Integration**: Extended sensory and cognitive grounding activities plug directly into the unified `ActivityItem` schema, catalog, and `ActivityEffectivenessLogs` table, prompting post-session effectiveness ratings without storing freeform user text.
- **Audio & Haptics**: Gapless offline ambient playback using `just_audio` with logarithmic volume attenuation curves for sleep timers. Haptics triggered on phase/step transitions via `HapticFeedback.lightImpact()` / `mediumImpact()`.
- **SMS & Phone Intents**: Offline reaching-out actions in Loneliness Comfort launch system `sms:<phone>?body=<encoded_text>` intents via `url_launcher`.

## UX & Interaction Patterns

- **Sensory & Cognitive Cards**: Tactile prompt card sequences with horizontal easing transitions (300ms) and step tick feedback.
- **Worry Dump Modes**: Dual disposition path — "Park until morning" (locks note until 8:00 AM) or "Let it dissolve" (immediate cryptographic memory/disk erasure with calming ambient dissolve animation).
- **Behavioral Experiments (Guess vs. Reality)**: Two-stage prompt (prediction warmth before sending → outcome confirmation on subsequent app open) generating aggregate insights on Gentle Progress screen.

## Cross-Story Dependencies

- Story 11.1 extends the existing `breathing_grounding` module.
- Story 11.4 establishes the new `hope_box` data layer and presentation UI.
- Story 11.5 depends on `SafetyPlanContactsDao` from Epic 2.
- Story 11.6 consolidates all routes in `AppRouter` and links them into Home Screen and Right Now distress fast paths.
