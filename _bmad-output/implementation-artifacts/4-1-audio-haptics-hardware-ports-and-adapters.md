# Story 4.1: Audio & Haptics Hardware Ports and Adapters

Status: ready-for-dev

## Story Description
As a developer,
I want hardware abstraction ports and concrete adapters for audio playback and device haptics,
So that respiration audio and tactile feedback run deterministically offline and remain easily testable with mocks.

## Acceptance Criteria
1. Abstract interfaces `AudioPlayerPort` and `HapticsPort` defined in `core/contracts/`:
   - `AudioPlayerPort`: methods `loadLoopingAsset(String assetPath)`, `play()`, `pause()`, `stop()`, `dispose()`, `setVolume(double volume)`, and smooth 300ms volume ramp `fadeIn()` / `fadeOut()`.
   - `HapticsPort`: methods `phaseTransitionInhale()`, `phaseTransitionExhale()`, and `groundingConfirm()`.
2. `JustAudioPlayerAdapter` implementation using `just_audio` and `audio_session`:
   - Configures audio session for ambient playback without interrupting other audio if possible.
   - Gapless looping via `LoopingAudioSource` / loop mode.
   - 300ms volume fade-in and fade-out ramping.
   - Silent failure: audio loading/playback errors are logged or swallowed safely without crashing or stopping respiration sessions.
3. `FlutterHapticsAdapter` implementation:
   - `phaseTransitionInhale()`: triggers double light impact 100ms apart.
   - `phaseTransitionExhale()`: triggers single light impact.
   - `groundingConfirm()`: triggers selection click.
4. Comprehensive unit tests using `mocktail` verifying interface contracts and error recovery.
