# Memory.md
# Firefly — Agent Memory & State

**Current Phase:** Sprint 4: Expressive Journaling & Unsent Letters (FR-05) (Planning Completed, Ready for Dev)

## Micro-Tasks for Sprint 4

### Epic 6: Expressive Journaling & Unsent Letters (FR-05)
- [x] 6.1 Application-Layer AES-256-GCM Double Encryption & Cryptographic Erasure (`JournalCryptoService`, HKDF subkey derivation, 12-byte nonce, 16-byte MAC, memory zeroing).
- [x] 6.2 Journal Drift Database DAO, Repository & TTL Expiry Engine (`JournalDao`, `JournalRepository`, `JournalEntry` domain model, automated TTL cleanup query).
- [ ] 6.3 Offline Speech-to-Text Port & Vosk Voice Recognition Adapter (`VoiceRecognitionPort`, `VoskVoiceAdapter`, background isolate transcription < 50MB RAM).
- [ ] 6.4 Journal State Management & Unsent Letters Controller (`JournalEditorController`, `JournalListController`, word count, TTL configuration, instant burn/wipe action).
- [ ] 6.5 Distraction-Free Journal Editor Screen & Unsent Letters UI (`JournalListScreen`, `JournalEntryScreen`, Atkinson Hyperlegible, offline mic dictation, burn animation).

## State
**Currently Working On:** Epic 6: Expressive Journaling & Unsent Letters.
**Next Immediate Step:** Story 6.3 (`6-3-offline-speech-to-text-port-vosk-voice-adapter`).
