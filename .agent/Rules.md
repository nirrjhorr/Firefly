# Rules.md
# Firefly — Engineering Rules, Approved Stack & Boundaries

**Version:** 1.0.0 | **Status:** Enforced from Phase 0 | **Updated:** 2026-09-30

> These rules are non-negotiable constraints, not suggestions. Every pull request, every generated file, and every agent task must be validated against this document before it is considered complete.

---

## 1. Approved Flutter Packages

### 1.1 Core — Allowed & Required

| Package | Purpose | Minimum Version |
|---|---|---|
| `flutter_riverpod` | State management framework | ^2.5.0 |
| `riverpod_annotation` | Code generation annotations | ^2.3.0 |
| `riverpod_generator` | Provider code generation | ^2.4.0 |
| `build_runner` | Code generation runner | ^2.4.0 |
| `drift` | Type-safe SQLite ORM | ^2.18.0 |
| `drift_sqflite` | SQLite executor for mobile | ^2.4.0 |
| `sqlcipher_flutter_libs` | AES-256 encrypted SQLite | ^0.3.0 |
| `flutter_secure_storage` | OS Keychain / Keystore key storage | ^9.2.0 |
| `local_auth` | Biometric + passcode unlock gate | ^2.3.0 |
| `go_router` | Declarative routing + shell routes | ^14.0.0 |
| `just_audio` | Gapless offline audio playback | ^0.9.40 |
| `audio_session` | iOS/Android audio focus | ^0.1.21 |
| `vosk_flutter` | 100% on-device offline STT | ^0.3.0 |
| `url_launcher` | Native `tel:` and `sms:` intents | ^6.3.0 |
| `file_picker` | User-initiated backup export/import | ^8.1.0 |
| `path_provider` | App-private directory resolution | ^2.1.4 |
| `cryptography` | AES-GCM + Argon2id backup engine | ^2.7.0 |
| `flutter_lints` | Base lint rules | ^4.0.0 |
| `custom_lint` | Extended lint enforcement | ^0.6.0 |

### 1.2 Dev-Only Packages (Never Ship in Release)

| Package | Purpose |
|---|---|
| `drift_dev` | Drift code generation |
| `mocktail` | Unit test mocking |
| `flutter_test` | Widget testing |

---

## 2. Approved Agent Skills

| Skill ID | Purpose | When to Activate |
|---|---|---|
| `flutter-expert` | Flutter widget, layout, animation implementation | All UI phases |
| `flutter-riverpod-expert` | Riverpod provider patterns, `AsyncNotifier` lifecycle | State management tasks |
| `c4-architecture-c4-architecture` | System context, container, and component diagrams | Architecture updates |
| `security-auditor` | Cryptographic review, STRIDE analysis, key lifecycle | Security phases, pre-release |
| `unit-testing-test-generate` | Test generation for repositories, controllers, engine | Every feature phase |

---

## 3. Architecture Boundaries (Hard Rules)

### 3.1 Layering Contract

```
UI Widget
    ↓ (calls)
Feature Controller (Riverpod AsyncNotifier)
    ↓ (calls)
Repository Interface (abstract — domain boundary)
    ↓ (implemented by)
Repository Impl → DTO Mapper → Drift DAO
                                    ↓
                            SQLCipher Database
```

**Violations that must be rejected at code review:**
- Any `Widget.build()` that calls a DAO method directly
- Any `Controller` that imports `drift` or `sqflite`
- Any `Repository` that imports Riverpod providers
- Any feature that imports from another feature's `presentation/` layer

### 3.2 Dependency Direction

```
presentation → domain ← data
                ↑
              core/*
```

`core/` is imported by all layers. Features import from `core/` and `shared/`. Features **never** import from each other's presentation layer.

### 3.3 State Management Rules

- All async state operations use `AsyncNotifier` — no raw `FutureProvider` for user-writable state
- Every `AnimationController`, `Timer`, `StreamSubscription`, and `AudioPlayer` instance MUST be disposed in `ref.onDispose()` — no exceptions
- State classes are immutable (`@immutable`, `copyWith` pattern)
- UI rebuilds triggered by `ref.watch` only — never `setState` inside `ConsumerWidget` for domain-level state

---

## 4. Error Handling Standard

### 4.1 Result Type

All repository methods return `Result<T, Failure>` — never throw across layer boundaries.

```dart
// core/errors/result.dart
sealed class Result<T, E> {
  const Result();
}

final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);
  final E error;
}
```

### 4.2 Hardware Degradation (Silent Failure Rule)

Audio and haptic failures **MUST NEVER crash or degrade the UI**. Use defensive wrappers:

```dart
// Correct pattern for hardware calls
Future<void> _safePlay(AudioAsset asset) async {
  try {
    await _audio.play(asset);
  } catch (_) {
    // Silent degradation — breathing session continues without audio
    // Log locally via package:logging only
  }
}
```

