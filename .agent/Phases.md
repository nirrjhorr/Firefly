# Phases.md
# Firefly — Incremental Development Roadmap

**Version:** 1.1.0 | **Status:** Living Document | **Updated:** 2026-09-30

> Each phase is a self-contained, verifiable unit. A phase is only complete when every checklist item is ticked. Phases build on each other — never start a phase until the prior one is verified.

---

## Phase Status Legend

| Symbol | Meaning |
|---|---|
| ⬜ | Not started |
| 🔄 | In progress |
| ✅ | Complete & verified |
| 🚫 | Blocked (see Memory.md) |

---

## Phase 0 — Workspace Scaffolding

**Goal:** Clean, linted, dependency-locked Flutter workspace ready for feature development.

### Checklist

- ⬜ `flutter create firefly --org app.firefly --platforms ios,android` — package name `app.firefly`
- ⬜ Delete default counter app code; replace `main.dart` with minimal `ProviderScope` shell
- ⬜ Install all approved packages in `pubspec.yaml` (see `Rules.md §1`)
- ⬜ Add `analysis_options.yaml` with strict lints:
  ```yaml
  include: package:flutter_lints/flutter.yaml
  analyzer:
    errors:
      missing_required_param: error
      unused_import: error
      dead_code: error
    strong-mode:
      implicit-casts: false
      implicit-dynamic: false
  linter:
    rules:
      avoid_print: true
      prefer_const_constructors: true
      always_declare_return_types: true
  ```
- ⬜ Create `.agent/` directory with all 5 compass documents
- ⬜ Create `research data/` directory; confirm all research docs present
- ⬜ Create `assets/` directory structure:
  ```
  assets/
  ├── fonts/           # AtkinsonHyperlegible, PlusJakartaSans, JetBrainsMono
  ├── audio/           # cyclic_sigh_ambience.mp3, gentle_rain.mp3, grounding_chime.mp3
  └── images/          # Placeholder app icon
  ```
- ⬜ Register fonts and assets in `pubspec.yaml`
- ⬜ Create `.semgrep/firefly_security.yaml` with security rules
- ⬜ Create `scripts/security_gate.sh` deny-list CI script
- ⬜ Set `Android: android:allowBackup="false"`, `android:usesCleartextTraffic="false"`
- ⬜ Set `Android: network_security_config.xml` blocking all outbound connections
- ⬜ Set `iOS: NSAppTransportSecurity` blocking all outbound connections
- ⬜ Create `core/errors/result.dart` — sealed `Result<T, E>` type
- ⬜ First `git commit`: "feat: Phase 0 — workspace scaffolding and security baseline"
- ⬜ Confirm `flutter analyze` returns zero warnings on clean workspace

**Exit Criteria:** `flutter run` shows a blank `Scaffold` with `ProviderScope`. Zero lint warnings. Zero network capability.

---

## Phase 1 — Security Engine & Encrypted Database

**Goal:** The on-device encrypted data store is operational. No data is ever written without encryption.

### Checklist

- ⬜ Implement `core/security/key_manager.dart`:
  - First-launch: generate 256-bit random key via `SecureRandom`
  - Store key in `flutter_secure_storage` with `synchronizable: false`
  - Retrieve key from Keychain/Keystore on subsequent launches
- ⬜ Implement `core/security/biometric_guard.dart`:
  - `authenticateAndGetDatabaseKey()` — biometric/passcode gate before DEK retrieval
  - `lockApp()` — drops in-memory key reference
- ⬜ Implement `core/security/network_kill_switch.dart` — `FireflyHttpOverride`
- ⬜ Install `HttpOverrides.global = FireflyHttpOverride()` as first line in `main()`
- ⬜ Design all Drift table schemas:
  - `MoodCheckIns`, `JournalEntries`, `SafetyPlans`, `SafetyPlanContacts`, `SafetyPlanWarnings`, `SafetyPlanSteps`, `AudioPreferences`, `AppConfiguration`, `UsageSummaries`
