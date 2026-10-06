# Changelog

All notable changes to **Firefly** are documented in this file.
The project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.5.0] - 2026-10-06

### Focus & Mental Organisation Suite — Three Priorities & Serene Focus Companion (Epic 20 / v2 Sprint 11)

#### Cognitive Load Throttling & Executive Function Restoration
- **Three Priorities Mode (`FocusScreen` at `/home/focus` & `/focus`):** Operationalized Cognitive Load Theory (*Sweller 1988, 2011*) and executive dysfunction research (*Arnsten 2009; Snyder 2013*) by capping immediate focus to at most 3 micro-intentions ("Rule of 3"). Prevents choice paralysis and shame from oversized to-do lists during mental fatigue or ADHD overwhelm.
- **Unstructured Brain Dump:** Distraction-free externalization space to offload racing tasks, anxieties, and ideas from working memory into an unjudged holding vault. Includes one-tap promotion to the 3 priorities and guilt-free parking for later.
- **Serene Focus Companion (Timer):** Non-punitive, unhurried focus intervals (5, 10, 15, 25 minutes) with smooth circular visualizer, gentle play/pause/reset, optional ambient sound accompaniment (Rain, Forest, Waves, Silence), and zero productivity guilt or streak mechanics.
- **Universal Route & Feature Integration:** Added direct anchor to `RightNowModal` ("My mind is scattered & overwhelmed"), registered `AppRoutes.focus` and `AppRoutes.modalFocus` in `AppRouter`, and seeded `act_three_priorities` and `act_serene_focus_timer` in `curated_activities.json` (75 total activities).
- **Taxonomy Alignment:** Added `ActivityCategory.focus` mapped to `RegulationGroup.flow` (Group 4).
- **Automated Verification:** Added `verify_focus_standalone.dart` passing 100% across all domain, repository, routing, and catalog checks with zero regressions.

---

## [2.4.0] - 2026-10-06

### Self-Compassion & Thought Untangler Module (Epic 19 / v2 Sprint 10)

#### Kristin Neff Self-Compassion Break & Thought Untangler Protocol
- **3-Step Neff Self-Compassion Break (`CompassionScreen` at `/home/compassion` & `/compassion`):** Operationalized Neff (2003, 2023) and Kirby et al. (2017) clinical findings that self-compassion protects against depressive rumination and shame:
  1. *Mindfulness (Acknowledge What Hurts):* Consciously labeling distress without suppression, accompanied by a pulsing soothing aura visualizer.
  2. *Common Humanity (You Are Not Alone):* Validating that imperfections and struggle are universal shared experiences, breaking the illusion of isolated failure.
  3. *Self-Kindness & Soothing Touch:* Directing physical touch (warm hand over heart/belly) and reassuring self-talk to stimulate oxytocin release.
- **Interactive Thought Untangler:** 3-step structured cognitive defusion separating objective reality from harsh internal criticism with quick tap chips and kind friend reframing.
- **State Management & Domain Architecture:** Pure Dart `SelfCompassionComponent`, `CompassionExerciseType`, `UntangledThought`, and immutable `CompassionSession` with Riverpod `CompassionNotifier` state machine.
- **Universal Route & Feature Integration:** Added direct launch anchor to `RightNowModal` ("I am being too hard on myself"), registered `AppRoutes.compassion` and `AppRoutes.modalCompassion` in `AppRouter`, and seeded `act_self_compassion_break` and `act_thought_untangler` in `curated_activities.json` (73 total activities).
- **Taxonomy Alignment:** Extended `ActivityCategory.selfCompassion` mapped to `RegulationGroup.expression` (Group 5).
- **Automated Verification:** Added `verify_self_compassion_standalone.dart` passing 100% across all domain, repository, routing, and catalog checks.

---

## [2.3.0] - 2026-10-06

### Single-Session Intervention (SSI) — One-Session Reset Engine (Epic 18 / v2 Sprint 9)

