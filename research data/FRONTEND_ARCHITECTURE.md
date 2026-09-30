# FRONTEND_ARCHITECTURE.md
# Firefly — Flutter Frontend Architecture Specification

**Version:** 1.0.0
**Date:** 2026-09-30
**Status:** Sprint 0 — Approved Blueprint

> This document is the authoritative specification for the Firefly Flutter frontend. It is intended for the engineering team and serves as the single source of truth for all architectural decisions in the presentation and application layers.

---

## Table of Contents
1. [State Management & Lifecycle Architecture](#1-state-management--lifecycle-architecture)
2. [Navigation & Deep-Linking Flow](#2-navigation--deep-linking-flow)
3. [Feature-First Folder Structure](#3-feature-first-folder-structure)
4. [UI Layer Performance & Animation Engine](#4-ui-layer-performance--animation-engine)
5. [Integration Contracts](#5-integration-contracts)

---

## 1. State Management & Lifecycle Architecture

### 1.1 Decision: Riverpod with `@riverpod` Codegen + `AsyncNotifier`

After evaluating BLoC and Riverpod, **Riverpod with code generation** is the specified standard for Firefly.

| Criterion | Riverpod (`@riverpod`) | BLoC |
|---|---|---|
| Compile-time safety | ✅ Full (generated providers) | ⚠️ Partial (events are dynamic) |
| Boilerplate | ✅ Minimal with codegen | ❌ High (Event/State/Bloc classes per feature) |
| Async data (DB streams) | ✅ Native `AsyncNotifier`/`StreamNotifier` | ⚠️ Requires manual stream subscription management |
| Testability | ✅ `ProviderContainer` override | ✅ `bloc_test` helpers |
| Offline-first suitability | ✅ Excellent (local stream-first) | ✅ Good |
| Trauma-informed teardown | ✅ `ref.onDispose` is guaranteed | ⚠️ Manual `close()` required |

**Verdict:** Riverpod's `ref.onDispose` contract guarantees resource cleanup (audio, timers, haptics) when a user navigates away mid-session — critical for trauma-informed UX. BLoC's manual `close()` introduces a risk of resource leaks.

---

### 1.2 State Lifecycle Categories

All feature state falls into one of three lifecycle categories:

| Category | Example | Riverpod Primitive | Persistence |
|---|---|---|---|
| **Transient** | Active breathwork timer, tap state | `@riverpod` (auto-disposed) | None — lives in memory |
| **Session** | In-progress check-in answers, draft journal | `@Riverpod(keepAlive: false)` | Ephemeral — cleared on app restart |
| **Persistent** | Completed journals, saved safety plan | `@Riverpod(keepAlive: true)` backed by Drift stream | SQLCipher-encrypted DB |

---

### 1.3 Reference Implementation: `BreathingSessionNotifier`

This pattern demonstrates the required standards for **error boundaries**, **optimistic state**, **resource cleanup**, and **haptic/audio sync**.

```dart
// lib/features/breathing_grounding/presentation/controllers/
// breathing_session_controller.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firefly/features/breathing_grounding/domain/models/breathing_phase.dart';
import 'package:firefly/core/contracts/audio_player_port.dart';
import 'package:firefly/core/contracts/haptics_port.dart';

part 'breathing_session_controller.g.dart';

// ─── State ────────────────────────────────────────────────────────────────────

enum BreathingPhase { idle, inhale, holdTop, exhale, holdBottom }

class BreathingSessionState {
  const BreathingSessionState({
    this.phase = BreathingPhase.idle,
    this.cycleCount = 0,
    this.phaseProgress = 0.0,
    this.isActive = false,
    this.error,
  });

  final BreathingPhase phase;
  final int cycleCount;
  final double phaseProgress; // 0.0 → 1.0 within current phase
  final bool isActive;
  final String? error;

  BreathingSessionState copyWith({
    BreathingPhase? phase,
    int? cycleCount,
    double? phaseProgress,
    bool? isActive,
    String? error,
  }) =>
      BreathingSessionState(
        phase: phase ?? this.phase,
        cycleCount: cycleCount ?? this.cycleCount,
        phaseProgress: phaseProgress ?? this.phaseProgress,
        isActive: isActive ?? this.isActive,
        error: error,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

/// Cyclic sighing pattern: 2-count double inhale → 8-count exhale.
/// All durations in milliseconds.
const _kInhaleDuration  = 2000;
const _kExhaleDuration  = 8000;
const _kTickInterval    = 50; // 20fps is sufficient for a progress gauge

@riverpod
class BreathingSessionNotifier extends _$BreathingSessionNotifier {
  Timer? _ticker;
  int    _phaseElapsed = 0;

  // Injected ports (see §5 Integration Contracts)
  late final AudioPlayerPort    _audio;
  late final HapticsPort        _haptics;

  @override
  BreathingSessionState build() {
    // --- Lifecycle teardown guarantee ---
    // This runs even if the user navigates away mid-breath. Ensures no
    // orphaned timers, leaked audio channels, or lingering haptic patterns.
    ref.onDispose(_teardown);

    _audio   = ref.watch(audioPlayerPortProvider);
    _haptics = ref.watch(hapticsPortProvider);

    return const BreathingSessionState();
  }

  // ── Public API ──────────────────────────────────────────────────────────────

  Future<void> startSession() async {
    // Optimistic state: immediately flip UI to active before IO
    state = state.copyWith(isActive: true, phase: BreathingPhase.inhale);

    try {
      await _audio.play(AudioAsset.cyclicSighAmbience);
      _beginPhase(BreathingPhase.inhale);
    } catch (e) {
      // Error boundary: audio failure should NOT crash the breathing session.
      // Log locally, surface a soft warning, and continue without audio.
      state = state.copyWith(
        error: 'Audio unavailable. Session continues silently.',
      );
      _beginPhase(BreathingPhase.inhale);
    }
  }

  void pauseSession() {
    _ticker?.cancel();
    _audio.pause();
    state = state.copyWith(isActive: false);
  }

  void resumeSession() {
    state = state.copyWith(isActive: true);
    _beginPhase(state.phase);
    _audio.resume();
  }

  Future<void> endSession() async {
    _teardown();
    state = const BreathingSessionState(); // reset to idle
  }

  // ── Internal Phase Engine ───────────────────────────────────────────────────

  void _beginPhase(BreathingPhase phase) {
    _ticker?.cancel();
    _phaseElapsed = 0;
    state = state.copyWith(phase: phase, phaseProgress: 0.0);

    // Trigger haptic cue on phase transition
    _haptics.phaseTransition(phase);

    final duration = _phaseDuration(phase);

    _ticker = Timer.periodic(
      const Duration(milliseconds: _kTickInterval),
      (timer) {
        _phaseElapsed += _kTickInterval;
        final progress = (_phaseElapsed / duration).clamp(0.0, 1.0);
        state = state.copyWith(phaseProgress: progress);

        if (_phaseElapsed >= duration) {
          timer.cancel();
          _advancePhase();
        }
      },
    );
  }

  void _advancePhase() {
    final nextPhase = switch (state.phase) {
      BreathingPhase.inhale     => BreathingPhase.exhale,
      BreathingPhase.exhale     => BreathingPhase.inhale,
      _                         => BreathingPhase.idle,
    };

    if (nextPhase == BreathingPhase.inhale) {
      // One full cycle completed
      state = state.copyWith(cycleCount: state.cycleCount + 1);
    }

    _beginPhase(nextPhase);
  }

  int _phaseDuration(BreathingPhase phase) => switch (phase) {
    BreathingPhase.inhale      => _kInhaleDuration,
    BreathingPhase.exhale      => _kExhaleDuration,
    _                          => 0,
  };

  void _teardown() {
    _ticker?.cancel();
    _ticker = null;
    _audio.stop();
    _haptics.cancel();
  }
}
```

---

## 2. Navigation & Deep-Linking Flow

### 2.1 Router Architecture: `go_router` with Shell Routes

```
GoRouter
│
├── /                           → SplashRoute (auth guard → privacy lock)
├── /home (ShellRoute)          → MainShellScaffold (bottom nav)
│   ├── /home/check-in          → CheckInScreen
│   ├── /home/breathe           → BreathingGroundingScreen
│   ├── /home/journal           → JournalListScreen
│   │   └── /home/journal/:id   → JournalEntryScreen
│   ├── /home/tiny-steps        → TinyStepsScreen
│   └── /home/progress          → GentleProgressScreen
│
├── /onboarding                 → OnboardingFlow (first launch only)
├── /safety-plan                → SafetyPlanScreen (emergency overlay)
└── /privacy-lock               → BiometricLockScreen
```

### 2.2 `go_router` Configuration

```dart
// lib/core/routing/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

// Route name constants — never use raw strings in navigation calls
abstract final class AppRoutes {
  static const splash      = '/';
  static const onboarding  = '/onboarding';
  static const home        = '/home';
  static const checkIn     = '/home/check-in';
  static const breathe     = '/home/breathe';
  static const journal     = '/home/journal';
  static const tinySteps  = '/home/tiny-steps';
  static const progress   = '/home/progress';
  static const safetyPlan = '/safety-plan';
  static const privacyLock = '/privacy-lock';
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final isPrivacyLocked = ref.watch(privacyLockProvider);
  final isFirstLaunch   = ref.watch(onboardingStatusProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false, // NEVER log routes in production (sensitive paths)
    redirect: (context, state) {
      // Guard 1: Privacy lock (biometric / PIN)
      final onLockScreen = state.matchedLocation == AppRoutes.privacyLock;
      if (isPrivacyLocked && !onLockScreen) {
        return AppRoutes.privacyLock;
      }

      // Guard 2: Onboarding
      if (isFirstLaunch && state.matchedLocation != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }

      return null; // no redirect
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyLock,
        builder: (_, __) => const BiometricLockScreen(),
      ),

      // ── Emergency Safety Plan: full-screen modal over any route ──────────
      // This route is reachable from ANYWHERE in the app via a persistent
      // SOS button that overlays the NavigationShell.
      GoRoute(
        path: AppRoutes.safetyPlan,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SafetyPlanScreen(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ),

      // ── Main Shell: Bottom Navigation ─────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) =>
            MainShellScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.checkIn,
            builder: (_, __) => const CheckInScreen(),
          ),
          GoRoute(
            path: AppRoutes.breathe,
            builder: (_, __) => const BreathingGroundingScreen(),
          ),
          GoRoute(
            path: AppRoutes.journal,
            builder: (_, __) => const JournalListScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (_, state) => JournalEntryScreen(
                  entryId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.tinySteps,
            builder: (_, __) => const TinyStepsScreen(),
          ),
          GoRoute(
            path: AppRoutes.progress,
            builder: (_, __) => const GentleProgressScreen(),
          ),
        ],
      ),
    ],
  );
}
```

### 2.3 Emergency Safety Plan — Instant Modal Overlay

The Safety Plan is accessible via a persistent `FloatingActionButton`-style SOS overlay that sits above the `NavigationShell`. It must be reachable within **one tap from any screen**.

```dart
// lib/shared/widgets/sos_overlay_button.dart

class SosOverlayButton extends StatelessWidget {
  const SosOverlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 96, // above bottom nav bar
      right: 16,
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.safetyPlan),
        child: Container(
          // Intentionally dim and unobtrusive — only visible when needed
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withOpacity(0.4),
            ),
          ),
          child: const Icon(Icons.shield_outlined, size: 20),
        ),
      ),
    );
  }
}
```

---

## 3. Feature-First Folder Structure

```
lib/
│
├── main.dart                          # ProviderScope + async DB initialization
│
├── core/                              # App-wide infrastructure (no UI)
│   ├── database/
│   │   ├── app_database.dart          # Drift database root + SQLCipher config
│   │   ├── migrations/                # Versioned Drift schema migrations
│   │   └── tables/                    # Drift table definitions (DAOs)
│   │
│   ├── security/
│   │   ├── key_manager.dart           # flutter_secure_storage key generation/retrieval
│   │   └── biometric_guard.dart       # local_auth wrappers
│   │
│   ├── routing/
│   │   ├── app_router.dart            # go_router configuration (see §2)
│   │   └── route_guards.dart          # Redirect logic
│   │
│   ├── theme/
│   │   ├── app_theme.dart             # Light/dark MaterialTheme
│   │   ├── color_tokens.dart          # Semantic color constants
│   │   ├── typography.dart            # Text styles
│   │   └── animation_tokens.dart      # Duration + curve constants for consistency
│   │
│   ├── contracts/                     # Abstract interface ports (see §5)
│   │   ├── audio_player_port.dart
│   │   ├── haptics_port.dart
│   │   └── voice_recognition_port.dart
│   │
│   ├── errors/
│   │   ├── app_exception.dart         # Domain-level exception types
│   │   └── error_handler.dart         # Maps exceptions to user-safe messages
│   │
│   └── utils/
│       ├── dart_extensions.dart       # General Dart/Flutter extension methods
│       └── local_date_utils.dart      # Timezone-safe local date handling
│
├── shared/                            # Pure UI components, no business logic
│   └── widgets/
│       ├── firefly_button.dart        # Primary accessible CTA button
│       ├── firefly_card.dart          # Soft-radius card container
│       ├── gentle_progress_bar.dart   # Non-gamified progress indicator
│       ├── sos_overlay_button.dart    # Emergency Safety Plan trigger (see §2.3)
│       ├── breathing_bloom.dart       # Custom painter for breathing animation
│       └── mood_selector.dart         # Accessible tap-target mood picker
│
└── features/
    │
    ├── check_in/
    │   ├── data/
    │   │   ├── check_in_repository_impl.dart
    │   │   └── sources/
    │   │       └── check_in_local_source.dart   # Drift DAO calls
    │   ├── domain/
    │   │   ├── check_in_entry.dart              # Immutable entity
    │   │   └── check_in_repository.dart         # Abstract interface
    │   └── presentation/
    │       ├── screens/
    │       │   └── check_in_screen.dart
    │       ├── controllers/
    │       │   └── check_in_controller.dart     # AsyncNotifier
    │       ├── states/
    │       │   └── check_in_state.dart
    │       └── widgets/
    │           └── mood_check_card.dart
    │
    ├── breathing_grounding/
    │   ├── data/
    │   │   └── breathing_repository_impl.dart
    │   ├── domain/
    │   │   └── breathing_session.dart
    │   └── presentation/
    │       ├── screens/
    │       │   └── breathing_grounding_screen.dart
    │       ├── controllers/
    │       │   └── breathing_session_controller.dart   # Full impl: see §1.3
    │       ├── states/
    │       │   └── breathing_session_state.dart
    │       └── widgets/
    │           ├── cyclic_sigh_bloom_painter.dart      # Custom painter
    │           └── phase_label_widget.dart
    │
    ├── journaling/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │       └── widgets/
    │           └── voice_to_text_button.dart           # Vosk offline STT
    │
    ├── tiny_steps/                        # Behavioral activation feature
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── safety_plan/
    │   ├── data/
    │   ├── domain/
    │   │   └── safety_plan.dart           # Stanley-Brown 6-step model
    │   └── presentation/
    │       └── screens/
    │           └── safety_plan_screen.dart
    │
    ├── hope_box/
    ├── one_session_reset/
    └── gentle_progress/
```

---

## 4. UI Layer Performance & Animation Engine

### 4.1 Rendering Strategy for Calming Visuals

All breathing and grounding animations must be:
1.  **Shader-free** unless the device supports Impeller (avoid `BackdropFilter` on mid-range Android).
2.  **`CustomPainter`-driven** for breathing blooms (avoids widget tree rebuilds during animation ticks).
3.  **Capped at 60fps** — there is no perceptual benefit above 60fps for slow pacing animations.

#### Reference: `CyclicSighBloomPainter`
```dart
// lib/features/breathing_grounding/presentation/widgets/
// cyclic_sigh_bloom_painter.dart

class CyclicSighBloomPainter extends CustomPainter {
  CyclicSighBloomPainter({
    required this.progress,  // 0.0 → 1.0 from BreathingSessionState.phaseProgress
    required this.phase,
    required this.color,
  }) : super(repaint: null); // repaint driven externally by AnimationController

  final double progress;
  final BreathingPhase phase;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    // Bloom grows on inhale, gently collapses on exhale
    final maxRadius = size.shortestSide * 0.45;
    final minRadius = size.shortestSide * 0.18;
    final radius = phase == BreathingPhase.inhale
        ? lerpDouble(minRadius, maxRadius, progress)!
        : lerpDouble(maxRadius, minRadius, progress)!;

    // Outer glow — uses three concentric circles at decreasing opacity
    for (int i = 3; i > 0; i--) {
      canvas.drawCircle(
        center,
        radius * (1 + i * 0.12),
        Paint()
          ..color = color.withOpacity(0.04 * i)
          ..style = PaintingStyle.fill,
      );
    }

    // Core bloom circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withOpacity(0.85)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(CyclicSighBloomPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.phase != phase;
}
```

**Integration:**
```dart
// In BreathingGroundingScreen — connects AnimationController to state
AnimatedBuilder(
  animation: _bloomController, // Driven by Timer in Notifier via ref.listen
  builder: (_, __) => CustomPaint(
    painter: CyclicSighBloomPainter(
      progress: breathingState.phaseProgress,
      phase: breathingState.phase,
      color: Theme.of(context).colorScheme.primary,
    ),
    size: const Size.square(280),
  ),
),
```

### 4.2 Animation Toolkit Tiers

| Use Case | Tool | Rationale |
|---|---|---|
| Breathing bloom, pacing gauges | `CustomPainter` + `AnimationController` | Zero widget tree overhead; smooth 60fps |
| Micro-interactions (button press, card appear) | `flutter_animate` | Declarative, chainable, tiny footprint |
| Complex character / mascot animations | `rive` runtime | GPU-accelerated state machines; < 2MB assets |
| Page transitions | `go_router` `CustomTransitionPage` | Consistent, testable, no third-party dependency |

### 4.3 Performance Guidelines & Budgets

| Resource | Budget | Enforcement |
|---|---|---|
| Frame build time | < 16ms (60fps) | `flutter run --profile` + DevTools Timeline |
| Active audio session memory | < 8 MB | `just_audio` isolate monitoring |
| `CustomPainter` repaint cycles | Only on state Δ | `shouldRepaint` must return `false` on no-op ticks |
| App launch to first meaningful frame | < 2s (cold start) | Lazy-load non-MVP features via `Isolate.spawn` |
| Background isolate (Vosk STT) | < 50 MB RAM | Terminate isolate immediately after transcription |

#### Jank Prevention Rules
1.  **No synchronous DB reads on the UI thread.** All Drift calls return `Future` or `Stream`; never `.fetchOne()` inside `build()`.
2.  **Breathing phase updates must NOT trigger `setState` on parent.** Use `ref.listen` in a `ConsumerWidget` to isolate rebuilds to the bloom painter only.
3.  **`shouldRepaint` is mandatory** on all `CustomPainter` subclasses. Returning `true` unconditionally is a hard lint violation.
4.  **Audio fade-in/out** using `just_audio`'s `setVolume` over 300ms prevents jarring cuts that could re-trigger anxiety.

---

## 5. Integration Contracts

All presentation controllers interact with hardware and data exclusively through **abstract interface ports**. This enforces testability (mock implementations), decouples features from infrastructure, and prevents direct dependency on platform channels.

### 5.1 `AudioPlayerPort`

```dart
// lib/core/contracts/audio_player_port.dart

enum AudioAsset {
  cyclicSighAmbience,
  groundingChime,
  gentleRain,
  whiteNoise,
}

/// Abstract port for all audio playback in the app.
/// Concrete implementation: `JustAudioPlayerAdapter` (lib/core/audio/).
abstract interface class AudioPlayerPort {
  Future<void> play(AudioAsset asset, {bool loop = false});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> setVolume(double volume); // 0.0 → 1.0
  Future<void> fadeIn({Duration duration = const Duration(milliseconds: 300)});
  Future<void> fadeOut({Duration duration = const Duration(milliseconds: 300)});
  void dispose();
}
```

### 5.2 `HapticsPort`

```dart
// lib/core/contracts/haptics_port.dart

/// Abstract port for haptic feedback patterns.
/// Concrete implementation uses `HapticFeedback` + platform-specific channels.
abstract interface class HapticsPort {
  /// Called at each phase transition (inhale/exhale boundary).
  Future<void> phaseTransition(BreathingPhase phase);

  /// Gentle pulse for grounding (5-4-3-2-1) confirmations.
  Future<void> groundingConfirm();

  /// Subtle tap for check-in mood selections.
  Future<void> selectionTap();

  /// Cancel any ongoing repeating haptic pattern.
  void cancel();
}
```

### 5.3 `VoiceRecognitionPort`

```dart
// lib/core/contracts/voice_recognition_port.dart

/// Abstract port for offline speech-to-text (Vosk).
/// All audio processing happens on a background Isolate — never on UI thread.
abstract interface class VoiceRecognitionPort {
  /// Returns a stream of partial transcription results.
  Stream<String> transcribePartial();

  /// Returns the final, committed transcription text.
  Future<String> transcribeFinal();

  void startListening();
  void stopListening();
  bool get isListening;
}
```

### 5.4 `CheckInRepository` (Data Layer Contract)

```dart
// lib/features/check_in/domain/check_in_repository.dart

import 'package:firefly/features/check_in/domain/check_in_entry.dart';

abstract interface class CheckInRepository {
  /// Persists a completed check-in entry to encrypted local storage.
  Future<void> saveCheckIn(CheckInEntry entry);

  /// Returns a reactive stream of the N most recent check-in entries.
  Stream<List<CheckInEntry>> watchRecentCheckIns({int limit = 7});

  /// Returns the most recent entry, or null if none exists.
  Future<CheckInEntry?> getLatestCheckIn();
}
```

### 5.5 Provider Wiring (Dependency Injection)

```dart
// lib/core/providers/infrastructure_providers.dart

// Audio
@riverpod
AudioPlayerPort audioPlayerPort(AudioPlayerPortRef ref) {
  final adapter = JustAudioPlayerAdapter();
  ref.onDispose(adapter.dispose);
  return adapter;
}

// Haptics
@riverpod
HapticsPort hapticsPort(HapticsPortRef ref) => FlutterHapticsAdapter();

// Voice Recognition (created lazily — only when journaling feature is active)
@riverpod
VoiceRecognitionPort voiceRecognitionPort(VoiceRecognitionPortRef ref) {
  final adapter = VoskVoiceAdapter();
  ref.onDispose(adapter.stopListening);
  return adapter;
}

// Repository
@riverpod
CheckInRepository checkInRepository(CheckInRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return CheckInRepositoryImpl(db.checkInDao);
}
```

---

## Appendix: Coding Standards Summary

| Rule | Standard |
|---|---|
| State Notifier pattern | `AsyncNotifier` for async, `Notifier` for sync |
| Routing | `context.go()` for tab switches; `context.push()` for sheets/modals |
| No raw strings in navigation | Always use `AppRoutes.*` constants |
| No direct DB access from `build()` | All reads via `StreamNotifier` or `AsyncNotifier` |
| Logging | Use `package:logging`; never `print()` in production |
| `shouldRepaint` | Always explicitly implemented; never `return true` unconditionally |
| Error surfaces | Use `error` field in state, not `SnackBar` throws (too jarring) |
| Privacy in logs | Route names must not log journal content, mood scores, or crisis events |

---

*Document maintained by the Firefly Engineering Team. Update version header on any structural change.*
