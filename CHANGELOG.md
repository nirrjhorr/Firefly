# Changelog

All notable changes to **Firefly** are documented in this file.
The project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-10-06

### Major Release — State-Based Regulation System & 6-Group Activity Architecture

#### Epic 10: Movement & Somatic Release (v2 Sprint 1)
- Unified Activity Domain Model and Drift schema (`curated_activities.json`, `ActivitiesDao`).
- "Right Now" immediate distress modal and routing.
- Progressive Muscle Relaxation (PMR) interactive anatomical body map.
- Movement engine routine action trackers and somatic reset flows.

#### Epic 11: Grounding, Sleep, Hope Box & Loneliness Suite (v2 Sprint 2)
- Extended sensory grounding suite and attention-switching tasks.
- Pre-bed sleep wind-down suite with circadian wake anchor and worry parking.
- Hope Box multi-media offline coping vault with photos, reasons to keep going, and voice notes.
- Loneliness comfort and "Guess vs. Reality" cognitive behavioral experiment engine.

#### Epic 12: Grounding, Mindfulness & Nature (v2 Sprint 3)
- Guided nature & outdoor micro-observation suite (sky gazing, tree canopy, light & shadow).
- Somatic visualizations & body centering (gravity settling, warm hands peripheral dilation).
- Meditative classical labyrinth tracing canvas with continuous touch feedback.

#### Epic 13: Cognitive Flow & Attention Switching (v2 Sprint 4)
- Structured working memory cognitive grounding exercises (Alphabet association, backward counting, category sorting).
- Spatial flow puzzles with non-stimulating canvas interactions.

#### Epic 14: Expression, Processing & Reframing (v2 Sprint 5)
- Encrypted worry dump and unsent letters auto-deleting vault with "Burn Now" zeroing.
- Cognitive defusion suite: Leaves on a Stream, Thought Cloud Dissolve, and 3-Tier Linguistic Defusion.

#### Epic 15: Auditory, Restorative & Social Environments (v2 Sprint 6)
- Multi-track Ambient Audio Mixer with independent volume controls and 5 restful presets.
- Weber-Fechner logarithmic volume attenuation over the final 5 minutes of a 15–60 min timer.
- Cooperative social connection activities (Parallel Quiet, Appreciation Micro-Notes, Cooperative Games, Low-Barrier Presence).
- Pre-written invitation SMS templates linked to "Guess vs. Reality" empirical outcome tracking.

---

## [1.0.0] - 2026-10-01

### Initial Production Release — 100% Offline Mental Wellbeing Companion

#### Epic 1: Core Scaffolding, Encrypted Storage & Design Foundations
- Installed `FireflyHttpOverride` network kill-switch blocking all HTTP, HTTPS, and socket traffic.
- Implemented `KeyManager` and `BiometricGuard` providing hardware-backed key derivation and biometric locks.
- Configured Drift encrypted database engine utilizing SQLCipher (AES-256-CBC, HMAC-SHA512, secure delete).
- Established low-stimulation design system tokens (Atkinson Hyperlegible, `#111518` canvas, `#4A7862` sage, `#B05454` crisis coral).

#### Epic 2: Stanley-Brown Offline Safety Plan
- Built 6-step Stanley-Brown crisis planning workflow with local encrypted persistence.
- Added offline `tel:` and `sms:` intent integration with pre-written reach-out message templates.
- Added persistent 1-tap SOS overlay button accessible across all application screens.
- Implemented panic button fast exit with immediate screen blanking and memory purging.

#### Epic 3: Affect Check-In & Deterministic Recommendation Engine
- Implemented state-matched affect check-in with 5 moon-phase mood tiles and energy slider.
- Built pure deterministic recommendation engine evaluating user states in `< 1ms` with zero cloud calls.
- Integrated `AffectResultCard` presenting contextual interventions matched to energy and distress levels.

#### Epic 4: Respiration & Grounding Engine
- Implemented cyclic sighing respiration controller (4s inhale / 8s exhale) with synchronized haptics.
- Developed `CyclicSighBloomPainter` for calming visual feedback.
- Created 5-4-3-2-1 sensory grounding exercise with tactile progression cards.
- Integrated offline audio soundscapes (cyclic sighing ambience, rain, grounding chimes).

#### Epic 5: Tiny Steps Mode (Behavioral Activation)
- Curated 20+ micro-action library filtered by current energy and mood state.
- Designed distraction-free cards with touch targets ≥ 72dp and gentle, non-gamified completion haptics.
- Added guilt-free dismiss option ("I'll do this later").

#### Epic 6: Expressive Journaling & Unsent Letters
- Implemented application-layer AES-256-GCM double encryption with HKDF subkey derivation.
- Added cryptographic memory zeroing (`_zeroMemory`) and instant cryptographic erasure.
- Developed TTL automated purge engine supporting 1-hour, 24-hour, and 7-day auto-delete presets.
- Integrated offline Vosk speech-to-text dictation on a background isolate (< 50MB RAM ceiling).
- Built distraction-free writing canvas with "Burn Now" dissolve animation.

#### Epic 7: Production Hardening, System Integration & Offline Model Packaging
- Bundled offline audio soundscapes and compressed Vosk acoustic models directly in app assets.
- Implemented `OfflineAssetManager` with non-blocking cold-start preflight (< 50ms).
- Built `LonelinessComfortScreen` and deep linking routes (`/home/loneliness`, `/home` fallback).
- Configured GoRouter `restorationScopeId` for process death state restoration.
- Implemented `PanicCryptographicService` with HMAC-SHA256 signing and latency benchmark (< 15ms vs. < 100ms SLA).
- Added golden path E2E smoke and WCAG AA accessibility compliance test suite.