- ⬜ Configure `app_database.dart`:
  - `beforeOpen`: apply SQLCipher PRAGMAs (key, WAL mode, foreign keys, secure_delete ON)
  - Schema version: 1
  - `MigrationStrategy` with `onCreate` and `onUpgrade` stubs
- ⬜ Run `build_runner` — confirm `.g.dart` files generated without errors
- ⬜ Implement `openEncryptedDatabase()` factory using key from `KeyManager`
- ⬜ Implement biometric lock screen (`features/onboarding/`):
  - Shows on cold launch and on resume from background
  - Refuses DB open if device has no passcode set (warn user)
- ⬜ Implement privacy lock guard in `go_router` `redirect`
- ⬜ Set `FLAG_SECURE` in `MainActivity.onCreate()` (Android)
- ⬜ Implement iOS blur overlay in `AppDelegate` (`willResignActive` / `didBecomeActive`)
- ⬜ Implement `core/security/journal_crypto_service.dart` — HKDF subkey + AES-GCM
- ⬜ Implement `core/security/cryptographic_eraser.dart`
- ⬜ Write unit tests:
  - `KeyManager` key generation idempotency
  - `BiometricGuard` mock authentication flow
  - SQLCipher opens and rejects wrong key
  - `NetworkKillSwitch` throws on any HTTP attempt
- ⬜ `git commit`: "feat: Phase 1 — security engine, SQLCipher DB, biometric lock"

**Exit Criteria:** App launches → biometric prompt → correct key → DB opens. App with wrong key shows error. All security unit tests pass.

---

## Phase 2 — Design System Foundations

**Goal:** The visual and interaction language of Firefly exists as reusable code. All subsequent UI is built on these foundations.

### Checklist

- ⬜ Implement `core/theme/app_colors.dart`:
  - `_Primitive` palette (private) — all hex constants
  - `AppCustomColors` — `ThemeExtension<AppCustomColors>` with `lerp`, `copyWith`
  - `AppCustomColors.dark` and `AppCustomColors.light` named instances
  - `extension AppColorsX on BuildContext` convenience accessor
- ⬜ Implement `core/theme/app_typography.dart`:
  - All type styles: `displayXl`, `displayLg`, `displayMd`, `headingLg`, `headingMd`, `bodyLg`, `bodyMd`, `bodySm`, `labelLg`, `labelMd`, `caption`, `monoSm`
  - `AppTypography.toTextTheme(Color)` mapping
- ⬜ Implement `core/theme/animation_tokens.dart` — `MotionTokens` with `resolve()` for `disableAnimations`
- ⬜ Implement `core/theme/spacing_tokens.dart` — `space2xs` through `space4xl`
- ⬜ Implement `core/theme/app_theme.dart`:
  - `AppTheme.darkTheme` and `AppTheme.lightTheme` — complete `ThemeData` with Material 3
  - No splash/highlight colors (calm press behavior)
  - `NavigationBarTheme`, `CardTheme`, `ElevatedButtonTheme`, `InputDecorationTheme`, `BottomSheetTheme`
- ⬜ Implement `shared/widgets/firefly_button.dart`:
  - Primary (56dp, sage fill, scale+fade press)
  - Secondary (outlined, 52dp)
  - Scale animation: 0.97 × 120ms `easeOut`
- ⬜ Implement `shared/widgets/firefly_card.dart` — elevated surface, 16dp radius, 1dp border
- ⬜ Implement `shared/widgets/mood_tile.dart` — moon-phase icon tiles, 72×72dp, selected glow
- ⬜ Implement `shared/widgets/energy_slider.dart` — "Still → Moving" with haptic midpoint tick
- ⬜ Implement `shared/widgets/breathing_bloom_painter.dart` — `CustomPainter` bloom
- ⬜ Implement `shared/widgets/sos_overlay_button.dart` — persistent 1-tap Safety Plan trigger
- ⬜ Implement `shared/widgets/gentle_progress_bar.dart` — non-gamified, no streak counter
- ⬜ Configure `MaterialApp.router` with both themes and `ThemeMode.system`
- ⬜ Golden tests for: `FireflyButton`, `MoodTile`, `FireflyCard` (dark + light)
- ⬜ `git commit`: "feat: Phase 2 — design system, color tokens, typography, base widgets"

