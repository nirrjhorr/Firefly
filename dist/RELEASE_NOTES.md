# Firefly v2.2.0 Release Notes

**Version:** `2.2.0+14`  
**Date:** 2026-10-06  
**Build Hash (SHA-256):** `1597bca9f9e68a141d47c0475066ea5ebef407a1e74265664e25a1a809bb6c3c`  
**Architecture:** 100% Offline Mental Wellbeing Companion & 6-Group Self-Regulation System  

## Key Highlights in v2.2.0
- **Multi-Tab Activity Architecture & 6 Core Regulation Groups:**
  - Complete library of 70 evidence-based self-regulation practices.
  - Interactive multi-tab organization: Movement & Somatic, Respiration, Grounding & Nature, Cognitive Flow & Puzzles, Expression & Reframing, and Rest & Social Connection.
  - Sub-millisecond client-side search, real-time energy filtering (Levels 1 to 5), and direct execution routes.
  - Dual-mode Right Now Distress modal featuring acute distress anchors and regulation group browsing.
- **Apple-Inspired Design System Harmonization & Stitch Serene Sanctuary:**
  - Low-stimulation illuminated sage (`#7DBA9B`), dusk blue (`#5B8A99`), and grounding warm amber (`#D99B65`).
  - Full WCAG 2.2 AAA contrast compliance (8.19:1 sage, 14.89:1 primary text against dark `#111518` canvas).
  - Canonical `FireflyNavHeader`, `FireflyEmptyState`, and `FireflyCard` tokens.
- **Clinical Safety Guardrails & Zero-Network Guarantee:**
  - Deterministic on-device crisis phrase detector with non-blocking local safety banner.
  - Instant pure-black OLED panic blackout screen with memory zeroing (< 15ms).
  - Stanley-Brown 6-step Safety Plan intervention with offline SOS overlay.
  - 100% offline verified: zero remote telemetry, zero cloud tracking, AES-256-GCM double encryption.
- **Packaging & Icon Verification:**
  - Verified launcher icons across all DPI buckets (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi) + Android v26 adaptive icon.
  - Complete bundled asset verification (audio soundscapes, Vosk acoustic models, Atkinson Hyperlegible fonts, curated activities JSON).

## Installation via ADB Sideload
```bash
# Sideload release package to physical test device
adb install -r dist/firefly-v2.2.0-release.apk

# Launch app directly
adb shell monkey -p app.firefly -c android.intent.category.LAUNCHER 1
```
