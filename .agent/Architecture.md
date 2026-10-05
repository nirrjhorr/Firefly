# Architecture.md
# Firefly — System Architecture & Technical Compass

**Version:** 2.0.0 | **Status:** Activity Architecture Integration | **Updated:** 2026-10-05

---

## 1. What We Are Building

**Firefly** is a calm, 100% offline, privacy-critical mental wellbeing companion and **state-based self-regulation system** for Flutter (iOS & Android). It meets users in their hardest moments — late-night anxiety, overwhelming stress, creeping loneliness, restlessness, racing thoughts, or difficulty sleeping — and guides them through one small, evidence-informed step at a time.

It is **not** a diagnostic tool. It **does not** replace professional care. It is a quiet companion that works without a network, never stores unencrypted data, and never judges.

**Core Promise:**
> *"Find something that helps you feel a little more settled right now."*
Deliver meaningful regulation in under 2 minutes. Work offline forever. Own your data completely.

---

## 2. Target Users

| Profile | Scenario | App Entry Point |
|---|---|---|
| Evening distress | Overwhelmed after a hard day, can't decompress | Check-in → Breathing / Grounding |
| Low-energy / flat mood | Can't start anything, stuck on the sofa | Check-in → Tiny Steps |
| Restless / can't settle | Physical tension, can't sit still | Right Now → Movement / Games |
| Racing thoughts | Mind won't stop, rumination loop | Right Now → Cognitive Reset / Audio |
| Loneliness spike | Alone, not sure if reaching out is worth it | Check-in → Loneliness Comfort |
| Can't sleep | Mind too active at night | Right Now → Sleep Wind-Down |
| Needs to express | Feeling heavy, needs to process | Check-in → Journal / Expression |
| Acute anxiety | Racing thoughts, physical tension | Check-in → Cyclic Sigh |
| Crisis precaution | Warning signs accumulating, needs a plan | Safety Plan (1-tap, persistent) |

**Scope boundary:** Mild-to-moderate distress. The Safety Plan is the escalation path for crisis — the app always surfaces it, never attempts to manage active crisis alone.

---

## 3. Feature Catalogue

