# Story 4.2: Respiration State Management & Cyclic Sighing Engine

Status: ready-for-dev

## Story Description
As a user regulating acute distress,
I want a reactive breathing controller running a precise cyclic sighing cadence (4s inhale / 8s exhale),
So that my autonomic nervous system is guided toward parasympathetic calm without requiring active cognitive counting.

## Acceptance Criteria
1. `BreathingPhase` enum (`inhale`, `exhale`) and `BreathingSessionState` domain/state models:
   - Tracks `phase`, `phaseProgress` (0.0 to 1.0), `cycleCount`, `elapsedSeconds`, `isActive`, and `soundscape`.
2. `BreathingSessionNotifier` controller:
   - Configurable or clinical default 4s (4000ms) inhale and 8s (8000ms) exhale cyclic sighing cadence.
   - 50ms periodic ticker driving smooth normalized progress.
   - Triggers `hapticsPort.phaseTransitionInhale()` and `phaseTransitionExhale()` at exact phase boundaries.
   - `ref.onDispose` guarantees immediate timer cancellation, audio stop, and haptic cleanup.
   - Error boundary: audio port failure does not block respiration ticker.
3. Unit tests verifying:
   - Exact cadence durations and progress computation.
   - Phase cycling and cycle count increments.
   - Cancellation lifecycle and timer resource disposal.