**Exit Criteria:** Dedicated design system screen shows all components rendering correctly in dark and light mode. Zero overflow warnings. Correct font rendering verified on device.

---

## Phase 3 — Safety Plan (Priority: Ship First)

**Goal:** The Stanley-Brown Safety Plan is fully functional before any other feature. Non-negotiable safety infrastructure.

### Checklist

- ✅ Implement `SafetyPlan` domain model + `SafetyPlanRepository` interface
- ✅ Implement `SafetyPlanRepositoryImpl` with full CRUD via Drift DAOs
- ✅ Implement `SafetyPlanController` (`AsyncNotifier` / `StateNotifier`) — load, save, update steps
- ✅ Implement `safety_plan_screen.dart`:
  - Six Stanley-Brown steps displayed in accordion cards
  - Each step: editable text field + reorder handle
  - Emergency contacts: name, phone, relationship, professional flag
  - Pre-written reach-out text templates (tap to copy/edit)
- ✅ Implement `safety_plan_editor_screen.dart` — full edit flow for all six steps
- ✅ Implement SOS overlay integration:
  - `SosOverlayButton` navigates to Safety Plan via `context.push(AppRoutes.safetyPlan)`
  - Overlay is rendered in `MainShellScaffold` above all content
  - Custom fade-in `PageTransitionBuilder` (300ms)
- ✅ Implement offline dialer: `url_launcher` with `tel:` URI for each contact
- ✅ Implement offline SMS: `url_launcher` with `sms:` URI + pre-written body
- ✅ Emergency lines section: editable list of crisis numbers (pre-populated with local defaults that user can change)
- ✅ Panic button: long-press SOS for 600ms → panic sequence (screen blank + state purge)
  - `PanicButton` widget implementation
  - `PanicBlankScreen` — pure black, no content
  - Fast purge of sensitive providers & biometric lock
- ✅ Safety plan reminder: gentle in-app prompt to review plan (not push notification)
- ✅ Unit tests: Safety plan CRUD, contact ordering, step update
- ✅ Integration test: Navigate to safety plan from Home, edit a step, verify persistence
- ✅ `git commit`: "feat: Phase 3 — Stanley-Brown safety plan, SOS overlay, panic exit"

**Exit Criteria:** Safety plan accessible from any screen in < 1 tap. All fields persist through app restart. Dialer and SMS intents launch correctly offline. Panic button blanks screen and drops state within 100ms.

---

## Phase 4 — Affect Check-In & Recommendation Engine

**Goal:** The check-in is the app's nervous system — it routes users to the right intervention based on their state.

### Checklist

- ✅ Implement `core/recommendation_engine/`:
  - `AffectState` input model (moodCategory, energyLevel, anxietyLevel, lonelinessLevel)
  - `ActionSuggestion` output model (actionType, title, body, route, durationMinutes)
  - `RecommendationEngine.evaluate(AffectState)` — pure function, no IO, deterministic
  - Priority rules (anxiety ≥ 4 → breathing; low + energy ≤ 2 → tiny steps; loneliness ≥ 4 → reach out; overwhelmed → grounding; moderate → journaling; calm → hope box)
- ✅ 100% unit test coverage for `RecommendationEngine` (all branches)
- ✅ Implement `CheckInEntry` domain model + `CheckInRepository` interface
- ✅ Implement `CheckInRepositoryImpl` with Drift DAO
- ✅ Implement `CheckInController` (`AsyncNotifier` / `StateNotifier`):
  - State: in-progress selection + submitted state
  - On submit: save to DB + call `RecommendationEngine.evaluate()` + return suggestion
