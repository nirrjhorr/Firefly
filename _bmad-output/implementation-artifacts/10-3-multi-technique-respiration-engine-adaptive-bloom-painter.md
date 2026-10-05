# Story 10.3: Multi-Technique Respiration Engine & Adaptive Bloom Painter

Status: done
Epic: 10 - v2 State-Based Regulation Architecture & Core Suite
FR: FR-11 (Breathing Studio & Adaptive Visualizer)

## Overview
Expanded the core cyclic sighing respiration engine into a full clinical breathing studio supporting 6 evidence-based techniques with adaptive visual bloom, dynamic multi-phase progression (inhale, inhale-hold, exhale, exhale-hold), tactile haptic cadence, and zero-network audio soundscapes.

## Supported Techniques & Timings
1. **Cyclic Sighing**: 4s Inhale, 0s Hold, 8s Exhale, 0s Rest (Huberman / Stanford parasympathetic reset)
2. **Box Breathing**: 4s Inhale, 4s Hold, 4s Exhale, 4s Rest (Tactical autonomic balance)
3. **Resonance Breathing**: 5.5s Inhale, 0s Hold, 5.5s Exhale, 0s Rest (0.1 Hz HRV peak)
4. **4-7-8 Relaxation**: 4s Inhale, 7s Hold, 8s Exhale, 0s Rest (Weil sleep induction)
5. **Star Breathing**: 3s Inhale, 1s Hold, 3s Exhale, 1s Rest (Micro-cadence grounding)
6. **Diaphragmatic (Belly)**: 4s Inhale, 0s Hold, 6s Exhale, 0s Rest (Vagal nerve stimulation)

## Changes Implemented
- [x] **Domain Models**:
  - `lib/features/breathing_grounding/domain/models/breathing_session_state.dart`:
    - Added `BreathingTechnique` enum with displayName, inhaleMs, inhaleHoldMs, exhaleMs, exhaleHoldMs.
    - Updated `BreathingPhase` to include `inhaleHold` and `exhaleHold` with backward-compatible `isInhale`, `isHold`, `isExhale`, and clinical label strings.
    - Added `technique` property to `BreathingSessionState` with immutable `copyWith`.
- [x] **Visualizer**:
  - `lib/features/breathing_grounding/presentation/widgets/cyclic_sigh_bloom_painter.dart`:
    - Added organic rendering for hold phases (`inhaleHold`, `exhaleHold`) with resting subtle wave oscillations.
    - Adapted color transitions (Sage `#7DBA9B` during inhale, deep Dusk Blue `#5B8A99` during exhale, warm amber accent during holds).
- [x] **Controller**:
  - `lib/features/breathing_grounding/presentation/controllers/breathing_session_controller.dart`:
    - Implemented `setTechnique(BreathingTechnique technique)`.
    - Added multi-phase state progression through 4 distinct phases based on technique parameters.
- [x] **UI**:
  - `lib/features/breathing_grounding/presentation/screens/breathing_grounding_screen.dart`:
    - Added horizontal technique selector chip list with smooth selection state.
    - Added dynamic pacing labels and timing indicators.
- [x] **Verification**:
  - `test/features/breathing_grounding/verify_respiration_standalone.dart`: 100% assertions passed.
  - `test/features/breathing_grounding/breathing_session_controller_test.dart`: Added unit tests for technique switching.
