# Firefly v1.0.0 Release Notes

**Version:** `1.0.0+1`  
**Date:** 2026-10-01  
**Build Hash (SHA-256):** `4dc046b20f94d5844de40b34d2c11683062d49f42712d7ef9bdffbc126a4cd8c`  
**Architecture:** 100% Offline Mental Wellbeing Companion  

## Key Highlights
- **100% Zero-Network Operation:** System-wide socket/HTTP killswitch prevents all outbound data leakage.
- **Stanley-Brown Safety Plan Intervention (SPI):** 6 evidence-based steps, persistent 1-tap SOS overlay, and panic fast-exit (< 15ms purge latency).
- **Affect Check-In & Deterministic Recommendations:** Sub-millisecond state matching into personalized respiration, behavioral activation, or unsent letters.
- **Respiration & Sensory Grounding:** Cyclic sighing (4s inhale / 8s exhale), visual bloom custom canvas, tactile haptics, and bundled ambient audio.
- **Tiny Steps Behavioral Activation:** Curated 20+ micro-action library without streaks or gamification.
- **Expressive Journaling & Unsent Letters:** Application-layer AES-256-GCM double encryption with cryptographic erasure, offline Vosk speech-to-text dictation, and auto-delete TTL intervals.
- **Hardened Local Storage:** SQLCipher AES-256-CBC database with hardware-backed key derivation.

## Installation via ADB Sideload
```bash
# Sideload release package to physical test device
adb install -r dist/firefly-v1.0.0-release.apk

# Launch app directly
adb shell monkey -p app.firefly -c android.intent.category.LAUNCHER 1
```