### A. Affect Check-In + "Right Now" Mode
- Moon-phase mood selector (Heavy → Open, 5 states — no numeric 1-10 scale)
- Energy drag-slider ("Still" → "Moving")
- Loneliness, anxiety levels (visual, non-clinical selectors)
- **Output:** Deterministic `ActionSuggestion` from the recommendation engine → routes user to the most relevant feature
- **"Right Now" fast path:** 12-state self-selection bypassing full check-in for users in acute distress (panicked / overwhelmed / racing thoughts / restless / can't sleep / etc.)

### B. Grounding & Respiration
- **Cyclic sighing** (default): double inhale + prolonged exhale, 4s/8s — backed by Balban et al. 2023
- **Breathing Studio:** single engine for all breathing techniques (box breathing, star breathing, resonance, extended exhale, humming breathing, counted breathing, breath awareness)
- **5-4-3-2-1 senses** grounding exercise with guided prompts
- **Extended sensory grounding:** texture hunt, sound hunt, colour search, feet-on-floor, object holding, environmental scan
- **Cognitive grounding:** counting backwards, categories, alphabet association, word association (attention switching — "Try a short attention reset")
- Haptic phase-sync (light impact on inhale, single pulse on exhale)
- Ambient local audio loop (gentle rain / white noise / silence)
- `CustomPainter` bloom visualizer — smooth, no widget-tree rebuilds

### C. Tiny Steps Mode (Behavioral Activation)
- Curated ≤ 2-minute micro-action library (30+ actions: drink water, open a window, stand up, make tea, open curtains, shoulder rolls, text someone)
- Matched by energy level and affect state from check-in
- After-session effectiveness feedback: "How do you feel now?" (5-point scale) stored to personal profile
- Completion: warm double-tap haptic + gentle sage fade — no confetti

### D. Expressive Journaling & Unsent Letters
- Free-text journaling with optional voice-to-text (Vosk offline STT)
- "Unsent letters" mode: write without sending — cathartic, private
- Per-entry TTL auto-delete toggle (cryptographic erasure on expiry)
- Pennebaker protocol guidance: 15–20 min prompts across 3–4 days (optional)

### E. Offline Safety Plan (Stanley-Brown Protocol)
- Six-step template: warning signs → internal coping → distraction contacts → support contacts → professional contacts → environment safety
- One-tap emergency access from **any screen** (persistent SOS overlay)
- Pre-written reach-out text templates
- Offline emergency dialer (native `tel:` intent — no internet needed)
- All data encrypted on-device; no cloud sync

### F. Loneliness Comfort & Hope Box
- **Loneliness Comfort:** Gentle ambient sound, "Someone's here" breathing visual
- **Guess vs. Reality:** Log expected outcome before reaching out; record what happened after
- **Hope Box:** Private offline vault — user photos, voice notes, favourite songs, written reasons to keep going
- Pre-written friction-reducing text prompts; one-tap launch of native SMS

### G. Progressive Muscle Relaxation (NEW)
- Interactive human body silhouette highlighting 10 regions: Forehead → Jaw → Neck → Shoulders → Hands → Chest → Abdomen → Legs → Feet
- Guided sequence: **Tense → Hold (5s) → Release → Notice → Move on**
- Audio-guided option; haptic on each phase transition
- Fully offline, no equipment required

### H. Sleep Wind-Down (NEW)
- Entry point: "I cannot switch my brain off"
- Duration options: 5 min / 10 min / 20 min / 30 min sleep mode
- Activities: body scan, slow breathing, progressive relaxation, sleep story, rain sounds, worry parking, gratitude reflection, tomorrow planning
- Gentle dCBT-I approach (Lin et al. 2023) — no sleep restriction protocol in v1.x

### I. Nature Mode (NEW)
- Indoor nature simulation for users who cannot easily go outside
- Audio: rain, ocean, forest, birdsong, fireplace
- Visual: ambient nature scenes (animated or static), watch clouds / fire / water
- Nature walk guidance prompts for outdoor use

### J. Audio Room & Sound Mixer (NEW)
- Intent-based routing: Relax / Sleep / Focus / Ground / Anxiety / Low mood / Nature / Meditation / Background
- Multi-source sound mixer (e.g., Rain 60% + Piano 30% + Fireplace 20%) with independent volume controls
- Controls: Timer / Volume / Fade in / Fade out / Loop / Mix / Save favourite / Playlists

### K. Flow Games & Cognitive Interruption (NEW)
- **Cognitive Reset** (2–5 min): short absorbing activities
- **Deep Flow**: longer sessions for extended attention shift
- Game types by mechanism: Spatial (Tetris-style, tangram) / Pattern (matching, Sudoku) / Visual (colour ordering) / Sequential (mazes, path tracing) / Memory (matching pairs) / Logic (nonograms)
- Cognitive grounding mini-games (counting, categories, word association)

### L. Labyrinth & Path Activities (NEW)
- Finger labyrinth (trace a meditative path)
- Digital path-following and spiral tracing
- One-line puzzles and connect-the-dots (sequential visual attention)
- Design principle: path-following ("Can I stay with the path?") not maze-solving ("Which way should I go?")

### M. Extended Mindfulness (NEW)
- Body scan (full systematic body awareness)
- Open awareness (observe thoughts without following)
- Loving kindness meditation
- Walking mindfulness, sound meditation
- Mindful pause (brief interruption of automatic behaviour)

### N. Creative Regulation (NEW)
- Guided drawing and colouring instructions
- Origami step-by-step
- Creative writing prompts, poetry starters
- Photography challenge (external attention)

### O. Cognitive Defusion & Thought Management (NEW)
- Thought cloud visualisation (observe thoughts passing)
- Leaves on stream, worry container
- Problem vs. worry separator (actionable vs. hypothetical)
- "I am having the thought that..." distancing language

### P. Problem Solving Flow (NEW)
- Structured 6-step guided flow: identify → can I influence? → what can I control? → possible solutions → one action → when?
- Distinguishes "I need to calm down" from "I need to figure something out"

### Q. Personal Regulation Profiles (NEW)
- After-session effectiveness feedback (5-point scale: Much worse → Much better)
- Personal profile: sessions per feature + average effectiveness
- Future: personalised suggestions ("Last time you felt this way, X helped")

---

## 4. App Flow, State Transitions, & Navigation

```mermaid
flowchart TD
    A([App Launch]) --> B{Privacy Lock\nBiometric / PIN}
    B -->|Authenticated| C[Home Screen]
    B -->|Failed / No Passcode| D[Warn + Refuse DB Open]

    C --> E[Check-In Screen\nMood · Energy · Anxiety · Loneliness]
    C --> SOS([🛡️ Safety Plan — 1-tap\nPersistent Overlay])

    E --> F{Recommendation\nEngine}

    F -->|anxietyLevel ≥ 4| G[Breathing & Grounding\nCyclic Sigh]
    F -->|mood=low + energyLevel ≤ 2| H[Tiny-Steps Mode\nBehavioural Activation]
    F -->|lonelinessLevel ≥ 4| I[Loneliness Comfort\nGuess vs Reality]
    F -->|mood=overwhelmed| J[5-4-3-2-1\nGrounding]
    F -->|moderate distress| K[Expressive Journaling\nUnsent Letters]
    F -->|calm / positive| L[Hope Box\nor Tiny Step]

    G --> M[Session Complete\nGentle Progress Note]
    H --> M
    I --> M
    J --> M
    K --> M
    L --> M

    M --> C

    SOS --> N[Safety Plan Screen\nFull-screen modal over any route]
    N --> O{Step Needed?}
    O -->|Internal coping| G
    O -->|Contact support| P[Pre-written SMS / tel: intent]
    O -->|Emergency| Q[Emergency Number — offline dialer]
```

**Navigation Architecture:**
- **Router:** `go_router` with Shell Routes.
- **Guards:** Privacy lock (biometric/PIN) and Onboarding guards intercept state transitions to redirect users to appropriate screens before they access any protected route.
- **Persistent Safety Plan Access:** The SOS button is a floating overlay rendered above the `NavigationShell` via `Stack` — it exists on every screen, including during active breathing sessions. It opens an instant full-screen modal over any route. Long-press activates the Panic Exit sequence.

---

## 5. Technology Stack

| Layer | Package / Tool | Version Pin | Rationale |
|---|---|---|---|
| Framework | Flutter + Dart 3.x | SDK ≥ 3.3.0 | Cross-platform, single codebase |
| State Management | `flutter_riverpod` + `riverpod_annotation` | ^2.5.x | Compile-safe, `AsyncNotifier`, guaranteed `onDispose` teardown |
| Code Generation | `build_runner` + `riverpod_generator` | ^2.4.x | Type-safe provider generation |
| Local Database | `drift` | ^2.18.x | Type-safe SQLite ORM, reactive streams, versioned migrations |
| Encryption | `sqlcipher_flutter_libs` | ^0.3.x | AES-256-CBC transparent SQLite encryption |
| Secure Key Storage | `flutter_secure_storage` | ^9.2.x | iOS Keychain / Android Keystore TEE |
| Biometric Auth | `local_auth` | ^2.3.x | Face ID, Touch ID, device passcode |
| Navigation | `go_router` | ^14.x | Declarative routes, shell routes, biometric guards |
| Audio | `just_audio` | ^0.9.x | Gapless local asset looping, cross-platform |
| Audio Session | `audio_session` | ^0.1.x | iOS/Android audio focus management |
| Haptics | Flutter `HapticFeedback` | SDK | Native haptic patterns, no package needed |
| Offline STT | `vosk_flutter` | ^0.3.x | 100% on-device speech recognition (no cloud) |
| File Picker | `file_picker` | ^8.x | User-initiated backup export/import |
| Path Provider | `path_provider` | ^2.1.x | App-private directory resolution |
| URL Launcher | `url_launcher` | ^6.3.x | Native `tel:` and `sms:` intents offline |
| Cryptography | `cryptography` | ^2.7.x | AES-GCM + Argon2id for backup engine |
| Linting | `flutter_lints` + `custom_lint` | ^4.x | Strict static analysis |

**Key Architectural Decisions:**
- **Riverpod over BLoC:** Chosen for its compile-time safety (via code generation), native `AsyncNotifier` handling DB streams, and `ref.onDispose` contract which guarantees resource cleanup (audio, timers, haptics) when a user navigates away mid-session.
- **Drift + SQLCipher over Isar/Hive:** Drift provides robust ACID compliance (via SQLite WAL mode), transparent AES-256-CBC encryption via SQLCipher, and full relational integrity (foreign keys) necessary for the hierarchical Safety Plan data.
- **Deterministic Rule Engine over Local LLM:** A rule-based engine offers sub-millisecond response times, zero impact on app size, and 100% predictable, safe outputs (non-negotiable for a crisis-adjacent app).

**Packages explicitly BANNED:** `http`, `dio`, `firebase_*`, `sentry_*`, `amplitude_*`, `mixpanel_*`, `google_sign_in`, any package making outbound network connections.

---

## 6. Folder & File Structure

```
lib/
│
├── main.dart                          # ProviderScope, HttpOverride kill switch, font init
│
├── core/
│   ├── database/
│   │   ├── app_database.dart          # Drift root + SQLCipher PRAGMA bootstrap
│   │   ├── app_database.g.dart        # Generated
│   │   ├── migrations/
│   │   │   └── migration_runner.dart  # Versioned migration logic
│   │   └── tables/
│   │       ├── mood_check_ins.dart
│   │       ├── journal_entries.dart
│   │       ├── safety_plan_tables.dart
│   │       ├── audio_preferences.dart
│   │       ├── app_configuration.dart
│   │       ├── usage_summaries.dart
│   │       └── effectiveness_ratings.dart  # NEW: per-session effectiveness scores
│   │
│   ├── security/
│   │   ├── key_manager.dart
│   │   ├── biometric_guard.dart
│   │   ├── journal_crypto_service.dart
│   │   ├── cryptographic_eraser.dart
│   │   └── network_kill_switch.dart
│   │
│   ├── routing/
│   │   ├── app_router.dart
│   │   ├── app_routes.dart
│   │   └── route_guards.dart
│   │
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   ├── animation_tokens.dart
│   │   └── spacing_tokens.dart
│   │
│   ├── contracts/
│   │   ├── audio_player_port.dart
│   │   ├── haptics_port.dart
│   │   └── voice_recognition_port.dart
│   │
│   ├── errors/
│   │   ├── app_exception.dart
│   │   ├── failure.dart
│   │   └── result.dart
│   │
│   ├── recommendation_engine/
│   │   ├── recommendation_engine.dart  # Extended: maps to 21-category activity system
│   │   ├── affect_state.dart           # Extended: includes reportedState enum
│   │   ├── action_suggestion.dart
│   │   └── right_now_router.dart       # NEW: 12-state immediate distress routing
│   │
│   ├── activity_system/               # NEW: unified activity catalogue architecture
│   │   ├── activity_model.dart        # Shared activity data model
│   │   ├── activity_catalogue.dart    # Dart constants for all curated activities
│   │   └── activity_filter.dart       # Dynamic filtering by state/energy/duration
│   │
│   └── utils/
│       ├── dart_extensions.dart
│       └── local_date_utils.dart
│
├── shared/
│   └── widgets/
│       ├── firefly_button.dart
│       ├── firefly_card.dart
│       ├── sos_overlay_button.dart
│       ├── panic_button.dart
│       ├── breathing_bloom_painter.dart
│       ├── mood_tile.dart
│       ├── energy_slider.dart
│       ├── gentle_progress_bar.dart
│       ├── effectiveness_prompt.dart   # NEW: "How do you feel now?" post-session widget
│       ├── body_silhouette_painter.dart # NEW: PMR body map CustomPainter
│       └── right_now_selector.dart     # NEW: 12-state immediate selection grid
│
└── features/
    ├── onboarding/
    │
    ├── check_in/
    │
    ├── right_now/                      # NEW
    │   ├── domain/right_now_state.dart
    │   └── presentation/
    │       ├── screens/right_now_screen.dart
    │       └── controllers/right_now_controller.dart
    │
    ├── breathing_grounding/            # EXTENDED
    │   ├── domain/
    │   │   ├── breathing_session.dart
    │   │   └── grounding_exercise.dart
    │   └── presentation/
    │       ├── screens/
    │       │   ├── breathing_studio_screen.dart  # NEW: multi-technique engine
    │       │   ├── breathing_grounding_screen.dart
    │       │   └── extended_grounding_screen.dart # NEW: texture/sound/colour hunts
    │       ├── controllers/
    │       │   ├── breathing_session_controller.dart
    │       │   └── grounding_controller.dart
    │       └── widgets/
    │           ├── cyclic_sigh_bloom.dart
    │           └── grounding_prompt_card.dart
    │
    ├── cognitive_grounding/            # NEW
    │   └── presentation/
    │       ├── screens/cognitive_grounding_screen.dart
    │       └── controllers/cognitive_grounding_controller.dart
    │
    ├── tiny_steps/                     # EXTENDED
    │   ├── data/
    │   ├── domain/tiny_step.dart
    │   └── presentation/
    │       ├── screens/tiny_steps_screen.dart
    │       └── controllers/tiny_steps_controller.dart
    │
    ├── pmr/                            # NEW: Progressive Muscle Relaxation
    │   └── presentation/
    │       ├── screens/pmr_screen.dart
    │       └── controllers/pmr_controller.dart
    │
    ├── sleep/                          # NEW: Sleep Wind-Down
    │   ├── data/
    │   ├── domain/sleep_session.dart
    │   └── presentation/
    │       ├── screens/sleep_winddown_screen.dart
    │       └── controllers/sleep_controller.dart
    │
    ├── nature/                         # NEW: Nature Mode
    │   └── presentation/
    │       ├── screens/nature_mode_screen.dart
    │       └── controllers/nature_controller.dart
    │
    ├── audio_room/                     # NEW: Audio Room + Sound Mixer
    │   ├── data/
    │   ├── domain/audio_track.dart
    │   └── presentation/
    │       ├── screens/audio_room_screen.dart
    │       ├── screens/sound_mixer_screen.dart
    │       └── controllers/audio_room_controller.dart
    │
    ├── flow_games/                     # NEW: Flow & Cognitive Interruption Games
    │   ├── domain/game_catalogue.dart
    │   └── presentation/
    │       ├── screens/game_hub_screen.dart
    │       └── games/
    │           ├── spatial_game_screen.dart
    │           ├── pattern_game_screen.dart
    │           └── labyrinth_screen.dart
    │
    ├── mindfulness/                    # NEW: Extended Mindfulness
    │   └── presentation/
    │       ├── screens/mindfulness_hub_screen.dart
    │       ├── screens/body_scan_screen.dart
    │       └── screens/loving_kindness_screen.dart
    │
    ├── creative/                       # NEW: Creative Regulation
    │   └── presentation/
    │       └── screens/creative_hub_screen.dart
    │
    ├── thought_tools/                  # NEW: Cognitive Defusion + Problem Solving
    │   └── presentation/
    │       ├── screens/cognitive_defusion_screen.dart
    │       └── screens/problem_solving_screen.dart
    │
    ├── journaling/
    │
    ├── safety_plan/
    │
    ├── loneliness_comfort/
    │
    ├── hope_box/
    │
    ├── personal_profile/               # NEW: Personal Regulation Profiles
    │   ├── domain/effectiveness_entry.dart
    │   └── presentation/
    │       └── screens/personal_profile_screen.dart
    │
    └── gentle_progress/
```

---

## 7. Data Flow & Integration Contracts

```
User Input (UI Widget)
        │
        ▼
Feature Controller (Riverpod AsyncNotifier)
        │
        ├──► Hardware Ports (AudioPlayerPort, HapticsPort, VoiceRecognitionPort)
        │
        ▼
Repository Interface (Domain boundary — abstract)
        │
        ▼
Repository Impl ──► DTO Mapper ──► Drift DAO
                                        │
                                        ▼
                              SQLCipher-Encrypted .db File
                              (Key sealed in iOS Keychain /
                               Android StrongBox TEE)
```

**Integration Contracts:** All presentation controllers interact with hardware and data exclusively through **abstract interface ports**. This enforces testability (via mocks), decouples features from infrastructure, and prevents direct dependency on platform channels.

**Invariant:** No Widget ever touches a DAO. No Controller imports `drift` directly. The Repository is the only boundary-crosser.

---

## 8. Security Summary

| Concern | Mechanism |
|---|---|
| Data at rest | SQLCipher AES-256-CBC + journal AES-GCM double encryption |
| Key storage | `flutter_secure_storage` → iOS Keychain / Android Keystore |
| App unlock | `local_auth` biometric gate before DEK retrieval |
| Network prevention | `HttpOverrides.global` kill switch + Android NSC + iOS ATS |
| OS screenshot | `FLAG_SECURE` (Android) + blur overlay on `willResignActive` (iOS) |
| Backup | AES-256-GCM + Argon2id passphrase derivation |
| Expired journals | Cryptographic key rotation → permanent unreadability + VACUUM |
| Cloud sync block | `synchronizable: false` on all Keychain items |

---

## 9. State Management & UI Performance
- **State Lifecycle Categories:**
  - **Transient:** Active timers, tap states (`@riverpod` auto-disposed).
  - **Session:** In-progress answers, draft journals (`@Riverpod(keepAlive: false)`).
  - **Persistent:** Completed journals, saved plans (`@Riverpod(keepAlive: true)` backed by Drift stream).
- **UI Render Strategy:**
  - **Shader-free:** Visualizations are shader-free unless Impeller is fully supported.
  - **CustomPainter:** Breathing blooms and pacing gauges (e.g., `CyclicSighBloomPainter`) are drawn using `CustomPainter` to avoid widget tree overhead and maintain smooth 60fps. Repaints are restricted natively via `shouldRepaint`.
  - **Jank Prevention Rules:** DB reads on the UI thread are strictly asynchronous. `setState` is avoided for high-frequency animations (like breathing ticks) — `ref.listen` is used to isolated updates.

---

## 10. Database Schema & Local Data Access
- **Embedded Engine:** Drift + SQLCipher provides complete crash safety via SQLite WAL mode and safe data migration logic (versioned additive schema shifts).
- **Entity-Relationship Models:** Essential features like the Safety Plan heavily rely on cascaded foreign keys (e.g. `SAFETY_PLANS` linking `SAFETY_PLAN_CONTACTS` and `SAFETY_PLAN_STEPS`) to maintain strict relational integrity offline.
- **Lazy-Loading Polices:** Journal entries only retrieve metadata previews initially to save memory. Full text and voice transcriptions load exclusively on demand when the entry is opened.
- **Offline Analytics:** Analytics data (usage length, feature access) are securely written to `USAGE_SUMMARIES` table upon session end. This data powers internal gentle progress charts securely.

---

## 11. On-Device Recommendation Engine
- **Engine Selection:** Instead of LLMs, Firefly implements a **Deterministic State Machine** via `RecommendationEngine.evaluate(AffectState)`.
- **Determinism Flow:** User inputs `AffectState` via Check-In OR self-selects via "Right Now" (12-state) → Rule Engine prioritizes safety rules → Outputs 100% predictable, deterministic `ActionSuggestion` route.
- **Rules Priority:** Immediate physiological regulation overrides cognitive tasks. High anxiety → cyclic sigh. Racing thoughts → cognitive reset. Restless → movement. Can't sleep → sleep mode. Low energy → tiny steps.
- **"Right Now" Router:** A separate pure `RightNowRouter.route(RightNowState)` maps 12 self-selected states to activity routes without requiring full affect data. Routes include: `/breathe`, `/ground`, `/ground?mode=cognitive`, `/move`, `/sleep`, `/journal/new`, `/audio`, `/games`, `/loneliness`.
- **Activity System:** The `ActivityCatalogue` in `core/activity_system/` provides a queryable library of all curated activities with fields for `targetStates`, `energyRequired`, `duration`, and `guidanceType`. Used by feature controllers to select contextually appropriate activities.

---

## 12. Hardware, Media & Notifications Subsystems
- **Audio Delivery:** Through `just_audio`, local ambient sounds employ gapless looping via `LoopingAudioSource`. Audio uniformly fades over 300ms to avoid jolts or triggers for the user.
- **Haptic Synchronization:** Haptic feedback patterns are synchronously triggered with audio phase changes via shared logic loops to guarantee < 16ms synchronization lag.
- **Privacy-First Reminders:** `flutter_local_notifications` powered reminders avoid all sensitive data, are thoroughly opt-in, use native local device alarms (no background service), and focus on a compassionate, generic tone.
