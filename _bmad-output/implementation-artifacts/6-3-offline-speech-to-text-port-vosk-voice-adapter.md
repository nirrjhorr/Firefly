# Story 6.3: Offline Speech-to-Text Port & Vosk Voice Recognition Adapter

Status: ready-for-dev

## Story Description
As a user feeling too exhausted, numb, or overwhelmed to type,
I want an offline voice-to-text input option powered by Vosk,
So that I can articulate my feelings verbally with 100% on-device privacy and zero audio data sent to any network.

## Acceptance Criteria
1. Abstract `VoiceRecognitionPort` in `lib/core/contracts/voice_recognition_port.dart`:
   - Methods: `Stream<String> transcribePartial()`, `Future<String> transcribeFinal()`, `Future<void> startListening()`, `Future<void> stopListening()`, `bool get isListening`.
2. `VoskVoiceAdapter` implementation:
   - Zero network transmission (offline-only speech model).
   - Audio buffer processing managed on a background isolate to keep UI thread memory overhead strictly < 50MB.
   - Graceful fallback for mock/test environments or uninitialized mic permissions without app crashes.
   - Disposing or stopping the adapter cleanly closes streams and terminates any background isolate worker.
3. Unit & contract tests:
   - Verifying state changes during `startListening` and `stopListening`.
   - Verifying partial transcription events are emitted on `transcribePartial()`.
   - Verifying `transcribeFinal()` produces the accumulated recognized text.
   - Verifying isolate and resource disposal cleanup.