### 4.3 Database Failure Protocol

If the database cannot be opened (wrong key, corrupted file):
1. Surface a user-safe error message ("Unable to open your data. Try unlocking again.")
2. **Never** delete or overwrite the database file automatically
3. Offer "Export encrypted backup" if a prior backup exists
4. Route to a locked screen — do not enter the app

---

## 5. Security Rules (Non-Negotiable)

### 5.1 Zero Network Policy

```dart
// MUST be the first line in main() — before any other initialization
HttpOverrides.global = FireflyHttpOverride();
```

- The `http` package must NOT appear in `pubspec.yaml` or `pubspec.lock`
- The `dio` package is banned
- CI must run a package deny-list check on every PR

### 5.2 Key & Storage Rules

| Rule | Enforcement |
|---|---|
| All Keychain items: `synchronizable: false` | `flutter_secure_storage` option — mandatory |
| Android backup: `allowBackup="false"` | `AndroidManifest.xml` — verified by CI |
| iOS DB file: `NSURLIsExcludedFromBackupKey = true` | Set on db file path after first open |
| No SQLite file opened without SQLCipher key PRAGMA | `beforeOpen` callback enforces this |
| No plaintext SharedPreferences for sensitive data | Lint rule + code review |

### 5.3 Privacy Rules

- `FLAG_SECURE` must be set in `MainActivity.onCreate()` (Android)
- Blur overlay on `applicationWillResignActive` (iOS) — no app switcher screenshots
- No `print()` statements in any file (Semgrep rule + lint)
- No analytics, crash reporting, or session tracking of any kind

---

## 6. Anti-Patterns — Explicitly Banned

### ❌ Telemetry & Analytics SDKs

```
BANNED: firebase_core, firebase_analytics, crashlytics,
        sentry_flutter, datadog_flutter_plugin,
        amplitude_flutter, mixpanel_flutter, segment_analytics,
        google_sign_in, google_mobile_ads
```

Installing any of these is an automatic PR rejection with no exceptions.

### ❌ Gamification & Guilt Mechanics

- No streak counters that reset on a missed day
- No achievement badges for completing sessions
- No push notifications saying "You missed X days"
- No countdown timers creating urgency
- No confetti, particle effects, or celebratory sound effects
- Allowed alternative: quiet "You showed up N times this week" summary — positive framing only

### ❌ Diagnostic Claims

- No copy that says "This app treats depression/anxiety/PTSD"
- No diagnostic scales used as actual diagnostic tools (PHQ-9 for check-in is fine as self-reflection, not diagnosis)
- Every screen involving mental health must carry a persistent footer: *"Firefly supports — it does not replace professional care."*

### ❌ Unconstrained LLMs

- No direct API calls to any LLM service (OpenAI, Gemini, Anthropic, etc.)
- On-device LLM (future): must be opt-in, sandboxed to journaling reflective prompts only, and gated by a crisis-keyword blocklist before any output is displayed
- The recommendation engine is deterministic Dart — not generative AI

### ❌ Plaintext Storage

- No `SharedPreferences` for any user-entered content, mood data, or safety plan data
- No SQLite without SQLCipher
- No plaintext log files containing user data
- No unencrypted backups — all exports are AES-256-GCM encrypted

### ❌ Aggressive UI Patterns

- No modal dialogs that cannot be dismissed without completing an action
- No auto-playing audio without user initiation
- No animations that run > 16ms/frame (jank budget violation)
- No `setState` calls inside `build()` methods
- No `shouldRepaint` returning `true` unconditionally on `CustomPainter`

---

## 7. Code Style & Quality Gates

### 7.1 Dart Style

- All code formatted with `dart format` (enforced in CI)
- Maximum line length: 100 characters
- No `dynamic` type — use sealed classes or generics
- No `late` variables without explicit initialization contract documented in a comment
- All `TODO` comments must include a GitHub issue reference: `// TODO(#42): ...`

### 7.2 Testing Requirements (Per Phase)

| Layer | Required Coverage |
|---|---|
| `core/recommendation_engine/` | 100% (pure functions, no IO) |
| Repository implementations | ≥ 80% (mocked DAO) |
| Feature controllers | ≥ 75% (mocked repository) |
| UI widgets | Smoke tests (golden tests for key screens) |
| Security (key manager, crypto) | Integration tests on device |

### 7.3 CI Pipeline Gates (Must Pass Before Merge)

1. `dart format --set-exit-if-changed .` — formatting
2. `dart analyze --fatal-infos` — zero analysis warnings
3. `semgrep --config .semgrep/firefly_security.yaml` — security rules
4. Package deny-list check (grep `pubspec.lock`)
5. `flutter test` — all unit + widget tests
6. `flutter build apk --release` — clean release build