- ✅ Implement `check_in_screen.dart`:
  - Mood selector row: 5 `MoodTile` components (Heavy → Open)
  - Energy slider: "Still → Moving"
  - Anxiety level: 5-dot selector (no numeric label)
  - Loneliness level: 5-dot selector
  - "I'm here" CTA button (56dp, sage fill)
- ✅ Implement `affect_result_card.dart` — displays `ActionSuggestion` with a navigation CTA
- ✅ Home screen: shows last check-in summary or "How are you right now?" prompt
- ✅ Aggregate mood history for `GentleProgress` screen (no individual entry detail — just distribution)
- ✅ Unit tests: Controller state flow, repository CRUD, mapper
- ✅ `git commit`: "feat: Phase 4 — affect check-in, deterministic recommendation engine"

**Exit Criteria:** Complete a check-in → correct intervention suggested → navigation works. Data persists. Recommendation engine unit tests: 100% pass.

---

## Phase 5 — Respiration Engine & Grounding

**Goal:** The breathing and grounding experience is smooth, calming, and precisely haptic-synced.

### Checklist

- ⬜ Implement `core/contracts/audio_player_port.dart` — abstract `AudioPlayerPort`
- ⬜ Implement `core/contracts/haptics_port.dart` — abstract `HapticsPort`
- ⬜ Implement `JustAudioPlayerAdapter` (concrete `AudioPlayerPort`):
  - Gapless looping via `LoopingAudioSource`
  - `fadeIn()` / `fadeOut()` — 300ms volume ramp (20 timer ticks)
  - Silent failure: audio errors caught, session continues
- ⬜ Implement `FlutterHapticsAdapter` (concrete `HapticsPort`):
  - `phaseTransition(inhale)` → double light impact 100ms apart
  - `phaseTransition(exhale)` → single light impact
  - `groundingConfirm()` → selection click
- ⬜ Implement `BreathingSessionNotifier` (`AsyncNotifier`):
  - Cyclic sighing: inhale 4000ms / exhale 8000ms
  - `Timer.periodic` at 50ms ticks driving `phaseProgress` (0.0 → 1.0)
  - `ref.onDispose` guarantees timer cancel + audio stop + haptic cancel
  - Error boundary: audio failure does not stop the session
  - Optimistic state: UI flips to active before IO completes
- ⬜ Implement `CyclicSighBloomPainter` (`CustomPainter`):
  - Radius: 50dp (exhale) → 120dp (inhale peak)
  - Three glow rings at decreasing opacity
  - `shouldRepaint` only when `progress` or `phase` changes
  - Color: sage during inhale, dusk-blue during exhale (smooth `ColorTween`)
- ⬜ Implement `breathing_grounding_screen.dart`:
  - Full-screen dark canvas (OLED black option)
  - Centered bloom painter (280×280dp)
  - Phase label: `displayMd` ("Breathe in" / "Let go")
  - Cycle count: `caption` non-prominently — no streak language
  - End session CTA: secondary button at bottom
- ⬜ Implement `grounding_prompt_card.dart` — 5-4-3-2-1 senses mode:
  - Sequential prompt cards (5 things to see → 4 to touch → 3 to hear → 2 to smell → 1 to taste)
  - Each card: tap to advance, haptic confirmation
- ⬜ `AudioPreferences` persisted to DB (last soundscape, volume)
- ⬜ Reduced motion: `MotionTokens.resolve()` collapses bloom animation to static circle
- ⬜ Widget tests: bloom painter renders correctly, phase label updates
- ⬜ `git commit`: "feat: Phase 5 — cyclic sighing engine, bloom painter, grounding, haptic sync"

**Exit Criteria:** Full breathing session runs for 3+ minutes. Audio loops gaplessly. Haptics fire on each phase transition. Navigating away mid-session — no timer leaks, audio stops, no crashes.

---

## Phase 6 — Tiny Steps, Journaling & Secure Wipe (MVP Completion)

**Goal:** Behavioral activation micro-actions and private expressive journaling are functional with cryptographic auto-delete.