#### One-Session Reset Protocol & Guided Engine
- **5-Step SSI Journey (`ResetScreen` at `/home/reset` & `/reset`):** Operationalized Schleider et al. (2025) and Baumel et al. (2019) research principles that each visit must deliver complete standalone value in under 5 minutes without requiring multi-week retention:
  1. *Anchor (Name the Moment):* 6 evidence-based acute distress selectors (Racing Thoughts, Chest Tightness, Heavy Inertia, Sensory Overwhelm, Loneliness Dread, General Acute Tension).
  2. *Regulate (Settle the Body):* 90-second autonomic down-regulation with pulsating circular bloom visualizer, play/pause controls, and paced breathing prompts.
  3. *Reframe (Gentle Perspective):* Self-compassion prompts and quick reassurance chips to create cognitive distance from acute distress.
  4. *Commit (One Small Step):* Single-tap behavioral activation micro-action selection (< 2 minutes) restoring agency.
  5. *Complete (Sanctuary Close):* Pre/post nervous system shift rating without streak pressure or gamification.
- **Pure Dart State Machine & Models:** Implemented `ResetPhase`, `ResetDistressAnchor`, and immutable `ResetSession` with JSON serialization and Riverpod `ResetSessionNotifier`.
- **Universal Route & Feature Integration:** Added direct launch cards on `CheckInScreen` and `RightNowModal` ("I need a complete reset"), registered routes in `AppRoutes` and `AppRouter`, and seeded `act_one_session_reset` in `curated_activities.json` (71 total activities).
- **Automated Verification:** Added `verify_one_session_reset_standalone.dart` with 100% test pass rate across all 24 standalone test suites.

---

## [2.2.0] - 2026-10-06

### Multi-Tab Activity Architecture, Design System Harmonization & Production Release Lock

#### Multi-Tab Self-Regulation Activity Architecture
- **6-Group Regulation Architecture Domain Engine:** Implemented `RegulationGroup` enum directly adhering to `research data/Activity_Architecture.md` to organize all 70 evidence-based practices across 6 core somatic groups:
  1. *Movement & Somatic Release* (Active physical regulation, progressive muscle relaxation, routine micro-actions)
  2. *Respiration & Autonomic Regulation* (Cyclic sighing, box breathing, resonance, 4-7-8 deep rest)
  3. *Grounding, Mindfulness & Nature* (5-4-3-2-1 sensory grounding, present-moment body scan, outdoor micro-observation)
  4. *Cognitive Flow & Attention Switching* (Alphabet association, tactile spatial flow puzzles, classical labyrinth tracing)
  5. *Expression, Processing & Reframing* (Encrypted journaling, ACT defusion, worry dumping, creative doodling)
  6. *Auditory, Restorative & Social Environments* (Offline soundscapes, ambient audio mixer, sleep wind-down, loneliness comfort)
- **Canonical `ActivitiesScreen` (`/home/activities`):** Built a dedicated library screen featuring Apple-inspired tactile horizontal pill tabs with real-time count badges, 5-tier energy filter modal, real-time client-side search, mechanism overview banners, and interactive cards for all 70 practices.
- **Dual-Tab `RightNowModal`:** Transformed the acute distress modal into a 2-tab switch offering immediate "Acute Anchors" (12 crisis fast-paths) and "By Regulation Group" (6 grouped cards with one-tap deep links into the full library).
- **Home Check-In Hub Integration:** Embedded an "Explore All Activities" card on `CheckInScreen` for effortless discovery without cognitive overload.
- **Universal Route Aliases:** Configured route redirects in `app_router.dart` for `/home/flow`, `/home/mindfulness`, `/home/creative`, and `/activities`.

