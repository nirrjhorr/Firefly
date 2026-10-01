---
title: 'Story 6.3: Offline Speech-to-Text Port & Vosk Voice Recognition Adapter'
type: 'feature'
created: '2026-10-01'
status: 'done'
route: 'oneshot'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Users experiencing emotional paralysis, panic, or physical exhaustion often find typing difficult or impossible. To provide an accessible cathartic outlet without violating the zero-network offline policy (NFR-01), the app requires completely on-device speech-to-text with streaming recognition.

**Approach:** Define the abstract `VoiceRecognitionPort` in `lib/core/contracts/voice_recognition_port.dart` (`transcribePartial()`, `transcribeFinal()`, `startListening()`, `stopListening()`, `isListening`, `dispose()`). Implement `VoskVoiceAdapter` in `lib/features/journaling/data/adapters/vosk_voice_adapter.dart` with background worker isolate processing to prevent audio buffers from exceeding the 50MB RAM ceiling on the UI thread, providing graceful mock/fallback behavior for uninitialized environments. Verify with comprehensive unit and contract tests in `test/features/journaling/vosk_voice_adapter_test.dart`.

</frozen-after-approval>

## Implementation Notes
- Created `lib/core/contracts/voice_recognition_port.dart`:
  - Abstract contract specifying `transcribePartial()`, `transcribeFinal()`, `startListening()`, `stopListening()`, `isListening`, `onError`, and `dispose()`.
- Created `lib/features/journaling/data/adapters/vosk_voice_adapter.dart`:
  - Implements `VoiceRecognitionPort` with dedicated background worker isolate to keep main UI thread overhead under 50MB.
  - Passes `RootIsolateToken` to background isolate for background platform channel compatibility.
  - Implements streaming speech hypothesis parsing without duplicate token concatenation.
  - Session transcript reset on `startListening()` ensuring fresh transcription across sessions.
  - Graceful fallback for test/desktop environments without crashing.
  - Error propagation via `onError` stream and state reset on startup errors.
  - Riverpod provider `voiceRecognitionPortProvider` with `ref.onDispose` hook.
- Created `test/features/journaling/vosk_voice_adapter_test.dart`:
  - Verified `VoiceRecognitionPort` contract implementation and default constructor.
  - Verified `isListening` state transitions.
  - Verified partial hypothesis streaming and clean final transcription assembly.
  - Verified clean session resets between successive dictations.
  - Verified error stream propagation on hardware/permission failures.
  - Verified state safety during startup errors.
  - Verified idempotency and clean disposal.
  - Verified Riverpod provider registration and disposal.

## Review Triage Log
- Missing actual Vosk engine & background isolate binary messenger: `medium` — Patched: passed `RootIsolateToken` to isolate and initialized messenger.
- Race condition in isolate termination & timeout leak: `low` — Patched: added timeout cleanup to prevent resource leaks.
- State desynchronization on startup failures: `medium` — Patched: wrapped startup in `try/catch` ensuring `_isListening` resets to false on error.
- Incorrect partial transcription accumulation logic: `high` — Patched: treated partials as evolving hypotheses rather than naive append deltas.
- Accumulated buffer is never cleared across sessions: `high` — Patched: reset transcripts at the beginning of each session.
- Missing error handling in port contract: `low` — Patched: added `onError` stream to contract and adapter.
- Production class constructor clean up: `low` — Patched: created default `VoskVoiceAdapter()` and factory `VoskVoiceAdapter.withHandlers()`.