### Checklist

- ⬜ Curate `tiny_steps` content library:
  - 20+ micro-actions categorized by: energy level (1–5) and affect state
  - Each action: title, body, durationMinutes (max 2), category
  - Stored as Dart constants (not DB — curated content, not user data)
- ⬜ Implement `TinyStepsController` — selects 3 actions matched to current `AffectState`
- ⬜ Implement `tiny_steps_screen.dart`:
  - 3 action cards, full-width, 72dp tap target
  - On completion: warm double-tap haptic + sage fade — no confetti
  - "I'll do this later" dismiss option
- ⬜ Implement `JournalEntry` domain model with TTL fields
- ⬜ Implement `JournalRepository` + `JournalRepositoryImpl`
- ⬜ Implement `core/contracts/voice_recognition_port.dart` + `VoskVoiceAdapter`
- ⬜ Implement `JournalController`:
  - Create, update (encrypted via `JournalCryptoService`), delete
  - Voice-to-text: launches `VoskVoiceAdapter` in background isolate
  - TTL: if `isAutoDeleteEnabled`, set `ttlDeleteAtUnix` = now + N days
- ⬜ Implement `journal_list_screen.dart`:
  - List shows: created date, word count (not content preview — privacy)
  - Pull-to-refresh
- ⬜ Implement `journal_entry_screen.dart`:
  - Large `TextField`, minimum height 200dp
  - Pennebaker mode toggle: shows "Write continuously for 15 minutes" timer (opt-in)
  - Unsent letter mode: header "This is for you — it won't be sent"
  - Voice-to-text button (offline Vosk)
  - Auto-delete toggle + duration picker (3 days / 7 days / 30 days / never)
  - Save: encrypts content via `JournalCryptoService` before DB write
- ⬜ Implement `SecureWipeService`:
  - Scheduled via `FlutterLocalNotifications` background callback
  - Overwrite content with random data → delete row → VACUUM
- ⬜ Implement `CryptographicEraser`:
  - Journal subkey rotation on "wipe all journals"
  - Version-incremented HKDF context → old ciphertext unreadable
- ⬜ Unit tests: Journal CRUD, TTL expiry logic, secure wipe triggers
- ⬜ `git commit`: "feat: Phase 6 — tiny steps, journaling, secure wipe"

**Exit Criteria:** Write a journal entry with auto-delete → advance system clock past TTL → wipe service erases the entry → entry unreadable. Voice-to-text works offline. Tiny steps correctly matched to check-in state.

---

## Phase 7 — Hope Box, Wind-Down & Loneliness (Next Roadmap)

**Goal:** Implement evidence-supported additions: Hope Box (B6), Wind-Down (B5), and Guess vs. Reality (B2).

### Checklist

- ⬜ Implement `HopeBoxScreen`:
  - Add items: photo (from device gallery), text note, voice note
  - All stored locally in app-private directory
  - Display: masonry grid of hope items
- ⬜ Implement `LonelinessComfortScreen`:
  - Ambient sound player (gentle rain default)
  - "Someone's here" breathing visual (slow ambient bloom)
  - "Guess vs. Reality" flow: log expectation → send message → log outcome
  - Pre-written SMS templates with one-tap `url_launcher`
- ⬜ Implement `WindDownScreen` (B5):
  - Sleep diary, fixed wake-time nudge, pre-bed "worry dump"
- ⬜ Implement DB schema migrations for Hope Box and Wind-Down features (v2 to v3)
- ⬜ `git commit`: "feat: Phase 7 — hope box, wind-down, loneliness comfort"

**Exit Criteria:** Hope box persists and displays media locally. Loneliness intervention properly connects to SMS intents and logs expectation vs reality. DB migration runs safely.

---

## Phase 8 — One-Session Reset & Extended Features (Later Roadmap)

**Goal:** Implement single-session interventions and extended features: One-Session Reset (B1), Movement Snacks (B4), Music Room (B7), Awe Walk (B3), Check-in Buddy (B8).