#### Apple-Inspired Design System Harmonization & Stitch Serene Sanctuary
- **Design System Token Unification:** Standardized `SpacingTokens` (aliases: `xs`, `sm`, `md`, `lg`, `xl`, `xxl`, `xxs`), `RadiusTokens` (aliases: `full`, `modalRadius`, `radiusSm`, `radiusMd`, `radiusLg`, `radiusPill`, `container`), `AppTypography` (aliases: `captionSm`, `displaySm`, `labelXs`, `headingSmall`, `titleMedium`, `bodyMedium`, `bodySmall`, `labelLarge`, `labelMedium`, `labelSmall`), and `AppIcons` (aliases: `nature`, `audio`, `shield`, `insights`, `notes`, `safetyPlan`, `history`, `restart`, `playing`), resolving over 380 undefined getter discrepancies across 18 feature modules.
- **Stitch Serene Sanctuary Color Alignment:** Elevated dark theme `accentPrimary` to Stitch's illuminated sage (`#7DBA9B`, 8.19:1 contrast against `#111518`, clearing WCAG 2.2 AAA), `accentSecondary` to dusk blue (`#5B8A99`), and `accentWarmth` to grounding amber (`#D99B65`).
- **Canonical Design System Components:**
  - `FireflyNavHeader`: Apple-inspired calm navigation header with 20dp horizontal margins, 44x44dp hit targets, clean heading typography, and gentle haptic back affordances.
  - `FireflyEmptyState`: Trauma-informed, calm empty state with illuminated circular halos, supportive validation, and gentle recovery CTAs.
- **Navigation & Routing Harmonization:** Repaired broken route mappings in `right_now_modal.dart` (restless -> `/move?mode=shakeout`, cant_focus -> `/labyrinth`, distracting -> `/flow-puzzle`).
- **Screen Refinements:**
  - `OnboardingScreen`: Upgraded to Stitch Serene Sanctuary specification with clinical scope transparency, 100% on-device encryption pillars, Low Sensory Mode toggle, and 640dp adaptive max-width container.
  - `SafetyPlanScreen`: Replaced raw unstyled spinners with sage-themed indicators; added zero-elevation header and explicit back navigation.
  - `HopeBoxScreen`: Purged local hardcoded hex literals in favor of semantic `context.colors` tokens.
  - `CyclicSighBloomVisualizer`: Synchronized procedural bloom expansion and contraction colors with illuminated sage and dusk blue.
- **Automated Verification Gates:**
  - `scripts/verify_design_system_and_tokens.py`: Passing 100% for WCAG 2.2 AAA contrast, token alias integrity, and component existence.
  - `scripts/security_gate.py`: Passing 100% with zero remote network egress and strict SQLCipher encryption invariants.

#### Static Analysis & Lint Sweep
- Removed unused private element `_triggerWarmDoubleTapHaptic` from `tiny_steps_screen.dart`.
- Converted non-const `ActionSuggestion` and `SafetyPlanContact` constructor invocations to `const` in `recommendation_engine.dart` and `safety_plan_repository_impl.dart`.

#### Release Asset & Packaging Verification
- Bumped `pubspec.yaml` to release version `2.2.0+14`.
- Updated release build automation in `scripts/build_test_release.py` generating `firefly-v2.2.0-release.apk` with SHA-256 (`f6c1f4863afffc197beff6f10fb99dba0ffc4488bde47af8073a5a52b9af603d`), verified assets, and generated `dist/RELEASE_NOTES.md`.

---

## [2.1.0] - 2026-10-06

### Clinical Safety Guardrails & Production Verification Release

#### Epic 16: Clinical Safety Guardrails & Production Verification (v2 Sprint 7)
- **Deterministic Crisis Phrase Detection:** On-device, zero-telemetry pattern matching (`CrisisPhraseDetector`) for suicidal ideation, self-harm, and acute hopelessness with conversational idiom exclusion filters.
- **Local Safety Interceptor (`LocalSafetyBanner`):** Non-intrusive, non-blocking support banner integrated into `JournalEntryScreen` and `/home/worry-dump` with direct 1-tap route to `/safety-plan`.
- **Screen Inventory Specification:** Canonical `docs/SCREEN_INVENTORY_AND_FEATURE_MAPPING.md` documenting all 12 functional modules, routes, CTAs, and the 6-layer Z-index overlay hierarchy.
- **Pre-Release Security Gate:** Automated validation pipeline (`scripts/security_gate.py` and `scripts/security_gate.sh`) enforcing zero forbidden networking packages in `pubspec.lock` and zero outbound socket calls in `lib/`.

---

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
