# Memory.md
# Firefly — Agent Memory & State

**Current Phase:** Sprint 1: Core Foundation & Encrypted Storage (Implementation Completed)

## Micro-Tasks for Sprint 1

### Task 1: Project Scaffolding & Linter Setup
- [x] 1.1 Run workspace initialization and establish clean structure.
- [x] 1.2 Replace `lib/main.dart` with a minimal `ProviderScope` shell and remove default counter code.
- [x] 1.3 Configure `analysis_options.yaml` with strict lints as defined in Phases.md.
- [x] 1.4 Update `pubspec.yaml` with all approved packages (Riverpod, Drift, SQLCipher, Secure Storage, local_auth, go_router, etc.) and remove banned packages. Register assets/fonts.
- [x] 1.5 Establish the feature-first folder tree (`lib/core/`, `lib/features/`, `lib/shared/`) and `assets/` structure.
- [x] 1.6 Apply security baselines: Android `allowBackup="false"`, cleartext disabled, iOS `NSAppTransportSecurity`, and create `core/errors/result.dart`.

### Task 2: Hardware Key Derivation & App Lock
- [x] 2.1 Implement `core/security/key_manager.dart` utilizing `flutter_secure_storage`.
- [x] 2.2 Implement `core/security/biometric_guard.dart` with `local_auth`.
- [x] 2.3 Implement `core/security/network_kill_switch.dart` and integrate it into `main.dart`.

### Task 3: Encrypted Database Engine (Drift + SQLCipher)
- [x] 3.1 Define Drift schema tables (`MoodCheckIns`, `JournalEntries`, `SafetyPlans`, `SafetyPlanContacts`, `SafetyPlanWarnings`, `SafetyPlanSteps`, `AudioPreferences`, `AppConfiguration`, `UsageSummaries`).
- [x] 3.2 Configure `core/database/app_database.dart` with SQLCipher PRAGMAs (`key`, `cipher_page_size = 4096`, `cipher_hmac_algorithm = HMAC_SHA512`, `kdf_iter = 256000`), foreign keys ON, WAL mode, and `secure_delete = ON`.
- [x] 3.3 Prepare migration runner in `core/database/migrations/migration_runner.dart`.
- [x] 3.4 Write unit tests verifying DB schema tables and encryption contracts in `test/core/database/`.

### Task 4: Design System Tokens & Base Navigation
- [x] 4.1 Implement `core/theme/app_colors.dart` (low-stimulation dark canvas `#111518`, deep rest `#0A0D0F`, sage `#4A7862`, crisis coral `#B05454`, and calm daylight).
- [x] 4.2 Implement `core/theme/app_typography.dart` (Atkinson Hyperlegible, Plus Jakarta Sans, JetBrains Mono) with dynamic scaling limits.
- [x] 4.3 Implement `core/theme/animation_tokens.dart` and `core/theme/spacing_tokens.dart`.
- [x] 4.4 Implement `core/theme/app_theme.dart` (Material 3 with custom tokens extension).
- [x] 4.5 Scaffold `go_router` in `core/routing/` with shell routing, bottom navigation bar, and accessible 1-tap `SosOverlayButton` for the Stanley-Brown Safety Plan.
- [x] 4.6 Create screen scaffolding for all primary feature roots.
- [x] 4.7 Authored automated unit test suites in `test/core/`.

## State
**Currently Working On:** Sprint 1 Review & Verification.
**Next Immediate Step:** Prepare for Sprint 2 (Safety Plan priority implementation & Check-in engine).