### Checklist

- ⬜ Implement `OneSessionResetScreen` (B1):
  - Self-contained 5–10 min guided module (name the problem → one skill → one small commitment)
- ⬜ Implement `MovementSnacksScreen` (B4):
  - 2–10 minute movement options matched to check-in (gentle for anxious, graded ladder for low energy)
- ⬜ Implement `MusicRoomScreen` (B7):
  - Import own music; "calm down" and "gentle lift" sets; slow soundscapes
- ⬜ Implement `AweWalkScreen` (B3):
  - 15-minute outdoor prompt with offline prompt cards ("find something vast", "notice something tiny")
- ⬜ Implement `CheckInBuddy` (B8):
  - User picks a trusted person; app prompts a ~2-minute weekly summary to share securely via intents
- ⬜ `git commit`: "feat: Phase 8 — one-session reset, movement, music room, awe walk, check-in buddy"

**Exit Criteria:** Single-session flows operate predictably and handle internal state. Audio components load external music appropriately.

---

## Phase 9 — Accessibility, SAST & Release

**Goal:** Firefly meets WCAG 2.2 AAA standards, passes all security audits, and is ready for App Store / Play Store submission.

### Checklist

#### Accessibility
- ⬜ Run Flutter accessibility checker on all screens
- ⬜ Verify all tap targets ≥ 56×56dp (Semantic tappable areas, not just visual)
- ⬜ Verify all text-on-background combinations meet 7:1 contrast (WCAG AAA)
- ⬜ Test at system font size 200%: no overflow, no clipped text on any screen
- ⬜ `MoodTile` and `EnergySlider`: `Semantics` labels for screen readers
- ⬜ `BreathingBloom`: `Semantics` announces phase changes to VoiceOver / TalkBack
- ⬜ All form fields: `autofillHints` disabled (prevents password manager pollution)
- ⬜ All images / icons: meaningful `semanticLabel` or `excludeFromSemantics: true`
- ⬜ `Reduced Motion` mode tested: all animations collapse, bloom becomes static

#### SAST & Security Verification
- ⬜ Run full Semgrep scan — zero violations
- ⬜ Run package deny-list check — zero banned packages
- ⬜ Run MobSF against release APK and IPA — zero high/critical findings
- ⬜ Verify `FLAG_SECURE` active: attempt screenshot in Android emulator — confirm black capture
- ⬜ Verify iOS blur overlay: background the app → confirm app switcher shows blur
- ⬜ Verify no outbound connections: Charles Proxy / mitmproxy — confirm zero requests
- ⬜ Verify `allowBackup=false`: confirm `adb backup` returns empty
- ⬜ Verify DB unreadable without key: copy `.db` file, attempt to open with DB Browser for SQLite — confirm encrypted

#### Performance
- ⬜ Profile breathing session with Flutter DevTools: confirm < 16ms frame build throughout
- ⬜ Memory: active audio session < 8 MB confirmed in DevTools Memory tab
- ⬜ Cold start to first meaningful frame < 2 seconds on mid-range Android
- ⬜ `should_repaint` audit: confirm `BreathingBloomPainter.shouldRepaint` correctly returns `false` on no-op ticks

#### Store Submission
- ⬜ App Store Privacy Label: all categories marked "Data Not Collected"
- ⬜ Google Play Data Safety Form: all data types "No" collection
- ⬜ App Store Review Notes: document offline-only nature and why no account is required
- ⬜ Crisis resource disclosure (required by both stores for mental health apps): confirm Safety Plan contains local crisis lines
- ⬜ `flutter build appbundle --release` — signed AAB ready for Play Console
- ⬜ `flutter build ipa --release` — IPA ready for App Store Connect
- ⬜ `git tag v1.0.0` + final commit: "release: v1.0.0 — Firefly initial release"

**Exit Criteria:** Both stores' privacy questionnaires completed with zero data collection claims. MobSF: zero critical findings. Accessibility: zero violations. Release builds signed and uploadable.
